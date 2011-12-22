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

#import "ACReplacingWrapper.h"
#import "ACAspectManager.h"
#import "ACGeneratedCode.h"
#import </usr/include/objc/objc-class.h>

@implementation ACReplacingWrapper

+(BOOL)canWrapMethod: (ACMethodSignature *) method{
    return [self verifyReplacement: [method getReplacementSEL]];
}

+(void)wrapMethod: (ACMethodSignature *) method{
    struct objc_method * original = [method getMethod];
    struct objc_method * replacement = class_getInstanceMethod([ACGeneratedCode class], [method getReplacementSEL]);
    if(replacement == NULL){
	NSLog(@"error checking should have stopped us from getting to this point");
	return;
    }
    original->method_imp = replacement->method_imp;	
}

+(BOOL)verifyReplacement: (SEL)selector{
    if( selector == NULL)
        return NO;
    struct objc_method * replacement = class_getInstanceMethod([ACGeneratedCode class], selector);
    if(replacement == NULL){
        return NO;
    }
    return YES;
}

+(void)wrapClass:(Class)toWrap{
    ACAspectManager * manager = [ACAspectManager sharedManager];
    if(![manager isClassWrappedWithDepth: toWrap]){
        int depth = [ACClass depthOfInheritance: toWrap];
	if([ACAspectManager loggingAll])
	    NSLog(@"wrapping %s with depth %i", toWrap->name, depth);
        struct objc_method_list * methodsToAdd = 
                (struct objc_method_list *)
                malloc( sizeof(struct objc_method) 
                + sizeof(struct objc_method_list));
        methodsToAdd->method_count = 1;
        struct objc_method meth;
        //NSLog(@"adding depth of %i to %s", depth, toWrap->name);
        NSString * depthSelectorString = [NSString stringWithFormat: @"depth%i", depth];
        SEL depthSelector = sel_registerName([depthSelectorString cString]);
        meth = *class_getInstanceMethod([ACGeneratedCode class], depthSelector);
        meth.method_name = @selector(__ac_depth);
        methodsToAdd->method_list[0] = meth;
        class_addMethods(toWrap, methodsToAdd);
        [manager setWrappedWithDepth: YES forClass: toWrap];
    }
}

@end

