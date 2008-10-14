/*
 *    Filename:	PrDict.m 
 *    Created :	Tue Jan 14 18:02:35 1992 
 *    Author  :	Vince DeMarco
 *		<vince@whatnxt.cuc.ab.ca>
 *    Updated : Michael Forbes
 *      <mforbes@unixg.ubc.ca>
 *
 *
 * Revision 2.0  1992/04/08  03:43:23  vince
 * Initial-Release
 *
 * Revision 2.1  1992/06/10  14:20:05  vince
 * new method valueAtPos: has been added, so that the nth
 * item in the dictionary can be obtained. Only the key is
 * returned not the data portion of the entry.
 *
 * Revision 2.2  1995/08/04  3;29:00   Michael Forbes
 * Now supports .ded files, and contains all the necessary
 * routines to save and insert files.  It should now be
 * possible for applications to use the methods fileTypes and
 * numFileTypes to query the PrDict object about supported file
 * types and then by supplying the filnames, have the dictionary
 * saved in any supported format (or inserted.)
 *
 * To add support to new formats, only the PrDict object need be
 * modified.  This makes the dictionary more of an encapsulated
 * object than before.
 * The following must be updated:
 * - insertDictFromFile:
 * - saveDictToFile:
 * - initFileTypes
 *
 * Revision X.X 2006-10-13  Eric Zoerner
 * Port to Cocoa
 * Abstracted out phone and partsOfSpeech, whereas previously they were passed
 * in as a combined string with "%%" between them as separator. Now PrDict
 * encapsulates the storage format
 *
 * BUGS:
 *
 * The insert method should have a filter so that invalid entries are
 * not entered.  Right now, if a .ded file is opened that is not in the
 * correct format, entries may be added that when used cause the application
 * to crash.
 * 
 *
 *
 */

#import "PrDict.h"
#import "PrEntry.h"

//#import "conversion.h" /* Preditor to TTS conversions and vice versa. */
 
/* To add a new file type, insert it's extension here.
 * Then insert a save method into the if - else if chain in saveToFile: method.
 * Then insert an insert method into the if - else if chain in readFromFile: method.
 * Then update the accessory view of Document.nib and the open method of PrEditorApp.m.
 * Hopefully, these will be converted so thay are automatically allocated by querying the PrDict object.
 */
static const char **fileTypes = (const char *[]){"preditor",
				 								 "ded",
												 NULL};	 /* fileTypes is an array of supported file extensions. */

@implementation PrDict

+ initialize
{
    [PrDict setVersion:CURRENT_VERSION];
    return self;
}

/* fileTypes.
 * Returns a pointer to a null terminated list of valid file types.
 */
+ (const char **)fileTypes
{
	return fileTypes;
}

/* numFileTypes.
 * Returns the number of supported file types.
 */
+ (int)numFileTypes
{
	int i = 0;
	while(fileTypes[i])
		i++;
	return i;
}

/* getTagOfFileType:
 * Returns the tag number associated with the extension on the file.
 * The tag number is it's position in the fileTypes array.
 * Returns -1 if type is not valid or in array.
 */
+ (int)getTagOfFileType:(const char *)fileName
{
	const char *extension;
	int i = 0;
	
	extension = getExtension(fileName);
	
	while(fileTypes[i]){
		if (strcmp(extension, fileTypes[i]) == 0)	/* Checks to see if extension is a supported type. */
			return i;
		i++;
	}		
	
	return -1;		/* File type not supported. */
}

/* acceptsFileType:fileName
 * Returns YES if fileName has a valid extension.
 * Returns NO if the extension is not supported.
 */
+ (BOOL)acceptsFileType:(const char*)fileName
{
	if ([self getTagOfFileType:fileName] > -1)	/* The type has a tag if it is in the fileTypes array. */
		return YES;
	else
		return NO;			/* extension was not on the list. */
}


