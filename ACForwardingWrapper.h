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

#import <Foundation/Foundation.h>
#import <AspectCocoa/ACReplacingWrapper.h>
#import <AspectCocoa/ACMethodSignature.h>

@interface ACForwardingWrapper : NSObject {
}

+(BOOL)canWrapMethod: (ACMethodSignature *) method;

+(void)wrapMethod: (struct objc_method *) method withDepth: (int) depth;

+(void)wrapClass:(Class)toWrap;


#define forwardInvHEADER(i) \
    - (void)forwardInvocation##i:(NSInvocation *)anInvocation \

forwardInvHEADER(0);
forwardInvHEADER(1);
forwardInvHEADER(2);
forwardInvHEADER(3);
forwardInvHEADER(4);
forwardInvHEADER(5);
forwardInvHEADER(6);
forwardInvHEADER(7);
forwardInvHEADER(8);
forwardInvHEADER(9);
forwardInvHEADER(10);
forwardInvHEADER(11);
forwardInvHEADER(12);

void __ac_forwardInvocation(id self, SEL _cmd, NSInvocation * anInvocation, int depth);
void __ac_nsobjects_forwardInvocation(id self, NSInvocation * anInvocation);

#define methodSigHEADER(i) \
    - (NSMethodSignature *)methodSignatureForSelector##i:(SEL)aSelector \

methodSigHEADER(0);
methodSigHEADER(1);
methodSigHEADER(2);
methodSigHEADER(3);
methodSigHEADER(4);
methodSigHEADER(5);
methodSigHEADER(6);
methodSigHEADER(7);
methodSigHEADER(8);
methodSigHEADER(9);
methodSigHEADER(10);
methodSigHEADER(11);
methodSigHEADER(12);

NSMethodSignature* __ac_methodSignatureForSelector(id self, SEL _cmd, SEL aSelector, int depth);
NSMethodSignature* __ac_nsobjects_methodSignatureForSelector(id self, SEL aSelector);

@end
