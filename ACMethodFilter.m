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

#import "ACMethodFilter.h"
#import </usr/include/objc/objc-class.h>

@implementation ACMethodFilter

- (id)init
{
    self = [super init];
    if (self) {
        filterList = [[NSMutableArray new] retain];
        allowList = [[NSMutableArray new] retain];
        filterPrefixList = [[NSMutableArray new] retain];
        allowPrefixList = [[NSMutableArray new] retain];
        [self filterAllMethods];
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

- (id)initDefault
{
    [self init];
    [self allowAllMethods];
    [self filterMethodsNamed: @"alloc"];
    [self filterMethodsNamed: @"dealloc"];
    [self filterMethodsNamed: @"release"];
    return self;
}

-(void)filterMethodsNamed:(NSString*)methodName{
    [filterList addObject: methodName];
}

-(void)filterMethodsWithPrefix:(NSString*)methodName{
    [filterPrefixList addObject: methodName];
}

-(void)filterAllMethods{
    filterMode = NO;
}

-(void)allowMethodsNamed:(NSString*)methodName{
    [allowList addObject: methodName];
}

-(void)allowMethodsWithPrefix:(NSString*)methodName{
    [allowPrefixList addObject: methodName];
}

-(void)allowAllMethods{
    filterMode = YES;
}

//this is the method called repeatedly by the Aspect when determining which methods to wrap
-(BOOL)allowsMethod:(ACMethod*)aMethod{
    struct objc_method * method = [aMethod getMethod];
    NSString * methodName = [[NSString alloc] initWithCString: (char *)method->method_name];
    int i;
    if( filterMode ){
        for(i=0; i<[filterList count]; i++){
            NSString * ith = [filterList objectAtIndex: i];
            if( [methodName isEqualToString: ith])
                return NO;
        }
        for(i=0; i<[filterPrefixList count]; i++){
            NSString * ith = [filterPrefixList objectAtIndex: i];
            if( [methodName hasPrefix: ith])
                return NO;
        }
        return YES;
    }else{
        for(i=0; i<[allowList count]; i++){
            NSString * ith = [allowList objectAtIndex: i];
            if( [methodName isEqualToString: ith])
                return YES;
        }
        for(i=0; i<[allowPrefixList count]; i++){
            NSString * ith = [allowPrefixList objectAtIndex: i];
            if( [methodName hasPrefix: ith])
                return YES;
        }
        return NO;
    }
}

@end
