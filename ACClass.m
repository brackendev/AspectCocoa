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

#import "ACClass.h"
#import "ACMethodIterator.h"

@implementation ACClass


-(id)initWithClass:(Class)aClass{
    self = [super init];
    theClass = aClass;
    methods = [[[NSMutableArray alloc] init] retain];
    depth = -98;
    return self;
}

- (void)dealloc{
    [methods release];
    [super dealloc];
}

-(BOOL)isMetaClass{
    return theClass->isa == [NSObject class]->isa;
}

-(Class)getClass{
    return theClass;
}

-(NSString *)getClassName{
    return [self className];
}

-(NSString *)className{
    return [NSString stringWithFormat: @"%s",[self getClass]->name];
}

-(NSString *)description{
    return [NSString stringWithFormat: @"ACClass %@ %@", [self className], [self getMethods]];
}

-(NSEnumerator *)methodEnumerator{
    return [[self allPossibleMethods] objectEnumerator];
}

-(NSMutableArray *)getMethods{
    return methods;
}

-(NSMutableArray *)allPossibleMethods{
    NSMutableArray * toReturn = [NSMutableArray new];
    ACMethodIterator * iterator = [[ACMethodIterator alloc] initWithClass: [self getClass]];
    while([iterator thereIsAnotherMethod]){
        struct objc_method * method = [iterator nextMethod];
	[toReturn addObject: [[ACMethod alloc] initWithMethod: method andClass: [self getClass]]];
    }
    return toReturn;
}

-(void)addMethod:(ACMethod*)method{
    [methods addObject: method];
}

//calculates and then caches the depth of inheritance
//of the wrapper class
-(int)depthOfInheritance{
    if( depth == -98 ){
        //calculate depth
        depth = [ACClass depthOfInheritance: theClass];
    }
    return depth;
}

+(int)depthOfInheritance:(Class) c{
    int dep = 0;
    while(c->super_class !=  NULL){
	c = c->super_class;
	dep++;
    }
    return dep;
}

@end
