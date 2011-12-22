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

#import "ACPointCut.h"
#import </usr/include/objc/objc-class.h>
#import </usr/include/objc/objc-runtime.h>

@implementation ACPointCut

+(NSEnumerator *)enumerateAllClasses{
    return [[[[ACClassScope alloc] initWithEverything] allClasses] objectEnumerator];
}

+(NSEnumerator *)enumerateDefaultClasses{
    return [[[[ACClassScope alloc] initDefault] allClasses] objectEnumerator];
}

+(NSEnumerator *)enumerateClassesNamed:(NSString *)first, ...{
    ACClassScope * scope = [[ACClassScope alloc] init];
    NSString * nextClass = first;
    va_list ap;
    va_start(ap,first);
    while(nextClass != nil){
	[scope addClass: objc_getClass([nextClass cString])->isa];
	[scope addClass: objc_getClass([nextClass cString])];
	nextClass = va_arg(ap,id);
    }
    va_end(ap);
    return [[scope allClasses] objectEnumerator];
}

+(ACPointCut *)pointCutWithJoinPoints:(NSArray *)joinPoints{
    return [[ACPointCut alloc] initWithJoinPoints: joinPoints];
}

+(ACPointCut *)pointCutForClasses:(NSArray *)classes andMethods: (NSArray *)methods{
    ACPointCut * pointCut = [[ACPointCut alloc] init];
    [[pointCut getClassFilter] filterAllClasses];
    NSEnumerator *classEnumerator = [classes objectEnumerator];
    NSString * nextClass;
    while (nextClass = [classEnumerator nextObject]) {
	[[pointCut getClassFilter] allowClassesNamed: nextClass];
    }
    [[pointCut getMethodFilter] filterAllMethods];
    NSEnumerator *methodEnumerator = [methods objectEnumerator];
    NSString * nextMethod;
    while (nextMethod = [methodEnumerator nextObject]) {
	[[pointCut getMethodFilter] allowMethodsNamed: nextMethod];
    }
    return pointCut;
}

+(ACPointCut *)pointCutForClass:(NSString *)className adviseClassMethods:  (NSString *)first, ... {
    ACPointCut * pointCut = [[ACPointCut alloc] init];
    [pointCut setClassScope: [[ACClassScope alloc] init]];
    [[pointCut getClassScope] addClass: objc_getClass([className cString])->isa];
    [[pointCut getMethodFilter] filterAllMethods];
    NSString * nextMethod = first;
    va_list ap;
    va_start(ap,first);
    while([nextMethod hasSuffix: @"&"]){
	[[pointCut getMethodFilter] allowMethodsNamed: [nextMethod substringToIndex: [nextMethod length] - 1]];
	nextMethod = va_arg(ap,id);
    }
    [[pointCut getMethodFilter] allowMethodsNamed: nextMethod];
    va_end(ap);
    return pointCut;
}

+(ACPointCut *)pointCutForClass:(NSString *)className adviseInstanceMethods:  (NSString *)first, ... {
    ACPointCut * pointCut = [[ACPointCut alloc] init];
    [pointCut setClassScope: [[ACClassScope alloc] init]];
    [[pointCut getClassScope] addClass: objc_getClass([className cString])];
    [[pointCut getMethodFilter] filterAllMethods];
    NSString * nextMethod = first;
    va_list ap;
    va_start(ap,first);
    while([nextMethod hasSuffix: @"&"]){
	[[pointCut getMethodFilter] allowMethodsNamed: [nextMethod substringToIndex: [nextMethod length] - 1]];
	nextMethod = va_arg(ap,id);
    }
    [[pointCut getMethodFilter] allowMethodsNamed: nextMethod];
    va_end(ap);
    return pointCut;
}

+(ACPointCut *)pointCutForClass:(NSString *)className adviseMethods:  (NSString *)first, ... {
    NSArray * classList = [NSArray arrayWithObjects: className, nil];
    NSMutableArray * methodList = [NSMutableArray new];
    NSString * nextMethod = first;
    va_list ap;
    va_start(ap,first);
    while([nextMethod hasSuffix: @"&"]){
	[methodList addObject: [nextMethod substringToIndex: [nextMethod length] - 1]];
	nextMethod = va_arg(ap,id);
    }
    [methodList addObject: nextMethod];
    return [self pointCutForClasses: classList andMethods: methodList];
}

+(id)defaultPointCut{
    return [[self alloc] initDefault];
}

