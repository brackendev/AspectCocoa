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
#import "ACAspectManager.h"
#import "ACAdviceList.h"
#import "NSObjectExtensions.h"
#import </usr/include/objc/objc-class.h>

@implementation ACGeneratedCode

depth(0)
depth(1)
depth(2)
depth(3)
depth(4)
depth(5)
depth(6)
depth(7)
depth(8)
depth(9)
depth(10)
depth(11)
depth(12)

//void useInvoker(ACInvocation * invoker){
//    [invoker performAdvice];
//    return [invoker returnValue]; //toReturn = *(id *)[invoker returnValue];
//}

ACInvocation * makeInvoker(id self, SEL _cmd, int depth, SEL toUse){
    Class toLookup = resolveClass(self, depth);
    ACAdviceList * advice = [[ACAspectManager sharedManager] 
                                adviceListForSelector: _cmd 
                                onClass: toLookup];
    if(advice == nil){ NSLog(@"!! error this should never happen! advice list was nil %s %s", _cmd, self->isa->name); }
    ACInvocation * invoker = [[ACInvocation alloc] initWithSignature: [advice getSig]];
    [invoker setClass: toLookup];
    [invoker setSelector: _cmd];
    [invoker setTarget: self];
    [invoker setAdvice: advice];
    [invoker use: toUse];
    return invoker;
}

Class resolveClass(id object, int md){
    Class toLookup = object->isa;
//    if( toLookup->isa == [NSObject class]->isa )
//        NSLog(@"equal");


    int od = [object __ac_depth];
    while(md < od){
        md ++;
        toLookup = toLookup->super_class;
    }

//    if( toLookup->isa == [NSObject class]->isa )
//        NSLog(@"still equal");


    return toLookup;
}

@end
