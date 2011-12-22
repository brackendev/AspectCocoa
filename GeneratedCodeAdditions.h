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

#import <AspectCocoa/ACGeneratedCode.h>

//@class ACGeneratedCode;

@interface ACGeneratedCode (GeneratedCodeAdditions)

/*begin defines one replacement IMP replacObject */

#define HEADERreplacObject(i) \
- (id)replacObject##i

HEADERreplacObject(0);  //SEL is replacObject0
HEADERreplacObject(1);
HEADERreplacObject(2);
HEADERreplacObject(3);
HEADERreplacObject(4);
HEADERreplacObject(5);
HEADERreplacObject(6);
HEADERreplacObject(7);
HEADERreplacObject(8);
HEADERreplacObject(9);
HEADERreplacObject(10);
HEADERreplacObject(11);
HEADERreplacObject(12);

#define MACROreplacObject(i) \
    - (id)replacObject##i \
    { \
        return replacObject(self, _cmd, i); \
    } \

/*end defines one replacement IMP replacObject */


/*begin defines one replacement IMP replacObjectObject */

#define HEADERreplacObjectObject(i) \
- (id)replacObject ## i ## Object:(id)a

HEADERreplacObjectObject(0);
HEADERreplacObjectObject(1);
HEADERreplacObjectObject(2);
HEADERreplacObjectObject(3);
HEADERreplacObjectObject(4);
HEADERreplacObjectObject(5);
HEADERreplacObjectObject(6);
HEADERreplacObjectObject(7);
HEADERreplacObjectObject(8);
HEADERreplacObjectObject(9);
HEADERreplacObjectObject(10);
HEADERreplacObjectObject(11);
HEADERreplacObjectObject(12);

#define MACROreplacObjectObject(i) \
    - (id)replacObject ## i ## Object:(id)a \
    { \
        return replacObjectObject(self, _cmd, i, a); \
    } \

/*end defines one replacement IMP replacObject */

@end

@interface ACInvocation (GeneratedCodeAdditions)

/*begin defines one replacement IMP replacObject */

-(void)replacObject;

/*end defines one replacement IMP replacObject */

-(void)replacObjectObject;

@end
