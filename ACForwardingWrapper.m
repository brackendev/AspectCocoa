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

#import "ACGeneratedCode.h"
#import "ACForwardingWrapper.h"
#import "ACAspectManager.h"
#import "ACMethodIterator.h"
#import "ACInvocation.h"
#import "NSObjectExtensions.h"
#import </usr/include/objc/objc-class.h>

@implementation ACForwardingWrapper

+(BOOL)canWrapMethod: (ACMethodSignature *) method
{
	//Something's broken, disabling forwarding wrappers completely until we figure it out
	return NO;
	/*
    SEL selector = [method getSelector];
    if(class_getInstanceMethod([NSObject class], selector) == NULL &&
       class_getInstanceMethod([NSObject class]->isa, selector) == NULL)
    {
	return YES;
    }else{
	return NO;
    }
	*/
}

+(void)wrapMethod: (struct objc_method *) method withDepth: (int) depth{
    NSString * methodSelector = [NSString stringWithCString: (char *)method->method_name];            
    if(![methodSelector hasPrefix: @"__ac_hiding_"]){
        method->method_name = sel_registerName([[NSString stringWithFormat: @"__ac_hiding_%i_%s", depth, method->method_name] cString]);
    }
}

+(void)wrapClass:(Class)toWrap{
    if([ACAspectManager loggingAll])
	NSLog(@"wrapping %s with forwarding", toWrap->name);
    ACAspectManager * manager = [ACAspectManager sharedManager];
    if(![manager isClassWrappedWithDepth: toWrap]){
	[ACReplacingWrapper wrapClass: toWrap];
    }
    if(![manager isClassWrappedWithForwarding: toWrap]){
	int depth = [ACClass depthOfInheritance: toWrap];
        BOOL addInv = NO;
        BOOL addSig = NO;
        int countToAdd = 2;
        //save the old methodSignatureForSelector:
	//we use ACMethodIterator instead of class_getInstanceMethod to find the original
	//because we to find the method only in toWrap, not in a superclass
        Method methSig = [ACMethodIterator 
                          findMethod: @selector(methodSignatureForSelector:) 
                          onClass: toWrap];
        if(methSig != NULL){
            //save it
            [manager saveSig: methSig forClass: toWrap];
            //and replace it with a special one
            NSString * selectorString = [NSString stringWithFormat: @"methodSignatureForSelector%i:", depth];
            SEL sigSelector = sel_registerName([selectorString cString]);
            methSig->method_imp = class_getInstanceMethod([self class], sigSelector)->method_imp;
            countToAdd--;
        }else{
            //add a new one
            addSig = YES;                
        }
        //save the old forwardInvocation:
        Method forwInv = [ACMethodIterator 
                          findMethod: @selector(forwardInvocation:) 
                          onClass: toWrap];
        if(forwInv != NULL){
            //save it
            [manager saveInv: forwInv forClass: toWrap];
            //and replace it with a special one
            NSString * selectorString = [NSString stringWithFormat: @"forwardInvocation%i:", depth];
            SEL invSelector = sel_registerName([selectorString cString]);
            forwInv->method_imp = class_getInstanceMethod([self class], invSelector)->method_imp;
            countToAdd--;
        }else{
            //add a new one
            addInv = YES;
        }
        if(countToAdd > 0){
            struct objc_method_list * methodsToAdd = 
                (struct objc_method_list *)
                malloc(countToAdd * sizeof(struct objc_method) 
                + sizeof(struct objc_method_list));
            methodsToAdd->method_count = countToAdd;
            struct objc_method meth;
            //give it a new forwardInvocation:
            if( addInv ){
                NSString * selectorString = [NSString stringWithFormat: @"forwardInvocation%i:", depth];
                SEL invSelector = sel_registerName([selectorString cString]);
                meth = *class_getInstanceMethod([self class], invSelector);
                meth.method_name = @selector(forwardInvocation:);
                methodsToAdd->method_list[--countToAdd] = meth;
            }
            //give it a new methodSignatureForSelector:
            if( addSig ){
                NSString * selectorString = [NSString stringWithFormat: @"methodSignatureForSelector%i:", depth];
                SEL sigSelector = sel_registerName([selectorString cString]);
                meth = *class_getInstanceMethod([self class], sigSelector);
                meth.method_name = @selector(methodSignatureForSelector:);
                methodsToAdd->method_list[--countToAdd] = meth;
            }
            class_addMethods(toWrap, methodsToAdd);
        }
    }
    [manager setWrappedWithForwarding: YES forClass: toWrap];
}


/*
*
* !!! We also need to add a customized respondsToSelector: and implmentsProtocol: to each wrapped class
*
*/


#define forwardInv(i) \
    - (void)forwardInvocation##i:(NSInvocation *)anInvocation \
    { \
        __ac_forwardInvocation(self, _cmd, anInvocation, i); \
    } \

forwardInv(0)
forwardInv(1)
forwardInv(2)
forwardInv(3)
forwardInv(4)
forwardInv(5)
forwardInv(6)
forwardInv(7)
forwardInv(8)
forwardInv(9)
forwardInv(10)
forwardInv(11)
forwardInv(12)

