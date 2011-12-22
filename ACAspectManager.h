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
#import <AspectCocoa/ACAdviceLookup.h>
#import <AspectCocoa/ACIMPLookup.h>
#import <AspectCocoa/ACBOOLLookup.h>
#import </usr/include/objc/objc-class.h>

@interface ACAspectManager : NSObject {
    ACAdviceLookup * adviceLookup;
    ACIMPLookup * methodSigLookup;
    ACIMPLookup * forwardInvLookup;

    ACBOOLLookup * classWrappedWithDepth;
    ACBOOLLookup * classWrappedWtihForwarding;    
}

+(void)enableAllAdvice;
+(void)disableAllAdvice;

+(void)protectAdvice;
+(void)unprotectAdvice;

/*
    Controls Debug logging
    Log nothing
*/
+(void)quiet;

/*
    Controls Debug logging
    Log everything
*/
+(void)verbose;

/*
    Controls Debug logging
    Log information relevant to code generation
*/
+(void)genOnly;

/*
*
*  Private Methods
*  these are either methods you shouldn't call at all
*  or methods that will eventually be made public, but aren't ready yet
*  so their actual functionality may change...
*
*/
+(ACAspectManager *)sharedManager;

+(BOOL)loggingGen;
+(BOOL)loggingAll;

-(void)addAdviceObject:(id)advice forMethod: (struct objc_method *)method onClass: (Class)class;
-(void)removeAdviceObject:(id)advice forMethod: (struct objc_method *)method onClass: (Class)class;

-(ACAdviceList *)adviceListForSelector: (SEL)selector onClass: (Class) toLookup;
-(NSMethodSignature *)savedMethodSignatureForSelector: (SEL)selector onClass: (Class) toLookup;

-(void)saveSig: (Method) sig forClass: (Class) c;
-(void)saveInv: (Method) inv forClass: (Class) c;

-(ACIMP *)getIMPforClass: (Class) c onLookup: (ACIMPLookup *) impLookup methodDepth: (int) md objectDepth: (int) od;
-(ACIMP *)getSigforClass: (Class) c methodDepth: (int) md objectDepth: (int) od;
-(ACIMP *)getInvforClass: (Class) c methodDepth: (int) md objectDepth: (int) od;

-(void)setWrappedWithDepth:(BOOL) b forClass: (Class) c;
-(BOOL)isClassWrappedWithDepth:(Class)c;

-(void)setWrappedWithForwarding:(BOOL) b forClass: (Class) c;
-(BOOL)isClassWrappedWithForwarding:(Class)c;


@end
