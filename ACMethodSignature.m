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

#import "ACMethodSignature.h"
#import </usr/include/objc/objc-class.h>

@implementation ACMethodSignature

-(id) initWithMethod:(struct objc_method *)meth signature: (NSMethodSignature*) sig depth: (int) d{
    self = [super init];
    if (self){
	method = meth;
	signature = [sig retain];
	depth = d;
    }
    return self;
}

-(void)dealloc{
    [signature release];
    [super dealloc];
}

-(NSString *)description{
    return [NSString stringWithFormat: @"%s %@", method->method_name, signature];
}

-(int) getDepth{
    return depth;
}

-(struct objc_method *) getMethod{
    return method;
}

-(NSMethodSignature *) getSignature{
    return signature;
}

-(SEL)getSelector{
    return method->method_name;
}

- (SEL)	getReplacementSEL {
    return sel_registerName([[NSString stringWithFormat: @"%@%i%@", 
                                [self returnSelector], 
                                depth, 
                                [self argsSelector]] cString]);
}

-(NSString *)stringSelectorSansDepth{
    return [NSString stringWithFormat: @"%@%@", [self returnSelector], [self argsSelector]];
}

-(NSString *)stringSelectorSansColin{
    return [NSString stringWithFormat: @"%@%@", [self returnSelector], [self argsSelectorSansColin]];
}

-(NSString *)argsSelector{
    NSString * selectorString = @"";
    int i;
    for(i=2; i<[signature numberOfArguments]; i++){
        NSString * nextArgType = [[NSString alloc] initWithCString: [signature getArgumentTypeAtIndex: i]];
        selectorString = [NSString stringWithFormat: @"%@%@:", selectorString ,[self stringForEncodedType: nextArgType]];
    }
    return selectorString;
}

-(NSString *)argsSelectorSansColin{
    NSString * selectorString = @"";
    int i;
    for(i=2; i<[signature numberOfArguments]; i++){
        NSString * nextArgType = [[NSString alloc] initWithCString: [signature getArgumentTypeAtIndex: i]];
        selectorString = [NSString stringWithFormat: @"%@%@", selectorString ,[self stringForEncodedType: nextArgType]];
    }
    return selectorString;
}

-(NSString *)returnSelector{
    NSString * selectorString = @"replac";
    NSString * returnType = [[NSString alloc] initWithCString: [signature methodReturnType]];
    return [NSString stringWithFormat: @"%@%@", selectorString ,[self stringForEncodedType: returnType]];
}

-(NSString *)argsSelectorAt:(int) i{
    NSString * argType = [[NSString alloc] initWithCString: [signature getArgumentTypeAtIndex: i+2]];
    return [NSString stringWithFormat: @"%@:", [self stringForEncodedType: argType]];
}

-(NSString *)codeReturnType{
    NSString * returnType = [[NSString alloc] initWithCString: [signature methodReturnType]];
    return [self codeForEncodedType: returnType];
}

-(NSString *)codeTypeAt:(int) i{
    NSString * argType = [[NSString alloc] initWithCString: [signature getArgumentTypeAtIndex: i+2]];
    return [self codeForEncodedType: argType];
}

-(NSString *)varAt:(int) i{
    char arg = 'a' + i;
    return [NSString stringWithFormat: @"%c", arg];
}

-(int)argCount{
    return [signature numberOfArguments]-2;
}

-(BOOL)canBeCoded{
    return ([[self stringSelectorSansDepth] rangeOfString: @"?"].location == NSNotFound);
}

-(NSString*)normalizeStruct:(NSString *)structName{
    if([structName hasPrefix: @"_NS"]){
        if([structName isEqualToString: @"_NSRange"])
            return @"NSRange";
        if([structName isEqualToString: @"_NSSize"])
            return @"NSSize";
        if([structName isEqualToString: @"_NSPoint"])
            return @"NSPoint";
        if([structName isEqualToString: @"_NSRect"])
            return @"NSRect";
    }       
    NSLog(@"couldn't find code/string for type %@", structName);
    return @"???";
//    if([structName isEqualToString: @"NSButtonState"]){
//    if([structName isEqualToString: @"_CGSEvent"]){
    return structName;
}

