/*
* Copyright (c) 2006 Jacob Burkhart (JacobBurkhart@gmail.com)
*
* Permission is hereby granted, free of charge, to any person obtaining a
* copy of this software and associated documentation files (the "Software"),
* to deal in the Software without restriction, including without limitation
* the rights to use, copy, modify, merge, publish, distribute, sublicense,
* and/or sell copies of the Software, and to permit persons to whom the
* Software is furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
* IN THE SOFTWARE.
*/

#import "ACAspect.h"
#import "ACAdviceList.h"
#import "ACMethodIterator.h"
#import </usr/include/objc/objc-class.h>
#import "ACAspectManager.h"
#import "ACInvocation.h"
#import "ACIMP.h"
#import "ACCodeGenerator.h"
#import "ACReplacingWrapper.h"
#import "ACForwardingWrapper.h"
#import "ACMethodSignature.h"

//callbacks!!!, we can use aspects to create callbacks

@implementation ACAspect

+(id)aspectWithPointCut: (id)pc andAdviceObject: (id)adv{
    return [[self alloc] initWithPointCut: pc andAdviceObject: adv];
}

-(id)initWithPointCut: (id)pc andAdviceObject: (id)adv{
    self = [super init];
    if (self){
        pointCut = [[NSArray arrayWithArray: [pc joinPoints]] retain];
        advice = [adv retain];
        loaded = NO;
	getSignature = (id (*)(id, SEL, SEL))[NSObject 
	    methodForSelector: @selector(instanceMethodSignatureForSelector:)];
    }
    return self;
}

- (void)dealloc{
    [pointCut release];
    [advice release];
    [super dealloc];
}

-(void)load{
    if([self isLoaded])
        return;
    [self loadActually: YES]; 
}

-(void)loadGenOnly{
    [self loadActually: NO]; 
}

-(void)loadActually: (BOOL)actuallyLoad{
    int i, j;
    ACAspectManager * manager = [ACAspectManager sharedManager];
    ACCodeGenerator * codeManager = [ACCodeGenerator generator];
    NSArray * classesToWrap = pointCut;
    for(i=0; i<[classesToWrap count]; i++){
        ACClass * ithClass = [classesToWrap objectAtIndex: i];
        NSArray * methodsToWrap = [ithClass getMethods];
        Class toWrap = [ithClass getClass];
        for(j=0; j<[methodsToWrap count]; j++){
            ACMethod * ithMethod = [methodsToWrap objectAtIndex: j];
            struct objc_method * method = [ithMethod getMethod];
	    SEL selector = method->method_name;
            if( selector == @selector(__ac_depth))
            {
		//we should not wrap our own methods
            }else{
		ACMethodSignature * signature;
                NS_DURING
		    NSMethodSignature * msig = getSignature(toWrap, 
							    @selector(instanceMethodSignatureForSelector:), 
							    selector);
                    signature = [[ACMethodSignature alloc] initWithMethod: method 
							   signature: msig 
							   depth: [ithClass depthOfInheritance]];
                NS_HANDLER
		    if([ACAspectManager loggingGen])
			NSLog(@"FAILED to get signature %s %s", toWrap->name, selector);
                    signature = nil;
                NS_ENDHANDLER
                if( (signature != nil) ){
		    //Wrap is possible
		    if(actuallyLoad){
			if( [ACReplacingWrapper canWrapMethod: signature] ){
			    [manager addAdviceObject: advice forMethod: method onClass: toWrap];
			    [ACReplacingWrapper wrapClass: toWrap];
			    [ACReplacingWrapper wrapMethod: signature];
			}else if( [ACForwardingWrapper canWrapMethod: signature] ){
			    [manager addAdviceObject: advice forMethod: method onClass: toWrap];
			    [ACForwardingWrapper wrapClass: toWrap];
			    int depth = [ithClass depthOfInheritance];
			    [ACForwardingWrapper wrapMethod: method withDepth: depth];
			    Class wrapSuper = toWrap->super_class;
			    Method methodSuper =  class_getInstanceMethod(wrapSuper, selector);
			    while(methodSuper != NULL){
				depth--;
				[ACForwardingWrapper wrapMethod: methodSuper withDepth: depth];
				[ACForwardingWrapper wrapClass: wrapSuper];
				wrapSuper = wrapSuper->super_class;
				methodSuper =  class_getInstanceMethod(wrapSuper, selector);
			    }
			}else{
			    if([ACAspectManager loggingGen])
				NSLog(@"--Failed to Wrap %s %@", toWrap->name, signature);
			}
		    }
		    //Generate Code is applicable
		    if(![ACReplacingWrapper canWrapMethod: signature] && [codeManager generateCode]){
			[codeManager addFailedMethod: signature forClass: toWrap];
			if([ACAspectManager loggingGen])
			    NSLog(@"--Will generate code for %s %@", toWrap->name, signature);
		    }
		}else{
		    if([ACAspectManager loggingGen])
			NSLog(@"--Can't generate code for %s %s", toWrap->name, selector);
		}
            }
        }
    }
    loaded = YES;
}


-(void)unload{
    if(![self isLoaded])
        return;
    int i, j;
    ACAspectManager * manager = [ACAspectManager sharedManager];
    NSArray * classesToWrap = pointCut;
//    NSArray * classesToWrap = [pointCut joinPoints];
    for(i=0; i<[classesToWrap count]; i++){
        ACClass * ithClass = [classesToWrap objectAtIndex: i];
        NSArray * methodsToWrap = [ithClass getMethods];
        Class toWrap = [ithClass getClass];
        for(j=0; j<[methodsToWrap count]; j++){
            ACMethod * ithMethod = [methodsToWrap objectAtIndex: j];
            struct objc_method * method = [ithMethod getMethod];
	    [manager removeAdviceObject: advice forMethod: method onClass: toWrap];
        }
        //after all aspects on ithClass have been unloaded
        //check if we can now return that class to it's original state
        if( [manager isClassWrappedWithDepth: toWrap] || [manager isClassWrappedWithForwarding: toWrap] ){
            //both classes and metaclasses will get passed through here for unloading
            //so we may have different classes with the same name (one meta the other not)
	    if([ACAspectManager loggingAll])
		NSLog(@"returning class %s to original state", toWrap->name);
            
            //give it back it's old:
            //methodSignatureForSelector
            //forwardInvocation
            
            //remove any added 
            // __ac_depth
            //method sig
            //or.. forwardInv
            
            //this is not a priority
        }
    }
    loaded = NO;
}

-(BOOL)isLoaded{
    return loaded;
}

@end