-(id)initWithJoinPoints:(NSArray *)joinPoints{
    self = [super init];
    if(self){
	cachedPointCut = [joinPoints retain];
    }
    return self;
}

-(id)init{
    return [self 
        initWithClassScope: [[ACClassScope alloc] initWithEverything] 
        classFilter: nil  
        methodScope: nil 
        methodFilter: nil];
}

-(id)initEmpty{
    return [self 
        initWithClassScope: [[ACClassScope alloc] init] 
        classFilter: nil  
        methodScope: nil 
        methodFilter: nil];
}

-(id)initDefault{
    return [self initWithClassScope: nil classFilter: nil  methodScope: nil methodFilter: nil];
}

-(id)initWithClassScope: (ACClassScope *)cscope 
            classFilter: (ACClassFilter *) cfilter 
            methodScope: (ACMethodScope *) mscope 
            methodFilter: (ACMethodFilter *) mfilter
{
    self = [super init];
    if (self){
        classScope = [cscope retain];
        if(classScope == nil){
            //all classes (not Aspect Cocoa)
            classScope = [[[ACClassScope alloc] initDefault] retain]; 
        }
    	classFilter = [cfilter retain];
        if(classFilter == nil){
            //filter out private classes ( _prefix)
            classFilter = [[[ACClassFilter alloc] initDefault] retain];
        }
    	methodScope = [mscope retain];
        if(methodScope == nil){
            //all methods on the class (not superclass)
            methodScope = [[[ACMethodScope alloc] initDefault] retain];
        }
    	methodFilter = [mfilter retain];
        if(methodFilter == nil){
            //filter out private methods ( _prefix)
            methodFilter = [[[ACMethodFilter alloc] initDefault] retain];
        }
	cachedPointCut = nil;
    }
    return self;
}

-(void)exceptionCheck{
    if(cachedPointCut != nil)
	[NSException raise: @"Point Cut already in use, it can no longer be modified" format: @""];
}

-(ACClassScope *) getClassScope{
    [self exceptionCheck];
    return classScope;
}
-(ACClassFilter *) getClassFilter{
    [self exceptionCheck];
    return classFilter;
}
-(ACMethodScope *) getMethodScope{
    [self exceptionCheck];
    return methodScope;
}
-(ACMethodFilter *) getMethodFilter{
    [self exceptionCheck];
    return methodFilter;
}

-(void)setClassScope:(ACClassScope *)newClassScope{
    [self exceptionCheck];
    if( classScope != newClassScope){
        [classScope release];
        classScope = [newClassScope retain];
    }
}
-(void)setClassFilter:(ACClassFilter *)newClassFilter{
    [self exceptionCheck];
    if( classFilter != newClassFilter){
        [classFilter release];
        classFilter = [newClassFilter retain];
    }
}
-(void)setMethodScope:(ACMethodScope *)newMethodScope{
    [self exceptionCheck];
    if( methodScope != newMethodScope){
        [methodScope release];
        methodScope = [newMethodScope retain];
    }
}
-(void)setMethodFilter:(ACMethodFilter *)newMethodFilter{
    [self exceptionCheck];
    if( methodFilter != newMethodFilter){
        [methodFilter release];
        methodFilter = [newMethodFilter retain];
    }
}

-(NSArray*)joinPoints{
    if(cachedPointCut == nil)
	cachedPointCut = [[self allClassesAndMethods] retain];
    return cachedPointCut;
}

//will return an array of class method pairs
-(NSArray*)allClassesAndMethods{
    int i, j;
    //get all the classes from the class scope
    NSMutableArray * classes = [classScope allClasses];
    //iterate through the methods returned by class scope and apply the filter
    for(i=0; i<[classes count]; i++){
        ACClass * ithClass = [classes objectAtIndex: i];
        if( [classFilter allowsClass: ithClass] ){
            //pass classes that get through the filter to the method scope
            NSMutableArray * methods = [methodScope methodsOnClass: ithClass];
            //iterate through the methods retuend by the method scope and apply the filter
            for(j=0; j<[methods count]; j++){
                ACMethod * ithMethod = [methods objectAtIndex: j];
                if( [methodFilter allowsMethod: ithMethod] ){
                    //add this method to the methods that need wrapping
                    [ithClass addMethod: ithMethod];
                }else{
                    [methods removeObjectAtIndex: j];
                    j--;
                }
            }
        }else{
            [classes removeObjectAtIndex: i];
            i--;
        }
    }
    //return the class/methods pairs
    return classes;
}

@end
