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

#import "ACInvocation.h"
#import "NSObjectExtensions.h"
#import </usr/include/objc/objc-class.h>

@implementation ACInvocation

static int _ac_adviceIsOn = 1;
static int _ac_protectedAdvice = 0;

+(void)enableAllAdvice{
    _ac_adviceIsOn = 1;
}

+(void)disableAllAdvice{
    _ac_adviceIsOn = 0;
}

+(void)protectAdvice{
    _ac_protectedAdvice = 1;
}

+(void)unprotectAdvice{
    _ac_protectedAdvice = 0;
}

-(id)initWithSignature:(NSMethodSignature *) sig{
    self = [super init];
    if (self) {
	fromForward = NO;
	invStorage = [[NSInvocation invocationWithMethodSignature: sig] retain];
	invokedAlready = NO;
	invokingAround = -1;
    }
    return self;
}

-(id)initWithInvocation:(NSInvocation *) inv{
    self = [super init];
    if (self) {
	fromForward = YES;
	invStorage = [inv retain];
	invokedAlready = NO;
	invokingAround = -1;
    }
    return self;
}

- (void)dealloc{
    [invStorage release];
	[super dealloc];
}

-(NSInvocation *)inv{
    return invStorage;
}

- (NSMethodSignature *)methodSignature{
    return [invStorage methodSignature];
}

-(void)use:(SEL)use{
    toUse = use;
}

-(void)setClass:(Class)c{
    invClass = c;
}

-(Class)getClass{
    return invClass;
}

-(NSString *)className{
    return [NSString stringWithCString: invClass->name];
}

-(void)setSelector:(SEL)sel{
    selector = sel;
}

-(SEL)selector{
    return selector;
}

-(id)target{
    if( fromForward )
	return [invStorage target];
    else
	return object;
}

-(void)setTarget:(id)obj{
    if( fromForward )
	[invStorage setTarget: obj];
    else
	object = obj;
}

- (NSString *)description {
    return [NSString stringWithFormat: @"%@ target->%@ selector->%s", [super description], [self target], selector];
}

-(void)setAdvice:(ACAdviceList *)adv{
    advice = adv;
}

-(void)performAdvice{
    if(_ac_adviceIsOn){
        //befores
	int i;
	for(i=[advice count]-1; i>=0; i--){
	    id adviceObject = [advice objectAtIndex: i];
	    if([adviceObject respondsToSelector: @selector(before:)] ){
		if(_ac_protectedAdvice){
		    _ac_adviceIsOn = 0;
		    [adviceObject before: self];
		    _ac_adviceIsOn = 1;
		}else{
		    [adviceObject before: self];		
		}
	    }
	}
	//arounds
	BOOL noArounds = YES;
	for(i=[advice count]-1; i>=0; i--){
	    id adviceObject = [advice objectAtIndex: i];
    //	NSLog(@"advice loop checks %i %@", i, adviceObject);
	    if([adviceObject respondsToSelector: @selector(around:)] ){
		invokingAround = i-1;
		if(_ac_protectedAdvice){
		    _ac_adviceIsOn = 0;
		    [adviceObject around: self];
		    _ac_adviceIsOn = 1;
		}else{
		    [adviceObject around: self];
		}
		i = invokingAround;
		invokingAround = -1;
		noArounds = NO;
		i = -1;
	    }
	}
	if(noArounds)
	    [self invoke];
	//afters
	for(i=0; i<[advice count]; i++){
    //    for(i=[advice count]-1; i>=0; i--){
	    id adviceObject = [advice objectAtIndex: i];
	    if([adviceObject respondsToSelector: @selector(after:)] ){
		if(_ac_protectedAdvice){
		    _ac_adviceIsOn = 0;
		    [adviceObject after: self];
		    _ac_adviceIsOn = 1;
		}else{
		    [adviceObject after: self];
		}
	    }
	}
    }else{
	[self invoke];
    }
}


-(void)invoke{
    if(invokingAround >= 0){
	int i;
	BOOL skipRealInvoke = NO;
        for(i=invokingAround; i>=0; i--){
	    id adviceObject = [advice objectAtIndex: i];
//	    NSLog(@"invoke loop checks %i %@", i,adviceObject);
	    if([adviceObject respondsToSelector: @selector(around:)] ){
		invokingAround = i-1;
		[adviceObject around: self];
		skipRealInvoke = YES;
	    }else{
		skipRealInvoke = NO;
	    }
	}
	if(skipRealInvoke)
	    return;
    }
    if(invokedAlready)
	return;
    else
	invokedAlready = YES;
    if( fromForward )
	[invStorage invoke];
    else
	[self performSelector: toUse];
}

- (void)invokeWithTarget:(id)target{
    [self setTarget: target];
    [self invoke];
}

- (void)getReturnValue:(void *)retLoc{
    [invStorage getReturnValue: retLoc];
}
- (void)setReturnValue:(void *)retLoc{
    [invStorage setReturnValue: retLoc];
}

- (void)getArgument:(void *)argumentLocation atIndex:(int)index{
    [invStorage getArgument: argumentLocation atIndex: index];
}
- (void)setArgument:(void *)argumentLocation atIndex:(int)index{
    [invStorage setArgument: argumentLocation atIndex: index];
}

- (void)cleanup{
    [self dealloc];
}

@end
