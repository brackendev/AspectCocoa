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


#import "ACAdviceList.h"
#import "ACIMP.h"

@implementation ACAdviceList

-(id)initWithIMP:(IMP)i signature:(NSMethodSignature*)sig selector:(SEL)sele{
    self = [super init];
    if (self) {
        imp = i;
        signature = [sig retain];
        selector = sele;
        advice = [[NSMutableArray new] retain];
    }
    return self;
}

- (void)dealloc{
    [signature release];
    [advice release];
    [super dealloc];
}

-(id)objectAtIndex:(int)i{
    return [advice objectAtIndex: i];
}

-(void)addAdviceObject:(id)object{
    [advice addObject: object];
}

-(void)removeAdviceObject:(id)object{
    [advice removeObject: object];
}

-(int)count{
    return [advice count];
}

-(NSMethodSignature *)getSig{
    return signature;
}

-(IMP)getIMP{
    return imp;
}


/*
-(void)performAdvice:(ACInvocation *)inv{
    //befores
    int i;
    for(i=0; i<[advice count]; i++){
        id adviceObject = [advice objectAtIndex: i];
        if([adviceObject respondsToSelector: @selector(before:)] )
            [adviceObject before: inv];
    }
    //arounds
    [inv invoke];
    //afters
    for(i=0; i<[advice count]; i++){
        id adviceObject = [advice objectAtIndex: i];
        if([adviceObject respondsToSelector: @selector(after:)] ){
            [adviceObject after: inv];
        }
    }
    //this line is necessary, but for no apparent reason..
    //the weridest bug I have ever seen
    //NSLog(@" ");
}
*/

@end
