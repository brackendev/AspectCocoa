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
#import <AspectCocoa/ACPointCut.h>

@interface ACAspect : NSObject {
    id pointCut;
    id advice;
    BOOL loaded;
    id (*getSignature)(id, SEL, SEL);
}

+(id)aspectWithPointCut: (id)pc andAdviceObject: (id)adv;

/* 
    Initialize this ACAspect object with a pointcut and an advice object
*/
-(id)initWithPointCut: (id)pc andAdviceObject: (id)adv;

/* 
    Load the aspect, apply it's advice to it's point cut
*/
-(void)load;

/* 
    Unload the aspect, unapply it's advice from it's point cut
*/
-(void)unload;

/* 
    returns whether or not this aspect is currently loaded
*/
-(BOOL)isLoaded;

/*
*
*  Private Methods
*  these are either methods you shouldn't call at all
*  or methods that will eventually be made public, but aren't ready yet
*  so their actual functionality may change...
*
*/
-(void)loadGenOnly;
-(void)loadActually: (BOOL)actuallyLoad;

@end
