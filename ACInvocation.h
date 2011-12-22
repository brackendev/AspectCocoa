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
#import <AspectCocoa/ACAdviceList.h>

@interface ACInvocation : NSObject {
    ACAdviceList * advice;
    id object;
    SEL selector;
    SEL toUse;
    NSInvocation * invStorage;
    Class invClass;
    BOOL fromForward;
    BOOL invokedAlready;
    int invokingAround;
}

+(void)enableAllAdvice;
+(void)disableAllAdvice;

+(void)protectAdvice;
+(void)unprotectAdvice;

/*
    Returns the NSMethodSignature object describing the method to be invoked.
*/
- (NSMethodSignature *)methodSignature;

/*
    set/get the selector to be invoked on the target
*/
- (void)setSelector:(SEL)sel;
- (SEL)selector;

/*
    set/get the target of the invocation
*/
- (id)target;
- (void)setTarget:(id)obj;

/*
    returns the class containg the method for which this invocation was created
    note that this may or may not the same class as [[invocation target] class];
    which will always return the lowest level class of the object
*/
- (Class)getClass;

/*
    set/get the target of the invocation
*/
- (void)invoke;
- (void)invokeWithTarget:(id)target;

/*
    set/get the return value or argument values of the invocation
    same usage as on NSInvocation
*/
- (void)getReturnValue:(void *)retLoc;
- (void)setReturnValue:(void *)retLoc;
- (void)getArgument:(void *)argumentLocation atIndex:(int)index;
- (void)setArgument:(void *)argumentLocation atIndex:(int)index;

/*
*
*  Private Methods
*  these are either methods you shouldn't call at all
*  or methods that will eventually be made public, but aren't ready yet
*  so their actual functionality may change...
*
*/
- (NSInvocation *)inv;
- (id)initWithSignature:(NSMethodSignature *) sig;
- (id)initWithInvocation:(NSInvocation *) inv;
- (void)use:(SEL)use;
- (void)setAdvice:(ACAdviceList *)adv;
- (void)performAdvice;
- (void)cleanup;

- (NSString *)className;
- (void)setClass:(Class)c;

@end
