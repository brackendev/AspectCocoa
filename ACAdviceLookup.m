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


#import "ACAdviceLookup.h"
#import </usr/include/objc/objc-class.h>

DICTIONARY * CreateDictionary()
{
	DICTIONARY * toReturn = (DICTIONARY *)calloc(1,sizeof(DICTIONARY));
	if(toReturn == NULL)
	{
		NSLog(@"calloc failure");
		return NULL;
	}
	toReturn->tree.nodes = (void **)calloc(BUCKET_SIZE, sizeof(void *));
	if(toReturn->tree.nodes == NULL)
	{
		NSLog(@"calloc failure");
		return NULL;
	}
	toReturn->tree.node_type = NODE_CONTAINS_LEAVES;
	toReturn->tree.size = 0;
	return toReturn;
}

//Deallocate tree, and all it's sub-trees
void DestroyTREE(TREE * tree)
{
	if(tree == NULL)
		return;
	//deallocate sub-trees
	if(tree->node_type == NODE_CONTAINS_LEAVES)
	{
		//free all nodes in the leafy tree
		int i;
		for(i=0; i<tree->size; i++)
		{
			LEAF * leaf = (LEAF *)tree->nodes[i];
			//if we're saving copies of the keys, deallocate the copies
			free(leaf);
		}
	}
	else
	{
		//call DestroyTree on all non-NULL nodes
		int i;
		for(i=0; i<BUCKET_SIZE; i++)
		{
			DestroyTREE((TREE *)tree->nodes[i]);
		}
	}
	//deallocate parent tree
	free(tree);
	return;
}

void DestroyDictionary(DICTIONARY * dict){
	if(dict != NULL)
		DestroyTREE(&dict->tree);
	return;
}


//If too many keys with the exact same hash are inserted into the Dictionary, we'll have an infinite loop
//BUCKET_SIZE+1 keys to be exact..
//If this happens, try changing the hash function or using a larger BUCKET_SIZE
unsigned long blandHash(Class classpointer, SEL methodname)
{
/*
	unsigned long hash = 0;
	hash = (int)methodname;
	hash = ((hash << 5) + hash) + (int)classpointer;
	hash = ((hash << 5) + hash) + ((char *)methodname)[0];
	hash = ((hash << 5) + hash) + ((char *)classpointer->name)[0];

	return hash;
*/
	char * key = (char *)methodname;
	unsigned long hash = 0;
	int c;

	while (c = *key++)
		hash = ((hash << 5) + hash) + c; // hash * 33 + c 
		//hash = c + hash*65599; //c + (hash << 6) + (hash << 16) - hash
		
	char * key2 = (char *)classpointer->name;
	
	while (c = *key2++)
		hash = ((hash << 5) + hash) + c;

	return hash;
}

int LeafEqualsKey(LEAF * leaf, Class classpointer, SEL methodname)
{
	return leaf->classpointer == classpointer &&
			leaf->methodname == methodname;
//	return strcmp(leaf->methodname, methodname) == 0 &&
//			strcmp(leaf->classpointer->name,classpointer->name) == 0 &&
//			leaf->classpointer->isa == classpointer->isa;
}

//Debugging function called when too many keys have the same hashed value
//prints out the keys with colliding hashes
/*
void CheckForTooManyDuplicateHashValues(TREE * tree, char * key)
{
	unsigned long newHash = blandHash(key);
	int i;
	for(i=0; i<BUCKET_SIZE; i++)
	{
		LEAF * leaf = (LEAF *)tree->nodes[i];
		if(blandHash(leaf->key) != newHash)
			return;
	}
	printf("%d keys with the same hash: %ul\n", BUCKET_SIZE, newHash);
	for(i=0; i<BUCKET_SIZE; i++)
	{
		LEAF * leaf = (LEAF *)tree->nodes[i];
		printf("%s hashes the same as ", leaf->key);
	}
	printf("%s\n", key);
}
*/

