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

#import "ACMethodScope.h"
#import "ACMethodIterator.h"
#import </usr/include/objc/objc-class.h>

//this is where we might specify that we want to wrap methods that exist in a superclass of the one with an Aspect
@implementation ACMethodScope

- (id)initDefault
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

//right now this is returning ALL methods except for those that start with _
-(NSMutableArray *)methodsOnClass:(ACClass *)aClass{
//    NSLog(@"getting allMethods on %s", [aClass getClass]->name);
    NSMutableArray * toReturn = [NSMutableArray new];
    ACMethodIterator * iterator = [[ACMethodIterator alloc] initWithClass: [aClass getClass]];
    while([iterator thereIsAnotherMethod]){
        struct objc_method * method = [iterator nextMethod];
//        NSLog(@"%s", method->method_name);
//        NSString * methodName = [[NSString alloc] initWithCString: (char *)method->method_name];
//        NSLog(methodName);
//            if( [methodName hasPrefix: @"_"]){ 
                //then don't add it
                //NSLog(@"ignoring method named %@", methodName);
//            }else{
                //NSLog(@"adding method named %@", methodName);
                [toReturn addObject: [[ACMethod alloc] initWithMethod: method]];
//            }
    }
//    NSLog(@"returning methods");
    return toReturn;
}

@end
