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

#import "ACMethod.h"
#import "ACAspectManager.h"
#import </usr/include/objc/objc-class.h>

/*
ACMethod needs to provide methods to the user that will provide 
the real or "original" selector and other information 
so that users will not access it directly
_ac_hiding_2_test should be reported as simply test
as it may be already wrapped, but should be reported as if it is not
*/

@implementation ACMethod

-(id) initWithMethod:(struct objc_method *)aMethod{
    self = [super init];
    method = aMethod;
    theClass = NULL;
    return self;
}

-(id) initWithMethod:(struct objc_method *)aMethod andClass:(Class)c{
    self = [super init];
    method = aMethod;
    theClass = c;
    return self;
}

-(struct objc_method *) getMethod{
    return method;
}

-(Class) getClass{
    return theClass;
}

-(NSMethodSignature *)getSignature{
    if(theClass == NULL)
	return nil;
    id (*getSignature)(id, SEL, SEL);
    getSignature = (id (*)(id, SEL, SEL))[NSObject methodForSelector: @selector(instanceMethodSignatureForSelector:)];
    return getSignature(theClass, @selector(instanceMethodSignatureForSelector:), method->method_name);
}

-(NSString *)getMethodName{
    return [NSString stringWithCString: (char *)method->method_name];
}

-(NSString *)methodName{
    NSString * stringForSelector = [self getMethodName];
    if([stringForSelector hasPrefix: @"__ac_hiding_"]){
	NSString * firstSubstring = [stringForSelector substringFromIndex: 12];
        NSString * nextSubstring = [firstSubstring substringFromIndex: [firstSubstring rangeOfString: @"_"].location+1];
	return nextSubstring;
    }
    return stringForSelector;
}

-(NSString *)description{
    return [NSString stringWithFormat: @"ACMethod %s", method->method_name];
}

@end