void SaveValueForKey(DICTIONARY * dict, void * value, Class classpointer, SEL methodname)
{
	unsigned long hash = blandHash(classpointer, methodname);
	TREE * tree = &dict->tree;
	//descend until we find the proper leafy tree
	while(tree->node_type == NODE_CONTAINS_TREES)
	{
		//if we find an empty tree
		//then we will need to create a leafy tree
		if(tree->nodes[hash % BUCKET_SIZE] == NULL)
		{
			TREE * newTree = (TREE *)calloc(1,sizeof(TREE));
			if(newTree == NULL)
			{
				NSLog(@"calloc failure");
				return;
			}
			newTree->nodes = (void **)calloc(BUCKET_SIZE,sizeof(void *));
			if(newTree->nodes == NULL)
			{
				NSLog(@"calloc failure");
				return;			
			}
			newTree->node_type = NODE_CONTAINS_LEAVES;
			newTree->size = 0;
			tree->nodes[hash % BUCKET_SIZE] = newTree;
			tree = newTree;
		}
		else
		{
			//tree found
			tree = (TREE *)tree->nodes[hash % BUCKET_SIZE];
		}
		//divide the hash value to find the next tree
		hash = hash / BUCKET_SIZE;
	}
	//If the key being inserted already exists in the dictionary, replace it's value
	int i;
	for(i=0; i<tree->size; i++)
	{
		LEAF * leaf = tree->nodes[i];
		if(LeafEqualsKey(leaf, classpointer, methodname))
		{
			leaf->value = value;
			return;
		}
	}
	//if the tree is too big to hold the new key
	//turn it into a non-leafy tree and re-insert what it previously held
	if(tree->size == BUCKET_SIZE)
	{
		//CheckForTooManyDuplicateHashValues(tree, key);
		
		//save old leaves
		void ** oldnodes = tree->nodes;
		//convert tree
		tree->node_type = NODE_CONTAINS_TREES;
		tree->size = 0;
		tree->nodes = (void **)calloc(BUCKET_SIZE,sizeof(void *));
		if(tree->nodes == NULL)
		{
			NSLog(@"calloc failure");
			return;
		}
		int i;
		for(i=0; i<BUCKET_SIZE; i++)
		{
			LEAF * leaf = (LEAF *)oldnodes[i];
			//re-insert old leaves
			SaveValueForKey(dict, leaf->value, leaf->classpointer, leaf->methodname);
			free(leaf);
		}
		free(oldnodes);
		//try again to insert new key
		SaveValueForKey(dict, value, classpointer, methodname);
	}
	else
	{
		//add new leaf
		LEAF * leaf = (LEAF *)calloc(1,sizeof(LEAF));
		if(leaf == NULL)
		{		
			NSLog(@"calloc failure");
			return;
		}
		tree->nodes[tree->size] = leaf;
		
		leaf->classpointer = classpointer;
		leaf->methodname = methodname;
		
		leaf->value = value;
		tree->size++;
	}
	
	return;
}

void * GetValueForKey(DICTIONARY * dict, Class classpointer, SEL methodname)
{
	unsigned long hash = blandHash(classpointer, methodname);
	TREE * tree = &dict->tree;
	//descend to the the leafy tree
	while(tree->node_type == NODE_CONTAINS_TREES)
	{
		//if we find a null one before we find a leafy one:
		//then dictionary does not contain key
		if(tree->nodes[hash % BUCKET_SIZE] != NULL)
			tree = (TREE *)tree->nodes[hash % BUCKET_SIZE];
		else
			return NULL;
		hash = hash / BUCKET_SIZE;
	}
	
	//linear search for the right leaf
	int i;
	for(i=0; i<tree->size; i++)
	{
		LEAF * leaf = tree->nodes[i];
		if(LeafEqualsKey(leaf, classpointer, methodname))
			return leaf->value;
	}
	return NULL;
}


void RemoveKeyFromTree(TREE * tree, Class classpointer, SEL methodname, unsigned long hash)
{
	if(tree == NULL)
		return;
	//if the tree contains leaves:
		//remove the proper leaf
		//put the last leaf in it's place
		//decrement the size
	if(tree->node_type == NODE_CONTAINS_LEAVES)
	{
		int i;
		for(i=0; i<tree->size; i++)
		{
			LEAF * leaf = (LEAF *)tree->nodes[i];
			//if the leaf matches
			if(LeafEqualsKey(leaf, classpointer, methodname))
			{
				//move one into it's place
				tree->nodes[i] = tree->nodes[tree->size-1];
				//decrement the tree size
				tree->size--;
			}
		}
	}
	else
	{
		//search and remove from the proper subtree
		//then check to see if the parent tree is empty, if so deallocate
		TREE * subtree = tree->nodes[hash % BUCKET_SIZE];
		RemoveKeyFromTree(subtree, classpointer, methodname, hash / BUCKET_SIZE);
		if(subtree == NULL)
		{
			//it has already been deleted.. return
			return;
		}
		//if the subtree is an empty leafy tree, delete
		if(subtree->node_type == NODE_CONTAINS_LEAVES)
		{
			if(subtree->size == 0)
			{
				free(subtree);
				tree->nodes[hash % BUCKET_SIZE] = NULL;
			}
		}
		else
		{
			int i;
			for(i=0; i<BUCKET_SIZE; i++)
			{
				if(subtree->nodes[i] != NULL)
					return;
			}
			tree->nodes[hash % BUCKET_SIZE] = NULL;
			free(subtree);
		}
	}
}

