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

#import "ACCodeGenerator.h"
#import "ACAspectManager.h"
#import "ACAspect.h"
#import "ACClass.h"
#import </usr/include/objc/objc-class.h>

@implementation ACCodeGenerator

#define append(a,b) \
[a appendString: b]

#define appendR(b) \
[toReturn appendString: b]

static ACCodeGenerator *_ac_missing_code_manager_instance = nil;

+(ACCodeGenerator *)generator{
    if( _ac_missing_code_manager_instance == nil){
        _ac_missing_code_manager_instance = [[[self alloc] init] retain];
    }
    return _ac_missing_code_manager_instance;
}

- (id)init {
    self = [super init];
    if (self) {
        failedMethods = [[NSMutableDictionary new] retain];
	generatingCode = NO;
    }
    return self;
}

- (void)dealloc{
    [failedMethods release];
    [super dealloc];
}

//= (void *)malloc(sizeof(void *));
-(NSString*)mallocForString:(NSString *)type{
    return @";\n";
    /*
    NSMutableString * toReturn = [NSMutableString new];
    if( [type isEqualToString: @"char"] ||
	[type hasPrefix: @"long"] ||
	[type hasPrefix: @"double"] ||
	[type hasPrefix: @"long"] )
    {
	appendR(@";\n");
    }else{
	appendR(@" = (");
	appendR(type);
	appendR(@")malloc(sizeof(");
	appendR(type);
	appendR(@"));\n");
    }
    return toReturn;
    */
}

-(BOOL)generateCode{
    return generatingCode;
}

-(void)enableCodeGeneration{
    generatingCode = YES;
}

-(void)disableCodeGeneration{
    generatingCode = NO;
}

+(void)generateCodeForPointCut: (ACPointCut *)pointCut writeTo: (NSString *) destination{
    [[self generator] generateCodeForPointCut: pointCut writeTo: destination];
}

-(void)generateCodeForPointCut: (ACPointCut *)pointCut writeTo: (NSString *) destination{
    [self enableCodeGeneration];
    [[[ACAspect alloc] initWithPointCut: pointCut andAdviceObject: self] loadGenOnly];
    [self writeCodeTo: destination];
    [self disableCodeGeneration];
}

-(void)writeCodeTo:(NSString *)path{
    [self writeToFile: path];
}

-(void)addFailedMethod:(ACMethodSignature *) method forClass: (Class) c{
    if( [method canBeCoded]){
        [failedMethods setObject: method forKey: [method stringSelectorSansColin]];
	if([ACAspectManager loggingGen])
	    NSLog(@"--Will generate code for %s %@", c->name, method);
    }else{
	if([ACAspectManager loggingGen])
	    NSLog(@"unable to make replacement for %s %@ -- encountered unknown data type", c->name, method);
    }
}

-(void)writeToFile:(NSString *)path {
    NSLog(@"writting in pieces");
    NSArray * methods = [failedMethods allValues];
//    if([methods count] <= 100){
//	[self writeFailedMethods: methods toFile: path];
//	return;
//    }
    int i=0;
    int start = 0;
    int count = [methods count]; 
    NSLog(@"count %i",count);
    while(start+100 < count){
	NSLog(@"%i from %i length %i",i,start,100);
	[self writeFailedMethods: [methods subarrayWithRange: NSMakeRange(start, 100)] 
	      toFile: [NSString stringWithFormat: @"%@%i", path, i]];
	start += 100;
	i++;
    }
    NSLog(@"%i from %i length %i",i,start,count-start);
    [self writeFailedMethods: [methods subarrayWithRange: NSMakeRange(start, count-start)] 
	  toFile: [NSString stringWithFormat: @"%@%i", path, i]];
}