- init
{
  self = [super init];
  if (self) {
    
    // custom initialization goes here
    // if error occurrs, [self release] and return nil
    
    //	hashTableZone = NXCreateZone(	vm_page_size,
    //									vm_page_size,
    //									NO);
    //    contentsZone  = NXCreateChildZone(	hashTableZone,
    //										vm_page_size,
    //										vm_page_size,
    //										NO);
    //    NXNameZone(	hashTableZone,
    //				"PrDict Object hashTableZone");
    //    NXNameZone(	contentsZone,
    //				"PrDict Object Contents Viewer Zone");
    //    hashTable = NXCreateHashTableFromZone(NXStrStructKeyPrototype,
    //										  10,
    //										  "PrDict Object",
    //										  hashTableZone);
    dictionary = [NSMutableDictionary new];   
    has_changed = NO;
//    word_list   = NULL;
  }
  return self;
}

/* Dictionary Methods */
- (void)setPhone:(NSString*)phoneString partsOfSpeech:(NSString*)posString
        forWord:(NSString*)aWord;
{
  PrEntry* entry = [[PrEntry alloc] init];
  
  entry->phone = phoneString;
  entry->partsOfSpeech = posString;
  
  [dictionary setObject:entry forKey:aWord];
	has_changed = YES;
}

- (void)removeWord:(NSString*)aWord
{
  [dictionary removeObjectForKey:aWord];
  has_changed = YES;
}

- (BOOL)containsWord:(NSString*)aWord
{
  return [dictionary objectForKey:aWord] != nil;
}

- (NSString*)phoneForWord:(NSString*)aWord
{
  return ((PrEntry*)[dictionary objectForKey:aWord])->phone;  
}

- (NSString*)partsOfSpeechForWord:(NSString*)aWord
{
  return ((PrEntry*)[dictionary objectForKey:aWord])->partsOfSpeech;    
}

- (unsigned)count
{
  return [dictionary count];
}


/* getExtension().  Returns a pointer to the file name extension.  Returns whole fileName if there is no "." */
const char *getExtension(const char *fileName)
{
	const char *extension;

	if (extension = strrchr(fileName, '.'))	/* extension points to the last '.' in the string, */
		return ++extension;
	else
		return fileName;
}

/* getNameWithoutExtensionOfFile().  Returns a pointer to the file name and places a null terminator at the last "."*/
char *getNameWithoutExtensionOfFile(char *fileName)
{
	char *extension;
	
	if (extension = strrchr(fileName, '.')){	/* extension points to the last '.' in the string, */
		*extension = '\000';					/* Sets end of string */
		return fileName;
	}
	else
		return fileName;
	
}

///* Get the positionth word in the Dictionary Returns only the key not the pronuncation*/
//- (const char *)valueAtPos:(int) position
//{
//    char           *word;
//    wordHashStruct *entry;
//    NXHashState     state;
//    int             i =0;
//
//    if (has_changed == YES){
//		has_changed = NO;
//		state = NXInitHashState(hashTable);
//
//		/* Here Vince copies the contents of the hash table into word_list which is an array of 
//		 * pointers to char, this is done because the hash table routines can rearange
//		 * the data, ie move it around as insertions and deletions occur.
//		 * He knows that this is slow, but it is only done when the contents of the hash
//		 * table actually change.
//		 *
//		 * word_list isn't in a ChildZone this is to ensure that all relevant info will
//		 * be on the same page in memory, and by using a child zone, he can just destroy
//		 * the zone instead of iterating over everything to kill the zone.
//		 */
//		NXDestroyZone(contentsZone);
//		contentsZone = NXCreateChildZone(hashTableZone,
//										 vm_page_size,
//										 vm_page_size,
//										 NO);
//		NXNameZone(	contentsZone,
//					"PrDict Object Contents Viewer Zone");
//		word_list = NXZoneMalloc(contentsZone,
//								 sizeof(char *) * [self count] + 1);
//		if(word_list){
//		    while (NXNextHashState(hashTable,
//								   &state,
//								   (void **)&entry)){
//									
//				/* The following lines did not allocate the extra byte
//				 * for the null terminator character and this caused problems
//				 * on the white hardware. */
//				word = NXZoneMalloc(contentsZone,
//									sizeof(char) * (strlen(entry->key) + 1));
//
//				strcpy(word, entry->key);
//				word_list[i++] = word;
//		    }
//		    quicksort(word_list, 0, i - 1);
//		}
//		else{
//	   		return NULL;
//		}
//    }
//    if ((position < [self count]) && word_list[position])
//		return word_list[position];
//    else
//        return NULL;
//}

