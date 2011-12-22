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

#import "GeneratedCodeAdditions.h"

@implementation ACGeneratedCode (GeneratedCodeAdditions)

//variablity is in:
// the number of arguments
// the return type
// the type of the arguments
// the depth of the class

/*begin defines one replacement IMP replacObject */

id replacObject(id self, SEL _cmd, int depth){
    ACInvocation * invoker = makeInvoker(self, _cmd, depth, @selector(replacObject));
    [invoker performAdvice];
    id returnVal = (id)malloc(sizeof(id));
    [[invoker inv] getReturnValue: &returnVal];
    [invoker cleanup];
    return returnVal;
}


MACROreplacObject(0)  //SEL is replacObject0
MACROreplacObject(1)
MACROreplacObject(2)
MACROreplacObject(3)
MACROreplacObject(4)
MACROreplacObject(5)
MACROreplacObject(6)
MACROreplacObject(7)
MACROreplacObject(8)
MACROreplacObject(9)
MACROreplacObject(10)
MACROreplacObject(11)
MACROreplacObject(12)

/*end defines one replacement IMP replacObject */


/*begin defines one replacement IMP replacObjectObject */

id replacObjectObject(id self, SEL _cmd, int depth, id a){
    ACInvocation * invoker = makeInvoker(self, _cmd, depth, @selector(replacObjectObject));
    [[invoker inv] setArgument: &a atIndex: 2];
    [invoker performAdvice];
    id returnVal = (id)malloc(sizeof(id));
    [[invoker inv] getReturnValue: &returnVal];
    [invoker cleanup];
    return returnVal;
}

MACROreplacObjectObject(0)
MACROreplacObjectObject(1)
MACROreplacObjectObject(2)
MACROreplacObjectObject(3)
MACROreplacObjectObject(4)
MACROreplacObjectObject(5)
MACROreplacObjectObject(6)
MACROreplacObjectObject(7)
MACROreplacObjectObject(8)
MACROreplacObjectObject(9)
MACROreplacObjectObject(10)
MACROreplacObjectObject(11)
MACROreplacObjectObject(12)

/*end defines one replacement IMP replacObjectObject */
@end


@implementation ACInvocation (GeneratedCodeAdditions)

//variablity is in:
// the number of arguments
// the return type
// the type of the arguments

/*begin defines one replacement IMP replacObject */

-(void)replacObject{
    id (*toInvoke)(id, SEL, ...);
    toInvoke = (id (*)(id, SEL, ...))[advice getIMP];
    id myReturn = toInvoke(object, selector);
    [invStorage setReturnValue: &myReturn];
}

/*end defines one replacement IMP replacObject */

/*begin defines one replacement IMP replacObjectObject */

-(void)replacObjectObject{
    id (*toInvoke)(id, SEL, ...);
    toInvoke = (id (*)(id, SEL, ...))[advice getIMP];
    id a = (id)malloc(sizeof(id));
    [invStorage getArgument: &a atIndex: 2];
    id myReturn = toInvoke(object, selector, a);
    [invStorage setReturnValue: &myReturn];
}

/*end defines one replacement IMP replacObjectObject */

@end