-(NSString*)stringForEncodedType:(NSString *)type{
//as far as we can tell the signed and unsigned types work interchangable
    if([type isEqualToString: @"c"] || 
        [type isEqualToString: @"C"] || 
        [type isEqualToString: @"i"] || 
        [type isEqualToString: @"I"] ||
        [type isEqualToString: @"s"] || 
        [type isEqualToString: @"S"] ||
        [type isEqualToString: @"b"])
        return @"Char";
//int, short, char, BOOL are all the same to objc_msgSend
    if([type isEqualToString: @"l"] || 
        [type isEqualToString: @"L"])
        return @"Long";
    if([type isEqualToString: @"q"] || 
        [type isEqualToString: @"Q"])
        return @"LongLong";
    if([type isEqualToString: @"f"] || 
        [type isEqualToString: @"d"]) 
        return @"Double";
//a double is also a float
    if([type hasPrefix: @"{"] || [type hasPrefix: @"("]){
        //might look like {_NSRect={_NSPoint=ff}{_NSSize=ff}}
        //we should parse out the actual name of the struct or union and use it appropriately
        int from;
        if([type hasPrefix: @"{"])
            from = [type rangeOfString: @"{"].location;
        else
            from = [type rangeOfString: @"("].location;            
        int to = [type rangeOfString: @"="].location;
        return [self normalizeStruct: [type substringWithRange: NSMakeRange(from + 1, to - 1)]];
    }
    if([type hasPrefix: @"@"]) 
        return @"Object";
    if([type hasPrefix: @"^"]) 
	return @"Pointer";
    if([type hasPrefix: @":"]) 
	return @"Selector";
    if([type hasPrefix: @"v"] || [type hasPrefix: @"V"])
	return @"Void";
    if([type hasPrefix: @"#"])
	return @"Class";
    if([type hasPrefix: @"*"])
	return @"CharStar";

    NSLog(@"couldn't find string for type %@", type);
    return @"???";

//    if([type hasPrefix: @"?"])
//        return @"?";
    //the rest of types should be basically pointers..
    //    if([type isEqualToString: @"*"] || [type isEqualToString: @":"])//a method SEL == char *
    //"^", "@", "[", "#", "v" (void), "*" , ":"....
}

-(NSString*)codeForEncodedType:(NSString *)type{
//as far as we can tell the signed and unsigned types work interchangable
    if([type isEqualToString: @"c"] || 
        [type isEqualToString: @"C"] || 
        [type isEqualToString: @"i"] || 
        [type isEqualToString: @"I"] ||
        [type isEqualToString: @"s"] || 
        [type isEqualToString: @"S"] ||
        [type isEqualToString: @"b"])
        return @"char";
//int, short, char, BOOL are all the same to objc_msgSend
    if([type isEqualToString: @"l"] || 
        [type isEqualToString: @"L"])
        return @"long";
    if([type isEqualToString: @"q"] || 
        [type isEqualToString: @"Q"])
        return @"long long";
    if([type isEqualToString: @"f"] || 
        [type isEqualToString: @"d"]) 
        return @"double";
//a double is also a float
    if([type hasPrefix: @"{"] || [type hasPrefix: @"("]){
        //might look like {_NSRect={_NSPoint=ff}{_NSSize=ff}}
        //we should parse out the actual name of the struct or union and use it appropriately
        int from;
        if([type hasPrefix: @"{"])
            from = [type rangeOfString: @"{"].location;
        else
            from = [type rangeOfString: @"("].location;            
        int to = [type rangeOfString: @"="].location;
        return [self normalizeStruct: [type substringWithRange: NSMakeRange(from + 1, to - 1)]];
    }
    if([type hasPrefix: @"@"])
        return @"id";
    if([type hasPrefix: @"^"])
	return @"void *";
    if([type hasPrefix: @":"])
	return @"SEL";
    if([type hasPrefix: @"v"] || [type hasPrefix: @"V"])
	return @"void";
    if([type hasPrefix: @"#"])
	return @"Class";
    if([type hasPrefix: @"*"])
	return @"char *";

    NSLog(@"couldn't find code for type %@", type);
    return @"???";

//    if([type hasPrefix: @"?"])
//        return @"?";
    //the rest of types should be basically pointers..
    //    if([type isEqualToString: @"*"] || [type isEqualToString: @":"])//a method SEL == char *
    //"^", "@", "[", "#", "v" (void), "*" , ":"....
//    return @"void *";
}

@end