-(void)writeFailedMethods:(NSArray *) methods toFile:(NSString *)path {
    NSLog(@"writting");
    NSString * category = [[path componentsSeparatedByString: @"/"] lastObject];
    NSLog(@"category is %@", category);
    NSMutableString * headerGenOutput = [NSMutableString new];
    NSMutableString * methodGenOutput = [NSMutableString new];
    NSMutableString * headerInvOutput = [NSMutableString new];
    NSMutableString * methodInvOutput = [NSMutableString new];
    int i;
    for(i=0; i<[methods count]; i++){
        ACMethodSignature * ithWrapper = [methods objectAtIndex: i];
        [headerGenOutput appendString: [self createGenHeader: ithWrapper]];
        [methodGenOutput appendString: [self createGenMethod: ithWrapper]];
        [headerInvOutput appendString: [self createInvHeader: ithWrapper]];
        [methodInvOutput appendString: [self createInvMethod: ithWrapper]];
    }
    NSMutableString * finalHeader = [NSMutableString new];
    
    /*
    #import "ACGeneratedCode.h"

    @interface ACGeneratedCode (GeneratedCodeAdditions)
    */
    [finalHeader appendString: @"#import <AspectCocoa/ACGeneratedCode.h>\n\n@interface ACGeneratedCode ("];
    [finalHeader appendString: category];
    [finalHeader appendString: @")\n\n"];

    //Gen headers
    [finalHeader appendString: headerGenOutput];
    
    /*
    @end

    @interface ACInvocation (GeneratedCodeAdditions)
    */
    [finalHeader appendString: @"\n@end\n\n\n\n@interface ACInvocation ("];
    [finalHeader appendString: category];
    [finalHeader appendString: @")\n\n"];
    
    //Inv headers
    [finalHeader appendString: headerInvOutput];

    /*
    @end
    */
    [finalHeader appendString: @"\n@end"];
    
    //done with finalHeader
    [finalHeader writeToFile: [NSString stringWithFormat: @"%@.h", path] atomically: YES];
    
    NSMutableString * finalMethod = [NSMutableString new];
    /*
    #import "GeneratedCodeAdditions.h"

    @implementation ACGeneratedCode (GeneratedCodeAdditions)
    */
    [finalMethod appendString: @"#import \""];
    [finalMethod appendString: category];
    [finalMethod appendString: @".h\"\n\n@implementation ACGeneratedCode ("];
    [finalMethod appendString: category];
    [finalMethod appendString: @")\n\n"];
    
    //Gen methods
    [finalMethod appendString: methodGenOutput];

    /*
    @end

    @implementation ACInvocation (GeneratedCodeAdditions)
    */
    [finalMethod appendString: @"\n@end\n\n\n\n@implementation ACInvocation ("];
    [finalMethod appendString: category];
    [finalMethod appendString: @")\n\n"];
    
    //Inv methods
    [finalMethod appendString: methodInvOutput];
    
    /*
    @end
    */
    [finalMethod appendString: @"\n@end"];
    
    //done with finalMethod
    [finalMethod writeToFile: [NSString stringWithFormat: @"%@.m", path] atomically: YES];
}