/* Archiving dictionaries in different formats. */

/* saveDictToFile:fileName
 * Saves the dictionary to the file fileName in the format specified by the extension.
 * fileName must be include the complete path.
 * Returns self if dictionary was saved.
 * If not successful raises an exception.
 */
- (BOOL)writeToFile:(NSString *)path
{
//	const char *extension;
//	
//	extension = getExtension(fileName);		/* Gets the extension of the fileName. */
//	
//	if (strcmp(extension, "preditor") == 0){		/* Save file as PrEditor Type. */
//											/* This code was copied from PrEditorDocument.m with few modifications. */
//    	
//		NXTypedStream *volatile stream = NULL;	/* Stream declared volatile because it is used
//					    						 * within the exception handling code
//												 * Which is essentually a setjmp and longjmp
//												 */
//		/* Exceptions thrown should be caught bu the calling routine. */
//		
//		stream = NXOpenTypedStreamForFile(fileName, NX_WRITEONLY);
//    	if (stream){
//		    NXSetTypedStreamZone(stream, [self zone]);
//		    /* NXWriteObject(stream, self); */
//		    NXWriteRootObject(stream, self);
//		    NXCloseTypedStream(stream);
//		}
//		else{
//			NX_RAISE(PRDICT_canNotSaveFile, "Can not save file.  Stream can not be opened.", NULL);
//			/* Raises an exception if the file can not be saved. */
//			return nil;
//		}
//
//    	return self;
//	}
//	else if (strcmp(extension, "ded") == 0){		/* Save file as ded type. */
//		int fd;		/* The file descriptor. */
//		NXStream *volatile stream = NULL;	/* Stream declared volatile because it is used
//					    					 * within the exception handling code
//											 * Which is essentually a setjmp and longjmp
//											 */
//		
//		fd = open(fileName, O_WRONLY|O_CREAT|O_TRUNC, 0666);	/* Open a file and assign its descriptoe to fd.
//																 * If the file does not exist, a new one will
//																 * becreated.  If a file exists, it will be
//																 * replaced. */
//		if (fd < 0){
//			NX_RAISE(PRDICT_canNotSaveFile, "Can not save file.  File can not be opened.", NULL);
//			/* Raises an exception if the file can not be saved. */
//			return nil;
//		}
//		
//		stream = NXOpenFile(fd, NX_WRITEONLY);
//		if (stream){
//			unsigned int c;
//			const char *key;
//			const char *data;
//		
//			NX_DURING		/* Simple handler to close stream if an exception occurs. */
//
//				for (c = 0; c < [self count]; c++){
//					key = [self valueAtPos:c];
//					data = [self valueForKey:key];
//					NXPrintf(stream, "%s %s\n", key, PreditorToTTS(data));
//				}
//			
//			NX_HANDLER		/* Simple handler to close stream if an exception occurs. */
//
//				NXClose(stream);
//				close(fd); 
//				NX_RERAISE();
//				return nil;
//				
//			NX_ENDHANDLER
//			
//			NXClose(stream);
//			close(fd); 
//
//		}
//		else{
//			NX_RAISE(PRDICT_canNotSaveFile, "Can not save file.  Stream can not be opened.", NULL);
//			/* Raises an exception if the file can not be saved. */
//			return nil;
//		}
//	}
//	else{
//		NX_RAISE(PRDICT_badFileType, "File type is not yet supported.", fileName);
//		/* Raises an exception if the file type is not supported. */
//		return nil;
//	}
//	return self;
  return NO;
}

