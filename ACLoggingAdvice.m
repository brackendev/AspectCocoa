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

#import "ACLoggingAdvice.h"
#import </usr/include/objc/objc-class.h>

@implementation ACLoggingAdvice

- (id)init{
    self = [super init];
    if (self){
        indent = [@"" retain];
    }
    return self;
}

- (void)dealloc{
    [indent release];
    [super dealloc];
}

-(void)before:(ACInvocation *)invocation{
    NSLog(@"%@before %s on %s",indent, [invocation selector], [invocation getClass]->name);
    NSString * newIndent = [NSString stringWithFormat: @"-%@",indent];
    [indent release];
    indent = [newIndent retain];

}

-(void)after:(ACInvocation  *)invocation{
    NSString * newIndent = [indent substringFromIndex: 1];
    [indent release];
    indent = [newIndent retain];
    NSLog(@"%@after %s on %s",indent, [invocation selector], [invocation getClass]->name);
}

@end

//-(void)error:(int) i, ...{
//    return;
//}

//    [[NSExceptionHandler defaultExceptionHandler] setExceptionHandlingMask:NSLogAndHandleEveryExceptionMask];
/*
    SEL selector = @selector(initWithDecimal:);
    id (*getSignarure)(id, SEL, SEL);
    getSignarure = (id (*)(id, SEL, SEL))[NSObject methodForSelector:@selector(instanceMethodSignatureForSelector:)];
    NSMethodSignature * signature;
    NS_DURING
        NSLog(@"this should be an error");
        signature =  getSignarure(objc_getClass("NSDecimalNumberPlaceholder")->isa, @selector(instanceMethodSignatureForSelector:), selector);
        NSLog(@"this should be an error, it's not");
    NS_HANDLER
        NSLog(@"userinfo is %@",[localException userInfo]);
    NS_ENDHANDLER
    NS_DURING
        [NSException raise: @"hi" format: @""];
        NSLog(@"exception raised");
        //NSLog(@"this should be an error %@", [objc_getClass("NSDecimalNumberPlaceholder") performSelector: @selector(methodSignatureForSelector:) withObject: @selector(initWithDecimal:)]);
    NS_HANDLER
        NSLog(@"userinfo is %@",[localException userInfo]);
    NS_ENDHANDLER
//    NSLog(@"%@",[[[NSException new] userInfo] objectForKey: NSStackTraceKey]);
*/

/*
-(void)before:(SEL)s object:(id)o{
    //we can't print out the object directly because we might have an aspect on selector: description
    //so perhaps we should have a way..
    //to look up if the selector we're about to call on a certain class has an aspect on it
    //because if it does, and it's this aspect we're in right now
    //we could have a nasty loop
    //or if two aspect objects end up calling each other
    //also bad news...
    
    NSLog(@"%@before %s on %s",indent, s, o->isa->name);
    NSString * newIndent = [NSString stringWithFormat: @"-%@",indent];
    [indent release];
    indent = [newIndent retain];
}

//-(void *)around

-(void)after:(SEL)s object:(id)o{
    //we can't print out the object directly because we might have an aspect on selector: description
    NSString * newIndent = [indent substringFromIndex: 1];
    [indent release];
    indent = [newIndent retain];
    
    NSLog(@"%@after %s on %s",indent, s, o->isa->name);
}
*/