//replacPointPoint: is [method stringSelectorSansDepth];
//replacPointPoint is [method stringSelectorSansColin];
//replacPoint is [method returnSelector];
//Point is [method argsSelectorSansColin];
//Point: is [method argsSelector];
//void * is [method codeReturnType];
//Point: is [method argsSelectorAt: 0];
//void * is [method codeTypeAt: 0];
//1 is [method argCount];
//a is [method varAt: 0];
/*
#define HEADERreplacPointPoint(i) \
- (void *)replacPoint ## i ## Point:(void*)a

HEADERreplacPointPoint(0);
...
HEADERreplacPointPoint(12);

#define MACROreplacPointPoint(i) \
    - (void *)replacPoint ## i ## Point:(void *)a \
    { \
        return (void *)replacPointPoint(self, _cmd, i, a); \
    } \
*/
-(NSString *)createGenHeader:(ACMethodSignature *) method{
    NSMutableString * toReturn = [NSMutableString new];
    int i;
    appendR( @"#define HEADER");
    appendR( [method stringSelectorSansColin]);
    appendR( @"(iii) \\\n");
    appendR( @"- (");
    appendR([method codeReturnType]);
    appendR(@")");
    appendR( [method returnSelector]);
    appendR( @" ## iii ");
    for(i=0; i<[method argCount]; i++){
        if( i==0)
            appendR( @"##");
        appendR( @" ");
        appendR( [method argsSelectorAt: i]);
        appendR( @" (" );
        appendR( [method codeTypeAt: i] );
        appendR( @") " );
        appendR( [method varAt: i] );
    }
    appendR( @"\n\n" );
    for(i=0; i<13; i++){
        appendR( @"HEADER" );
        appendR( [method stringSelectorSansColin] );
        appendR( @"(" );
        [toReturn appendString: [NSString stringWithFormat: @"%i", i] ];
        appendR( @");\n" );
    }
    appendR( @"\n\n#define MACRO" );
    appendR( [method stringSelectorSansColin] );
    appendR( @"(iii) \\\n" );
    appendR( @"-(" );
    appendR( [method codeReturnType] );
    appendR( @")" );
    appendR( [method returnSelector] );
    appendR( @" ## iii " );
    for(i=0; i<[method argCount]; i++){
        if( i==0)
            appendR( @"##");
        appendR( @" ");
        appendR( [method argsSelectorAt: i] );
        appendR( @" (" );
        appendR( [method codeTypeAt: i] );
        appendR( @") " );
        appendR( [method varAt: i] );
    }
    appendR( @" \\\n { \\\n" );
    //return (void *)replacPointPoint(self, _cmd, i, a
    appendR( @"	return (" );
    appendR( [method codeReturnType] );
    appendR( @")" );
    appendR( [method stringSelectorSansColin] );
    appendR( @"(self, _cmd, iii" );
    for(i=0; i<[method argCount]; i++){
        appendR( @", " );
        appendR( [method varAt: i] );
    }
    appendR( @"); \\\n } \\\n\n\n" );
    return toReturn;
}

/*
void * replacPointPoint(id self, SEL _cmd, int depth, void * a){
    ACInvocation * invoker = makeInvoker(self, _cmd, depth, @selector(replacPointPoint));
    [[invoker inv] setArgument: &a atIndex: 2];
    [invoker performAdvice];
    id returnVal = malloc(sizeof(id));
    [[invoker inv] getReturnValue: &returnVal];
    return returnVal;
}

MACROreplacPointPoint(0)
...
MACROreplacPointPoint(12)
*/
-(NSString *)createGenMethod:(ACMethodSignature *) method{
    NSMutableString * toReturn = [NSMutableString new];
    int i;
//void * replacPointPoint(id self, SEL _cmd, int depth, void * a){
    appendR( [method codeReturnType] );
    appendR( @" " );
    appendR( [method stringSelectorSansColin] );
    appendR(@"(id self, SEL _cmd, int depth");
    for(i=0; i<[method argCount]; i++){
        appendR( @", " );
        appendR( [method codeTypeAt: i] );
        appendR( @" " );
        appendR( [method varAt: i] );
    }
    appendR(@"){\n");
//ACInvocation * invoker = makeInvoker(self, _cmd, depth, @selector(replacPointPoint));
    appendR(@"	ACInvocation * invoker = makeInvoker(self, _cmd, depth, @selector(");
    appendR( [method stringSelectorSansColin] );
    appendR(@"));\n");
//[[invoker inv] setArgument: &a atIndex: 2];
    for(i=0; i<[method argCount]; i++){
        appendR(@"	[[invoker inv] setArgument: &");
        appendR( [method varAt: i] );
        appendR(@" atIndex: ");
        [toReturn appendString: [NSString stringWithFormat: @"%i", i+2] ];
        appendR(@"];\n");
    }
    
//    [invoker performAdvice];
    appendR(@"	[invoker performAdvice];\n	");
    if(![[method codeReturnType] isEqualToString: @"void"]){
//    id returnVal = malloc(sizeof(id));
	appendR( [method codeReturnType] );    
	appendR(@" returnVal");// = (");
	appendR( [self mallocForString: [method codeReturnType]]);
	//appendR( [method codeReturnType] );
	//appendR(@")malloc(sizeof(");
	//appendR( [method codeReturnType] );    
	//appendR(@"));\n");
//    [[invoker inv] getReturnValue: &returnVal];
	appendR(@"	[[invoker inv] getReturnValue: &returnVal];\n");    
//    [invoker cleanup];
	appendR(@"	[invoker cleanup];\n");
//    return returnVal;
	appendR(@"	return returnVal;\n");
    }else{
//    [invoker cleanup];
	appendR(@"	[invoker cleanup];\n");    
    }
    appendR(@"}\n");
//MACROreplacPointPoint(0) ... MACROreplacPointPoint(12)
    for(i=0; i<13; i++){
        appendR( @"MACRO" );
        appendR( [method stringSelectorSansColin] );
        appendR( @"(" );
        [toReturn appendString: [NSString stringWithFormat: @"%i", i] ];
        appendR( @")\n" );
    }
    appendR(@"\n\n");
    return toReturn;
}

