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

#import "ACAspectManager.h"
#import "ACAdviceList.h"
#import "ACAspect.h"
#import "ACInvocation.h"
#import "ACIMP.h"

@implementation ACAspectManager

static int loggingStyle = 0;
static ACAspectManager *_ac_aspect_manager_instance = nil;

+(ACAspectManager *)sharedManager{
    if( _ac_aspect_manager_instance == nil){
        _ac_aspect_manager_instance = [[[self alloc] init] retain];
/*
        NSLog(@"loading signature aspect");
        ACPointCut * pointCut = [[ACPointCut alloc] init];
        [pointCut setClassScope: [[ACClassScope alloc] init]];
        [[pointCut getClassScope] addClassAndMeta: [NSObject class]];
        [[pointCut getMethodFilter] filterAllMethods];
        [[pointCut getMethodFilter] allowMethodsNamed:@"methodSignatureForSelector:"];
        ACLookAspect * signatureAspect = [[ACLookAspect alloc] initWithPointCut: pointCut andAdviceObject: [ACSignatureFix new]];
        [signatureAspect load];
        NSLog(@"loaded signature aspect");
*/
    }
    return _ac_aspect_manager_instance;
}

+(void)enableAllAdvice{
    [ACInvocation enableAllAdvice];
}

+(void)disableAllAdvice{
    [ACInvocation disableAllAdvice];
}

+(void)protectAdvice{
    [ACInvocation protectAdvice];
}

+(void)unprotectAdvice{
    [ACInvocation unprotectAdvice];
}


+(void)quiet{
    loggingStyle = 0;
}

+(void)genOnly{
    loggingStyle = 1;
}

+(void)verbose{
    loggingStyle = 2;
}

+(BOOL)loggingGen{
    return loggingStyle >= 1;
}

+(BOOL)loggingAll{
    return loggingStyle == 2;
}

- (id)init {
    self = [super init];
    if (self) {
        adviceLookup = [[ACAdviceLookup new] retain];
        methodSigLookup = [[ACIMPLookup new] retain];
        forwardInvLookup = [[ACIMPLookup new] retain];	
	classWrappedWithDepth = [[ACBOOLLookup new] retain];
	classWrappedWtihForwarding = [[ACBOOLLookup new] retain];
    }
    return self;
}

- (void)dealloc{
    [adviceLookup release];
    [methodSigLookup release];
    [forwardInvLookup release];
    [classWrappedWithDepth release];
    [classWrappedWtihForwarding release];
    [super dealloc];
}

-(void)setWrappedWithDepth:(BOOL) b forClass: (Class) c{
    [classWrappedWithDepth saveBOOL: b forClass: c];
}

-(BOOL)isClassWrappedWithDepth:(Class)c{
    return [classWrappedWithDepth getBOOLforClass: c];
}

-(void)setWrappedWithForwarding:(BOOL) b forClass: (Class) c{
    [classWrappedWtihForwarding saveBOOL: b forClass: c];
}

-(BOOL)isClassWrappedWithForwarding:(Class)c{
    return [classWrappedWtihForwarding getBOOLforClass: c];
}


/*
-(void)set:(BOOL) b forClassReady: (Class) c{
    [classReadyLookup saveBOOL: b forClass: c];
}

-(BOOL)isClassWrappedWithDepth:(Class)c{
    return [classReadyLookup getBOOLforClass: c];
}
*/

/*
-(void)wrap:(ACMethodWrapper *) wrapper withAdvice: (id)advice{
    if([ACAspectManager loggingAll])
	NSLog(@"---wrapping selector %s on class %s", method->method_name, class->name);    
    [adviceLookup addAdvice: advice forMethod: method onClass: class];
}
*/


-(void)addAdviceObject:(id)advice forMethod: (struct objc_method *)method onClass: (Class)class{
    //store the original IMP and the advice for the 2 keys selectorKey and classKey
    //if an IMP is already being stored there, then just add the new advice
    if([ACAspectManager loggingAll])
	NSLog(@"---wrapping selector %s on class %s", method->method_name, class->name);
    [adviceLookup addAdvice: advice forMethod: method onClass: class];
}

-(void)removeAdviceObject:(id)advice forMethod: (struct objc_method *)method onClass: (Class)class{
    //remove the advice from the store
    //if no advice left, also restore the IMP to method and remove the ACAdviceListWithIMP object
    if([ACAspectManager loggingAll])
	NSLog(@"---unwrapping selector %s on class %s", method->method_name, class->name);
    [adviceLookup removeAdvice: advice forMethod: method onClass: class];
}

-(ACAdviceList *)adviceListForSelector: (SEL)selector onClass: (Class) toLookup{
    ACAdviceList * toReturn = [adviceLookup adviceListforSelector: selector onClass: toLookup];
    if(toReturn == nil)
        NSLog(@"nil advice %s",toLookup->name);
    return toReturn;
}

-(NSMethodSignature *)savedMethodSignatureForSelector: (SEL)selector onClass: (Class) toLookup{
    ACAdviceList * adviceList = [adviceLookup adviceListforSelector: selector onClass: toLookup];
    if(adviceList == nil)
	return nil;
    else
	return [adviceList getSig];
}

//+(ACAdviceList *)adviceListForSelector: (SEL)selector onObject: (id)object depth: (int) d{
//    return [[self sharedManager] adviceListForSelector: selector onObject: object];
//}

-(void)saveSig: (Method) sig forClass: (Class) c{
    [methodSigLookup saveIMP: sig->method_imp forClass: c];
}

-(void)saveInv: (Method) inv forClass: (Class) c{
    [forwardInvLookup saveIMP: inv->method_imp forClass: c];
}

-(ACIMP *)getIMPforClass: (Class) c onLookup: (ACIMPLookup *) impLookup methodDepth: (int) md objectDepth: (int) od{
    Class toLookup = c;
    while(md < od){
        md ++;
        toLookup = toLookup->super_class;
    }
    return [impLookup getIMPforClass: toLookup];
}

-(ACIMP *)getSigforClass: (Class) c methodDepth: (int) md objectDepth: (int) od{
    return [self getIMPforClass: c onLookup: methodSigLookup methodDepth: md objectDepth: od];
}

-(ACIMP *)getInvforClass: (Class) c methodDepth: (int) md objectDepth: (int) od{
    return [self getIMPforClass: c onLookup: forwardInvLookup methodDepth: md objectDepth: od];
}

@end


