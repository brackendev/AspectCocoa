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

#import <AspectCocoa/ACMethod.h>
#import <Foundation/Foundation.h>
#import </usr/include/objc/objc-class.h>

@interface ACClass : NSObject {
    Class theClass;
    NSMutableArray * methods;
    int depth;
}

/* 
    Initializes this ACClass object with some Class

    Note that an ACClass object when used to define pointcuts will apply only to that method
    In Objective-C class methods and instance methods are actually stored in two seperate classes
    By default, a class and it's meta class have the same name.

    So, an ACClass object created from [NSObject class] won't include class methods, such as alloc
    such methods are accessable only via [NSObject class]->isa
    
    [[ACClass alloc] initWithClass: [NSObject class]];
    [[ACClass alloc] initWithClass: [NSObject class]->isa];

*/
-(id)initWithClass:(Class)aClass;

/* 
    Returns whether or not this class is a meta class.
*/
-(BOOL)isMetaClass;

/* 
    Returns the Class wrapped by this ACClass
*/
-(Class)getClass;

/* 
    Returns an NSString representation of the class name
*/
-(NSString *)getClassName;

/* 
    Returns an NSEnumerator of ACMethod objects.
    For enumerating through all methods on the class (not it's meta class).
*/
-(NSEnumerator *)methodEnumerator;


/* 
    Returns an array of ACMethod objects for all methods in the wrapped Class
*/
-(NSMutableArray *)allPossibleMethods;

/* 
    Provides to the Aspect an array of ACMethod objects defining all methods that should be advised
*/
-(NSMutableArray *)getMethods;

/* 
    Add an ACMethod object to the list of methods provided to the aspect for advising.
*/
-(void)addMethod:(ACMethod*)method;

/*
*
*  Private Methods
*  these are either methods you shouldn't call at all
*  or methods that will eventually be made public, but aren't ready yet
*  so their actual functionality may change...
*
*/
-(int)depthOfInheritance;
+(int)depthOfInheritance:(Class) c;

@end
