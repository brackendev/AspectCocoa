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

#import "ACMethodIterator.h"

@implementation ACMethodIterator

-(id) initWithClass: (Class) aclass{
    self = [super init];
    if (self) {
        theClass = aclass;
        iterator = 0;
        i = 0;
        methodList = class_nextMethodList(theClass, &iterator);
        if( methodList == NULL ){
            anotherMethod = NO;
            count = 0;
        }else if( &methodList->method_list[0] == NULL ){
            anotherMethod = NO;
            count = 0;
        }else{
            anotherMethod = YES;
            count = methodList->method_count;
        }
    }
    return self;
}

+(void)listMethods:(Class)aclass{
    ACMethodIterator * m = [[ACMethodIterator alloc] initWithClass: aclass];
    struct objc_method * method = [m nextMethod];
    while(method != NULL){
        NSLog(@"%s", method->method_name);
        method = [m nextMethod];
    }
}

+(Method)findMethod:(SEL)selector onClass:(Class)aclass{
    ACMethodIterator * m = [[ACMethodIterator alloc] initWithClass: aclass];
    struct objc_method * method = [m nextMethod];
    while(method != NULL){
        if(selector == method->method_name){
            return method;
        }
        method = [m nextMethod];
    }
    return NULL;
}
/*
+(struct objc_method_list *)findListContainingMethod:(SEL)selector onClass:(Class)aclass{
    ACMethodIterator * m = [[ACMethodIterator alloc] initWithClass: aclass];
    struct objc_method * method = [m nextMethod];
    while(method != NULL){
        if(selector == method->method_name){
            return currentMethodList;
        }
        method = [m nextMethod];
    }
    return NULL;
}
*/

-(BOOL)thereIsAnotherMethod{
    return anotherMethod;
}

-(struct objc_method *)nextMethod{
    if( !anotherMethod){
        return NULL;
    }
    struct objc_method * toReturn = &methodList->method_list[i];
    currentMethodList = methodList;
    i++;
    if(i >= count){
        i = 0;
        methodList = class_nextMethodList(theClass, &iterator);
        if( methodList == NULL ){
            anotherMethod = NO;
        }else if( &methodList->method_list[0] == NULL ){
            anotherMethod = NO;
        }else{
            anotherMethod = YES;
            count = methodList->method_count;
        }
    }
    return toReturn;
}

@end