//-(void)replacPointPoint;
-(NSString *)createInvHeader:(ACMethodSignature *) method{
    return [NSString stringWithFormat: @"\n-(void)%@;\n", [method stringSelectorSansColin]];
}

//replacPointPoint: is [method stringSelectorSansDepth];
//replacPointPoint is [method stringSelectorSansColin];
//replacPoint is [method returnSelector];
//Point is [method argsSelectorSansColin];
//Point: is [method argsSelector];
//void * is [method codeReturnType];
//Point: is [method argsSelectorAt: 0];
//void * is [method codeTypeAt: 0];
//1 is [method argCount];
//a is [method varAt: 0];
/*
-(void)replacPointPoint{
    void * (*toInvoke)(id, SEL, ...);
    toInvoke = (void * (*)(id, SEL, ...))[advice getIMP];

    void * a = malloc(sizeof(void *));
    [invStorage getArgument: &a atIndex: 2];
    void * myReturn = toInvoke(object, selector, a);
    [invStorage setReturnValue: &myReturn];

    void * a = *(void **)[self getArgAt: 0];
    void * myReturn = toInvoke(object, selector, a);
    returnVal = &myReturn;
}
*/
-(NSString *)createInvMethod:(ACMethodSignature *) method{
    NSMutableString * toReturn = [NSMutableString new];
    int i;
//-(void)replacPointPoint{
    appendR(@"-(void)");
    appendR([method stringSelectorSansColin]);
    appendR(@"{\n");
//    void * (*toInvoke)(id, SEL, ...);
    appendR(@"	");
    appendR([method codeReturnType]);
    appendR(@" (*toInvoke)(id, SEL, ...);\n");
//    toInvoke = (void * (*)(id, SEL, ...))[advice getIMP];
    appendR(@"	toInvoke = (");
    appendR([method codeReturnType]);
    appendR(@" (*)(id, SEL, ...))[advice getIMP];\n");
    
    for(i=0; i<[method argCount]; i++){
//    void * a = malloc(sizeof(void *));
	appendR(@"	");
	appendR([method codeTypeAt: i]);
	appendR(@" ");
	appendR( [method varAt: i] );
	appendR( [self mallocForString: [method codeTypeAt: i]]);
	//appendR(@" = (");
	//appendR([method codeTypeAt: i]);
	//appendR(@")malloc(sizeof(");
	//appendR([method codeTypeAt: i]);
	//appendR(@"));\n");
//    [invStorage getArgument: &a atIndex: 2];
        appendR( @"	[invStorage getArgument: &" );
        appendR( [method varAt: i] );
        appendR( @" atIndex: " );
        [toReturn appendString: [NSString stringWithFormat: @"%i", i+2] ];
        appendR( @"];\n" );
    }
//    void * myReturn = toInvoke(object, selector, a);
    if(![[method codeReturnType] isEqualToString: @"void"]){
    	appendR(@"	" );
	appendR([method codeReturnType]);
	appendR(@" myReturn = toInvoke(object, selector");
    }else{
	appendR(@"	toInvoke(object, selector");
    }
    for(i=0; i<[method argCount]; i++){
        appendR( @", " );
        appendR( [method varAt: i] );
    }
    appendR(@");\n");
//    [invStorage setReturnValue: &myReturn];
    if(![[method codeReturnType] isEqualToString: @"void"]){
	appendR(@"	[invStorage setReturnValue: &myReturn];");
    }
    appendR(@"\n}\n\n");
    return toReturn;
}

@end
