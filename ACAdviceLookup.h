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
//#import </usr/include/objc/objc-class.h>
//#import </usr/include/objc/objc-runtime.h>
#import <AspectCocoa/ACAdviceList.h>

#define BUCKET_SIZE 32

typedef enum
{
  NODE_CONTAINS_LEAVES, //leafy tree
  NODE_CONTAINS_TREES //non-leafy tree
} NODE_TYPES;

typedef struct dict_leaf{
	Class classpointer;
	SEL methodname;
	id value;
} LEAF;

typedef struct dict_tree{
	NODE_TYPES node_type;
	int size; //only applies to leafy trees
	void ** nodes; //should always be allocated to be of size BUCKET_SIZE
} TREE;

typedef struct dictionary {
  struct dict_tree tree;
} DICTIONARY;


//allocate and return a new dictionary
DICTIONARY * CreateDictionary();

//completely deallocate the dictionary
void DestroyDictionary(DICTIONARY * dict);

//save a value in the dictionary
void SaveValueForKey(DICTIONARY * dict, void * value, Class classpointer, SEL methodname);

//get a value from the dictionary
//returns null if no value in dictionary
void * GetValueForKey(DICTIONARY * dict, Class classpointer, SEL methodname);

//removes the key from the dictionary
void RemoveKey(DICTIONARY * dict, Class classpointer, SEL methodname);

void PrintTree(TREE * tree, char * indent);

void DestroyTREE(TREE * tree);


@interface ACAdviceLookup : NSObject {
	DICTIONARY * dictionary;
}

-(ACAdviceList *)adviceListforSelector:(SEL)selector onClass:(Class) class;

-(void)setAdviceList:(ACAdviceList *)list forSelector:(SEL)selector onClass:(Class) class;

-(void)removeAdviceListforSelector:(SEL)selector onClass: (Class)class;

-(ACAdviceList *)adviceListforSelectorWithoutSuperLookup:(SEL)selector onClass:(Class) class;

-(void)printTree;

-(void)addAdvice:(id)advice forMethod:(struct objc_method *)method onClass: (Class)class;

-(void)removeAdvice:(id)advice forMethod:(struct objc_method *)method onClass: (Class)class;

@end
