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

#import <Foundation/Foundation.h>
#import <AspectCocoa/ACMethodSignature.h>
#import <AspectCocoa/ACPointCut.h>

@interface ACCodeGenerator : NSObject {
    NSMutableDictionary * failedMethods;
    BOOL generatingCode;
}

/* 
    Returns the shared instance of ACCodeGenerator.
    There is a single generator because we never want to generate code for the same signature more than once
*/
+(ACCodeGenerator *)generator;

/* 
    Returns whether or not code generation is enabled.
*/
-(BOOL)generateCode;

/* 
    Enables code generation for loading of all future aspects
*/
-(void)enableCodeGeneration;

/* 
    Disables all code generation.
*/
-(void)disableCodeGeneration;

/* 
    Output all generated code to the given path
*/
-(void)writeCodeTo:(NSString *)path;

/* 
    Generates all code needed for a specific pointCut and writes it to a given path
    (if all necessary code already exists in the runtime, an empty file will be generated)
*/
+(void)generateCodeForPointCut: (ACPointCut *)pointCut writeTo: (NSString *) destination;
-(void)generateCodeForPointCut: (ACPointCut *)pointCut writeTo: (NSString *) destination;


/*
*
*  Private Methods
*  these are either methods you shouldn't call at all
*  or methods that will eventually be made public, but aren't ready yet
*  so their actual functionality may change...
*
*/
-(NSString*)mallocForString:(NSString *)type;

-(void)addFailedMethod:(ACMethodSignature *) method forClass: (Class) c;

-(void)writeToFile:(NSString *)path;
-(void)writeFailedMethods:(NSArray *) methods toFile:(NSString *)path;

-(NSString *)createGenHeader:(ACMethodSignature *) method;
-(NSString *)createGenMethod:(ACMethodSignature *) method;
-(NSString *)createInvHeader:(ACMethodSignature *) method;
-(NSString *)createInvMethod:(ACMethodSignature *) method;

@end
