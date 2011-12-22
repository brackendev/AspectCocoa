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

#import "ACClassFilter.h"
#import </usr/include/objc/objc-class.h>

@implementation ACClassFilter

- (id)initDefault
{
    self = [super init];
    if (self) {
        filterList = [[NSMutableArray new] retain];
        allowList = [[NSMutableArray new] retain];
        filterPrefixList = [[NSMutableArray new] retain];
        allowPrefixList = [[NSMutableArray new] retain];
        [self allowAllClasses];
    }
    return self;
}

- (void)dealloc{
    [filterList release];
    [allowList release];
    [filterPrefixList release];
    [allowPrefixList release];
    [super dealloc];
}

-(BOOL)allowsClass:(ACClass *)aClass{
    int i;
    if(filterMode){ //means we are allowing all, and filtering out those that are in the filter list
        for(i=0; i<[filterList count]; i++){
            NSString * ith = [filterList objectAtIndex: i];
            if([[aClass getClassName] isEqualToString: ith])
                return NO;
        }
        for(i=0; i<[filterPrefixList count]; i++){
            NSString * ith = [filterPrefixList objectAtIndex: i];
            if([[aClass getClassName] hasPrefix: ith])
                return NO;
        }
        return YES;
    }else{//we are filtering all, and checking the allow lists
        for(i=0; i<[allowList count]; i++){
            NSString * ith = [allowList objectAtIndex: i];
            if([[aClass getClassName] isEqualToString: ith])
                return YES;
        }
        for(i=0; i<[allowPrefixList count]; i++){
            NSString * ith = [allowPrefixList objectAtIndex: i];
            if([[aClass getClassName] hasPrefix: ith])
                return YES;
        }
        return NO;
    }
}

-(void)filterClassesNamed:(NSString*)methodName{
    [filterList addObject: methodName];
}

-(void)filterClassesWithPrefix:(NSString*)methodName{
    [filterPrefixList addObject: methodName];
}

-(void)filterAllClasses{
    filterMode = NO;
}

-(void)allowClassesNamed:(NSString*)methodName{
    [allowList addObject: methodName];
}

-(void)allowClassesWithPrefix:(NSString*)methodName{
    [allowPrefixList addObject: methodName];
}

-(void)allowAllClasses{
    filterMode = YES;
}

@end
