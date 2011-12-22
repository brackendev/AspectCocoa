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

#import "ACClassScope.h"
#import </usr/include/objc/objc-class.h>
#import </usr/include/objc/objc-runtime.h>
#import "ACAspectManager.h"

@implementation ACClassScope


- (id)init
{
    self = [super init];
    if (self) {
        classesInScope = [[NSMutableArray new] retain];
    }
    return self;
}

- (void)dealloc{
    [classesInScope release];
    [super dealloc];
}

- (id)initDefault
{
    [self init];
    [self addNonNSClasses];
    return self;
}

- (id)initWithEverything
{
    [self init];
    [self addNonACClasses];
    return self;
}

- (id)initWithClasses:(NSArray *)classes
{
    [self init];
    classesInScope = [[classes mutableCopy] retain];
    return self;
}

-(void)addClass:(Class)aClass{
    [classesInScope addObject: [[ACClass alloc] initWithClass: aClass]];
}

-(void)addClassAndMeta:(Class)aClass{
    [self addClass: aClass];
    [self addClass: aClass->isa];
}

-(NSArray *)allClasses{
    return classesInScope;
}

-(void)addNonACClasses{
    int numClasses;
    Class * classes = NULL;
    classes = NULL;
    numClasses = objc_getClassList(NULL, 0);
    if( numClasses > 0 ){
        classes = malloc( sizeof(Class) * numClasses );
        (void) objc_getClassList( classes, numClasses );
        int i;
        for( i=0; i<numClasses; i++){
            NSString * className = [[NSString alloc] initWithCString: classes[i]->name];
	    if([className hasPrefix: @"AC"]){
//            if( [className isEqualToString: @"NSObject"] || [className isEqualToString: @"NSString"] || [className isEqualToString: @"NSMethodSignature"]  || [className isEqualToString: @"Protocol"]  || [className hasPrefix: @"AC"] || [className hasPrefix: @"NSArray"] || [className hasPrefix: @"NSDictionary"] || [className hasPrefix: @"NSMutableArray"] || [className hasPrefix: @"NSMutableDictionary"] || [className hasPrefix: @"%NS"]  || [className isEqualToString: @"NSCFArray"] || [className isEqualToString: @"NSPlaceholderString"] || [className isEqualToString: @"NSPlaceholderMutableArray"] || [className isEqualToString: @"NSPlaceholderMutableDictionary"] || [className isEqualToString: @"NSConstantString"] || [className isEqualToString: @"NSPlaceholderArray"] || [className isEqualToString: @"NSUnarchiver"] || [className isEqualToString: @"NSUnarchiver"] || [className isEqualToString: @"NSUnarchiver"]  || [className isEqualToString: @"NSNibControlConnector"]){
                //then don't add it
            }else{
                //add the class and the meta class
                [self addClassAndMeta: classes[i]];
            }
        }
        free(classes);
    }
}

-(void)addNonNSClasses{
    int numClasses;
    Class * classes = NULL;
    classes = NULL;
    numClasses = objc_getClassList(NULL, 0);
    if([ACAspectManager loggingAll])
	NSLog(@"adding non NS classes %i", numClasses);
    if( numClasses > 0 ){
        classes = malloc( sizeof(Class) * numClasses );
        (void) objc_getClassList( classes, numClasses );
        int i;
        for( i=0; i<numClasses; i++){
	    if(classes[i] == NULL){
		break;
	    }
            NSString * className = [[NSString alloc] initWithCString: classes[i]->name];
	    //if([ACAspectManager loggingAll])
		//NSLog(@"checking class %@", className);
            if( [className hasPrefix: @"_"] || [className hasPrefix: @"AC"] || [className hasPrefix: @"NS"] || [className hasPrefix: @"NX"]  || [className hasPrefix: @"%NS"] || [className isEqualToString: @"Object"] || [className isEqualToString: @"Protocol"] || [className isEqualToString: @"List"] || [className isEqualToString: @"WebHTTPPersistentConnection"] ){
                //then don't add it
            }else{
                //add the class and the meta class
                [self addClassAndMeta: classes[i]];
            }
        }
        free(classes);
    }
    //if([ACAspectManager loggingAll])
	//NSLog(@"done adding non NS classes");
}

-(void)printClassList{
    NSLog(@"class list");
    int j=0;
    int numClasses;
    Class * classes = NULL;

    classes = NULL;
    numClasses = objc_getClassList(NULL, 0);

    if( numClasses > 0 ){
        classes = malloc( sizeof(Class) * numClasses );
        (void) objc_getClassList( classes, numClasses );
        int i;
        for( i=0; i<numClasses; i++){
            NSLog(@"%s", classes[i]->name);
            if( ![[NSString stringWithFormat: @"%s", classes[i]->name] hasPrefix: @"AC"])
                j++;
        }
        free(classes);
    }
    
    NSLog(@"found %i total classes", j);
}


                /*
                NSLog(@"class %s", classes[i]->name);
                NSLog(@"metaclass %s", classes[i]->isa->name);
                NSLog(@"meta metaclass %s", classes[i]->isa->isa->name);
                NSLog(@"meta meta metaclass %s", classes[i]->isa->isa->isa->name);
                NSLog(@"meta meta meta metaclass %s", classes[i]->isa->isa->isa->isa->name);
                NSLog(@"meta meta meta meta metaclass %s", classes[i]->isa->isa->isa->isa->isa->name);

                NSLog(@"class %i", classes[i]->info);
                NSLog(@"metaclass %i", classes[i]->isa->info);
                NSLog(@"meta metaclass %i", classes[i]->isa->isa->info);
                NSLog(@"meta meta metaclass %i", classes[i]->isa->isa->isa->info);
                NSLog(@"meta meta meta metaclass %i", classes[i]->isa->isa->isa->isa->info);
                NSLog(@"meta meta meta meta metaclass %i", classes[i]->isa->isa->isa->isa->isa->info);

                NSLog(@"class %i", classes[i]->instance_size);
                NSLog(@"metaclass %i", classes[i]->isa->instance_size);
                NSLog(@"meta metaclass %i", classes[i]->isa->isa->instance_size);
                NSLog(@"meta meta metaclass %i", classes[i]->isa->isa->isa->instance_size);
                NSLog(@"meta meta meta metaclass %i", classes[i]->isa->isa->isa->isa->instance_size);
                NSLog(@"meta meta meta meta metaclass %i", classes[i]->isa->isa->isa->isa->isa->instance_size);
                */
                
                            //if( [className isEqualToString: @"NSObject"] || [className isEqualToString: @"NSString"] || [className isEqualToString: @"NSMethodSignature"]  || [className isEqualToString: @"Protocol"]  || [className hasPrefix: @"AC"] || [className hasPrefix: @"NSArray"] || [className hasPrefix: @"NSDictionary"] || [className hasPrefix: @"NSMutableArray"] || [className hasPrefix: @"NSMutableDictionary"] || [className hasPrefix: @"%NS"]  || [className isEqualToString: @"NSCFArray"] || [className isEqualToString: @"NSPlaceholderString"] || [className isEqualToString: @"NSPlaceholderMutableArray"] || [className isEqualToString: @"NSPlaceholderMutableDictionary"] || [className isEqualToString: @"NSConstantString"] || [className isEqualToString: @"NSPlaceholderArray"] || [className isEqualToString: @"NSUnarchiver"] || [className isEqualToString: @"NSUnarchiver"] || [className isEqualToString: @"NSUnarchiver"]  || [className isEqualToString: @"NSNibControlConnector"]){

@end
