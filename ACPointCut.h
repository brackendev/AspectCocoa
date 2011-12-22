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

#import <AspectCocoa/ACClassScope.h>
#import <AspectCocoa/ACClassFilter.h>
#import <AspectCocoa/ACMethodScope.h>
#import <AspectCocoa/ACMethodFilter.h>
#import <Foundation/Foundation.h>

@interface ACPointCut : NSObject {
    ACClassScope * classScope;
    ACClassFilter * classFilter;
    ACMethodScope * methodScope;
    ACMethodFilter * methodFilter;
    NSArray * cachedPointCut;
}

/* 
    Returns an NSEnumerator of ACClass objects.
    For enumerating through all classes, the same as init
*/
+(NSEnumerator *)enumerateAllClasses;

/* 
    Returns an NSEnumerator of ACClass objects.
    For enumerating through all classes, the same as initDefault
*/
+(NSEnumerator *)enumerateDefaultClasses;

/* 
    Returns an NSEnumerator of ACClass objects.
    For enumerating through all classes as named by the arguments.
    Expects nil for it's last argument.
*/
+(NSEnumerator *)enumerateClassesNamed:(NSString *)first, ... ;

/* 
    Returns a point cut object as defined by the passed array
    which is assumed to be an array of ACClass objects (each containing some number of ACMethod) objects
*/
+(ACPointCut *)pointCutWithJoinPoints:(NSArray *)joinPoints;

/* 
    Returns a point cut object for 
	-all classes as named by NSString objects in the 'classes' array
	-all methods belonging to such classes, as named by the NSString objects in the 'methods' array
*/
+(ACPointCut *)pointCutForClasses:(NSArray *)classes andMethods: (NSArray *)methods;

+(id)defaultPointCut;

/* 
    Returns a point cut object for all methods on all classes in the runtime, 
    except for those prefixed with AC and core foundation bridged classes.
*/
-(id)init;

/* 
    Returns a point cut object for all methods on all classes in the runtime
    except for anything in Foundation, Appkit, or Aspect Cocoa. (as defined by a prefix of NS %NS _NS etc...)
    This typically implies all user defined classes.
*/
-(id)initDefault;

/* 
    Returns a point cut object for all classes in the runtime, 
    except for those prefixed with AC and core foundation bridged classes.
*/
-(id)initWithJoinPoints:(NSArray *)joinPoints;

/*
*
*  Private Methods
*  these are either methods you shouldn't call at all
*  or methods that will eventually be made public, but aren't ready yet
*  so their actual functionality may change...
*
*/
+(ACPointCut *)pointCutForClass:(NSString *)className adviseClassMethods:  (NSString *)first, ... ;
+(ACPointCut *)pointCutForClass:(NSString *)className adviseInstanceMethods:  (NSString *)first, ... ;
+(ACPointCut *)pointCutForClass:(NSString *)className adviseMethods:  (NSString *)first, ... ;

-(id)initEmpty;
-(id)initWithClassScope: (ACClassScope *)cscope 
            classFilter: (ACClassFilter *) cfilter 
            methodScope: (ACMethodScope *) mscope 
            methodFilter: (ACMethodFilter *) mfilter;

-(ACClassScope *) getClassScope;
-(ACClassFilter *) getClassFilter;
-(ACMethodScope *) getMethodScope;
-(ACMethodFilter *) getMethodFilter;

-(void)setClassScope:(ACClassScope *)newClassScope;
-(void)setClassFilter:(ACClassFilter *)newClassFilter;
-(void)setMethodScope:(ACMethodScope *)newMethodScope;
-(void)setMethodFilter:(ACMethodFilter *)newMethodFilter;

-(NSArray*)joinPoints;
-(NSArray*)allClassesAndMethods;

@end