- (id)initWithContentsOfFile:(NSString *)path
{
//	const char *extension;
//	NXStream *volatile stream = NULL;	/* Stream declared volatile because it is used
//										 * within the exception handling code
//										 * Which is essentually a setjmp and longjmp
//										 */
//	
//	extension = getExtension(fileName);		/* Gets the extension of the fileName. */
//	
//	if (strcmp(extension, "preditor") == 0){	/* Insert file as preditor Type. */
//		/* This works by creating a local instance of PrDict object loaded
//		 * from disk and then transfers the contents to this instance.
//		 */
//		
//		unsigned int i, c;
//		const char *word;
//		id tempDict = nil;
//		NXTypedStream *volatile typedStream = NULL;	/* Stream declared volatile because it is used
//													 * within the exception handling code
//													 * Which is essentually a setjmp and longjmp
//													 */
//		
//		NX_DURING		/* Simple handler to close stream if an exception occurs. */
//	
//			/* Load the file from disk from file: fileName */
//			/* Load hashTable from disk */
//	    	typedStream = NXOpenTypedStreamForFile(fileName, NX_READONLY);
//	    	if (typedStream){
//				NXSetTypedStreamZone(typedStream, [self zone]);
//				tempDict = NXReadObject(typedStream);
//				NXCloseTypedStream(typedStream);
//	    	}
//	
//		NX_HANDLER
//
//		    if (typedStream)	/* Deallocate memory */
//				NXCloseTypedStream(typedStream);
//		
//			if (tempDict)		/* Deallocate memory */
//				[tempDict free];
//		   	
//			NX_RERAISE();		/* Reraise exception. */
//
//			return nil;	
//		
//		NX_ENDHANDLER
//		
//		c = [tempDict count];
//		for (i = 0; i < c; i++){	/* For all the words in the temp dictionary. */
//			word = [tempDict valueAtPos:i];	/* Get the key. */
//			[self insertKey:word data:[tempDict valueForKey:word]];	/* Insert the key and data into this dictionary. */
//		}
//		
//		[tempDict free];	/* Free tempDict object. */
//		    
//    } /* if (strcmp(getExtension(fileName), "preditor") != 0) */	
//	else if (strcmp(extension, "ded") == 0){		/* Insert file as ded Type. */
//		char wordToken[MAX_WORD_LENGTH];
//		char pronunciationToken[MAX_WORD_LENGTH];
//		int count;
//		
//		stream = NXMapFile(fileName, NX_READONLY);
//		
//		if (stream){
//			int done = NO;
//			
//			NX_DURING		/* Simple handler to close stream if an exception occurs. */
//
//				while(!done){
//					if (NXScanf(stream, "%s ", wordToken) == 1){
//						count = 0;
//						do{
//							pronunciationToken[count] = NXGetc(stream);
//						} while (	(pronunciationToken[count] != '\n') &&	/* Quit on newline or end of file. */
//									(pronunciationToken[count] != EOF) &&
//									(++count < MAX_WORD_LENGTH));
//						if (pronunciationToken[count - 1] == EOF)
//							done = YES;
//						pronunciationToken[count] = '\000';	/* Null terminate the string. */
//						[self insertKey:wordToken data:TTSToPreditor((const char *)pronunciationToken)];
//					}
//					else
//						done = YES;
//				}
//						
//			NX_HANDLER		/* Simple handler to close stream if an exception occurs. */
//				
//				if (stream)
//					NXClose(stream);
//				NX_RERAISE();
//				return nil;
//				
//			NX_ENDHANDLER
//			
//			NXClose(stream);
//		}
//		else{
//			NX_RAISE(PRDICT_canNotSaveFile, "Can not open file.  Stream can not be opened.", NULL);
//			/* Raises an exception if the file can not be opened. */
//			return nil;
//		}			
//	}
//	else{
//		NX_RAISE(PRDICT_badFileType, "File type is not yet supported.", fileName);
//		/* Raises an exception if the file type is not supported. */
//		return nil;
//	}
	return self;
}