void perform_forwardInvocation(id self, SEL original, SEL toInvoke,  NSInvocation * anInvocation, int depth){
	Class toLookup = resolveClass(self, depth);
	Method thisMethod = [ACMethodIterator 
                          findMethod: toInvoke
                          onClass: toLookup];
						  
	if(thisMethod == NULL)
	{
		NSLog(@"Error, couldn't find method %s on class %s", toInvoke, toLookup->name);
		[ACMethodIterator listMethods: toLookup];
	}

	struct objc_method_list * methodsToAdd = 
                (struct objc_method_list *)
                malloc( sizeof(struct objc_method) 
                + sizeof(struct objc_method_list));
        methodsToAdd->method_count = 1;
        methodsToAdd->method_list[0] = *thisMethod;
	methodsToAdd->method_list[0].method_name = original;
        class_addMethods(toLookup, methodsToAdd);

	ACAdviceList * advice = [[ACAspectManager sharedManager] adviceListForSelector: original onClass: toLookup];
	ACInvocation * invoker =  [[ACInvocation alloc] initWithInvocation: anInvocation];
	[invoker setClass: toLookup];
	[invoker setSelector: original];
	[invoker setAdvice: advice];
	[invoker performAdvice];
	
	class_removeMethods(toLookup, methodsToAdd);
}

void __ac_forwardInvocation(id self, SEL _cmd, NSInvocation * anInvocation, int depth){
    SEL oldInvoke = [anInvocation selector];
    int originalDepth = depth;
    if([self respondsToSelector: oldInvoke]){
	while(depth>0){
	    depth--;
	    SEL superInvoke = sel_registerName([[NSString stringWithFormat: @"__ac_hiding_%i_%s", depth,oldInvoke] cString]);
	    if ([self respondsToSelector: superInvoke]){
		[anInvocation setSelector: superInvoke];
		return perform_forwardInvocation(self, oldInvoke, superInvoke, anInvocation, depth);
	    }
	}
    }
    SEL newInvoke = sel_registerName([[NSString stringWithFormat: @"__ac_hiding_%i_%s", depth,oldInvoke] cString]);
    if ([self respondsToSelector: newInvoke]){
	[anInvocation setSelector: newInvoke];
	return perform_forwardInvocation(self, oldInvoke, newInvoke, anInvocation, originalDepth);
    }else{
        //see if we have an imp for forwardInvocation on this class saved
        ACIMP * savedIMP = [[ACAspectManager sharedManager] getInvforClass: self->isa methodDepth: depth objectDepth: [self __ac_depth]];
        if(savedIMP != nil){
            IMP toInvoke = [savedIMP getIMP];
	    toInvoke(self, @selector(forwardInvocation:), anInvocation);
        }else{
            __ac_nsobjects_forwardInvocation(self, anInvocation);
        }
    }
}

void __ac_nsobjects_forwardInvocation(id self, NSInvocation * anInvocation){
    IMP toInvoke = class_getInstanceMethod([NSObject class], @selector(forwardInvocation:))->method_imp;
    toInvoke(self, @selector(forwardInvocation:), anInvocation);
}

//we're getting the replacement imp 
//for methodSignatureForSelector:
//from this class
#define methodSig(i) \
    - (NSMethodSignature *)methodSignatureForSelector##i:(SEL)aSelector \
    { \
        return __ac_methodSignatureForSelector(self, _cmd, aSelector, i); \
    } \

methodSig(0)
methodSig(1)
methodSig(2)
methodSig(3)
methodSig(4)
methodSig(5)
methodSig(6)
methodSig(7)
methodSig(8)
methodSig(9)
methodSig(10)
methodSig(11)
methodSig(12)

NSMethodSignature* __ac_methodSignatureForSelector(id self, SEL _cmd, SEL aSelector, int depth){
//    NSLog(@"(Aspect) method sig %s %i", aSelector, depth);
    //newSig = aSelector prepended with __ac_hiding_
    SEL newSig = sel_registerName([[NSString stringWithFormat: @"__ac_hiding_%i_%s", depth, aSelector] cString]);
    //see if there is a hidding method with this selector
    if ([self respondsToSelector: newSig]){
        //return the signature of the hiding method
        return __ac_nsobjects_methodSignatureForSelector(self, newSig);
    }else{
        //see if we have an imp for forwardInvocation on this class saved
        ACIMP * savedIMP = [[ACAspectManager sharedManager] getSigforClass: self->isa methodDepth: depth objectDepth: [self __ac_depth]];
        if(savedIMP != nil){
            IMP toInvoke = [savedIMP getIMP];
            return toInvoke(self, @selector(methodSignatureForSelector:), aSelector);
        }else{
            return __ac_nsobjects_methodSignatureForSelector(self, aSelector);
        }
    }
}

NSMethodSignature* __ac_nsobjects_methodSignatureForSelector(id self, SEL aSelector){
    IMP toInvoke = class_getInstanceMethod([NSObject class], @selector(methodSignatureForSelector:))->method_imp;
    return toInvoke(self, @selector(methodSignatureForSelector:), aSelector);
}

	
@end
