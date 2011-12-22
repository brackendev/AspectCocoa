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
#import <AspectCocoa/ACInvocation.h>

@interface ACGeneratedCode : NSObject {

}

#define HEADERdepth(i) \
- (int)depth##i;

HEADERdepth(0)
HEADERdepth(1)
HEADERdepth(2)
HEADERdepth(3)
HEADERdepth(4)
HEADERdepth(5)
HEADERdepth(6)
HEADERdepth(7)
HEADERdepth(8)
HEADERdepth(9)
HEADERdepth(10)
HEADERdepth(11)
HEADERdepth(12)

#define depth(i) \
    - (int)depth##i \
    { \
        return i; \
    } \

ACInvocation * makeInvoker(id self, SEL _cmd, int depth, SEL toUse);
void useInvoker(ACInvocation * invoker);
Class resolveClass(id object, int md);

@end