/* Archiving PrDict object */

//- awake
//{
//    [super awake];
//    
//	//[self initFileTypes];
//
//	if (!contentsZone){ /* The awake method can be called multiple times so this needs to
//						 * be in the if statement, that way we will not created an excess
//						 * number of zones
//						 */
//		contentsZone = NXCreateChildZone(	hashTableZone,
//											vm_page_size,
//											vm_page_size,
//											NO);
//		NXNameZone(	contentsZone,
//					"PrDict Object Contents Viewer Zone");
//    }
//    has_changed = YES;
//    word_list = NULL;
//    return self;
//}
//
//- write:(NXTypedStream *)stream
//{
//    wordHashStruct *entry;
//    unsigned        count = NXCountHashTable(hashTable);
//    NXHashState     state = NXInitHashState(hashTable);
//    int keysize, datasize;
//
//    [super write:stream]; 
//    /* WriteOut number of elements in hash table */
//	NXWriteTypes(	stream,
//				"i",
//				&count);
//    while (NXNextHashState(	hashTable,
//							&state,
//							(void **)&entry)){
//		
//		/* The following two lines did not allocate the extra byte
//		 * for the null terminator character and this cauesed problems
//		 * on the white hardware. */
//		
//		keysize  = strlen(entry->key) + 1;
//		datasize = strlen(entry->data) + 1;
//
//		NXWriteTypes(	stream,
//						"ii",
//						&keysize,
//						&datasize);
//		NXWriteArray(	stream,
//						"c",
//						keysize,
//						entry->key);
//		NXWriteArray(	stream,
//						"c",
//						datasize,
//						entry->data);
//    }
//    return self;
//}
//
//- read:(NXTypedStream *)stream
//{
//    unsigned int    count;
//    unsigned int    i=0;
//    wordHashStruct *entry;
//    int             keysize, datasize;
//    int             versionNumber;
//
//    [super read:stream];
//    if ((versionNumber = NXTypedStreamClassVersion(stream, "PrDict")) == [PrDict version]) {
//		NXReadTypes(stream, "i", &count);
//		if (!hashTableZone){	/* This is called because when a object is unarchived it is assummed that
//				     			 * You don't need to call init, because you will be initializing all of
//				     			 * the relevant datastructures from disk
//			    	 			 */
//	    	hashTableZone = NXCreateZone(vm_page_size, vm_page_size, NO); 
//	    	NXNameZone(hashTableZone,
//					   "PrDict Object hashTableZone");
//	    	hashTable = NXCreateHashTableFromZone(NXStrStructKeyPrototype,
//												  count * 2,
//												  "PrDict Object",
//												  hashTableZone);
//		}
//		while(i < count){
//	   		NXReadTypes(stream,
//						"ii",
//						&keysize,
//						&datasize);
//	    	entry       = NXZoneMalloc(hashTableZone,
//									   sizeof(wordHashStruct));
//	    	entry->key  = NXZoneMalloc(hashTableZone,
//									   sizeof(char)*keysize);
//	    	entry->data = NXZoneMalloc(hashTableZone,
//									   sizeof(char)*datasize);
//	   		NXReadArray(stream,
//						"c",
//						keysize,
//						entry->key);
//	    	NXReadArray(stream,
//						"c",
//						datasize,
//						entry->data);
//	    	NXHashInsert(hashTable,entry);
//	    	i++;
//		}
//    } /* Must be older version or something */
//    return self;
//}

@end