void RemoveKey(DICTIONARY * dict, Class classpointer, SEL methodname)
{
	unsigned long hash = blandHash(classpointer, methodname);
	RemoveKeyFromTree(&dict->tree, classpointer, methodname, hash);
}

void PrintTree(TREE * tree, char * indent)
{
	if(tree->node_type == NODE_CONTAINS_TREES)
	{
		printf("%s tree of trees\n", indent);
		char * newIndent = (char *)calloc(strlen(indent)+4, sizeof(char));
		if(newIndent == NULL)
		{
			NSLog(@"calloc failure");
			return;
		}
		sprintf(newIndent, "%s    ", indent);
		int i;
		for(i=0; i<BUCKET_SIZE; i++)
		{
			printf("%d",i);
			if(tree->nodes[i] != NULL)
				PrintTree(tree->nodes[i], newIndent);
			else
				printf("%s     !!!! empty node!!!!----\n",indent);
		}
		free(newIndent);
	}
	else
	{
		printf("%s tree of %d leaves\n", indent, tree->size);
		int i;
		for(i=0; i<tree->size; i++)
		{
			LEAF * leaf = tree->nodes[i];
			printf("%s     leaf %s %s\n",indent, leaf->classpointer->name, (char *)leaf->methodname);
		}
	}
}


@implementation ACAdviceLookup

- (id)init{
    self = [super init];
    if (self){
		dictionary = CreateDictionary();
    }
    return self;
}


-(ACAdviceList *)adviceListforSelector:(SEL)selector onClass:(Class) class
{
	ACAdviceList * toReturn = (ACAdviceList *)GetValueForKey(dictionary, class, selector);
    if(toReturn == nil){
        if( class == [NSObject class] || class == [NSObject class]->isa )
            return nil;
        return [self adviceListforSelector: selector onClass: class->super_class];
    }
	return toReturn;
}

-(ACAdviceList *)adviceListforSelectorWithoutSuperLookup:(SEL)selector onClass:(Class) class
{
	return (ACAdviceList *)GetValueForKey(dictionary, class, selector);
}

-(void)setAdviceList:(ACAdviceList *)list forSelector:(SEL)selector onClass:(Class) class
{
	SaveValueForKey(dictionary, list, class, selector);
}

-(void)removeAdviceListforSelector:(SEL)selector onClass: (Class)class
{
	RemoveKey(dictionary, class, selector);
}

-(void)printTree
{
	PrintTree(&dictionary->tree," ");
}

-(void)addAdvice:(id)advice forMethod:(struct objc_method *)method onClass: (Class)class{
    SEL selector = method->method_name;
    ACAdviceList * adviceList = [self adviceListforSelectorWithoutSuperLookup: selector onClass: class];
    if( adviceList == nil){
        id (*getSignarure)(id, SEL, SEL);
        getSignarure = (id (*)(id, SEL, SEL))[NSObject methodForSelector:@selector(instanceMethodSignatureForSelector:)];
        NSMethodSignature * signature;
        signature =  getSignarure(class, @selector(instanceMethodSignatureForSelector:), selector);
        adviceList = [[ACAdviceList alloc] initWithIMP: method->method_imp signature: signature selector: selector];
        [self setAdviceList: adviceList forSelector: selector onClass: class];
    }
    [adviceList addAdviceObject: advice];
}

-(void)removeAdvice:(id)advice forMethod:(struct objc_method *)method onClass: (Class)class{
    SEL selector = method->method_name;
    ACAdviceList * adviceList = [self adviceListforSelectorWithoutSuperLookup: selector onClass: class];
    if( adviceList == nil)
        return;
    [adviceList removeAdviceObject: advice];
    if( [adviceList count] == 0 ){
        
        //register that the class is unloaded
        //[[ACAspectManager sharedManager] setWrappedWithDepth: NO forClass: class];
 
        //return the IMP to it's rightfull place
        method->method_imp = [adviceList getIMP];
        
        //remove the adviceList entirely
        [self removeAdviceListforSelector: selector onClass: class];
    }
}


- (void)dealloc{
	DestroyDictionary(dictionary);
    [super dealloc];
}


@end