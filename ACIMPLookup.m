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

#import "ACIMPLookup.h"
#import </usr/include/objc/objc-class.h>

@implementation ACIMPLookup

- (id)init{
    self = [super init];
    if (self){
        lookup = [[NSMutableDictionary new] retain];
    }
    return self;
}

- (void)dealloc{
    [lookup release];
    [super dealloc];
}

-(NSString *)keyForClass:(Class)class{
    if( class->isa == [NSObject class]->isa ){
        return [NSString stringWithFormat: @"%s meta class", class->name];
        //this is a safe way to do it because class names cannot/shouldnot have spaces
    }else{
        return [[NSString alloc] initWithCString: class->name];
    }
}

-(void)saveIMP: (IMP)imp forClass: (Class) class{
    [lookup setObject: [ACIMP allocWithIMP: imp] forKey: [self keyForClass: class]];
}

-(ACIMP *)getIMPforClass: (Class) class{
    return [lookup objectForKey: [self keyForClass: class]];
}

@end
