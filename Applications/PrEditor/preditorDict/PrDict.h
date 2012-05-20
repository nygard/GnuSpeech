//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

/*
 *    Filename:	PrDict.h 
 *    Created :	Tue Jan 14 18:01:58 1992 
 *    Author  :	Vince DeMarco
 *		<vince@whatnxt.cuc.ab.ca>
 *    Updated : Michael Forbes
 *      <mforbes@unixg.ubc.ca>
 *
 *
 * Revision 2.0  199208-04  03:43:23  vince
 * Initial-Release
 *
 * Revision 2.1  1992-10-06  14:20:05  vince
 * new method valueAtPos: has been added, so that the nth
 * item in the dictionary can be obtained. Only the key is
 * returned not the data portion of the entry.
 *
 * Revision 2.2  1995-03-08  11:07:00  Michael Forbes
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
 */

#import <Cocoa/Cocoa.h>

#define CURRENT_VERSION 100 

/************** Defines for exception codes used in saveDictToFile: and insertDictFromFile: ****************/
#define PRDICT_badFileType		NX_APP_ERROR_BASE			/* File type not supported. */
#define PRDICT_canNotSaveFile	(NX_APP_ERROR_BASE + 1)	/* File can not be saved.  Stream could not be opened. */
/***********************************************************************************************************/
 

const char *getExtension(const char *fileName);		/* Function to get extension after last "." of fileName. */
char *getNameWithoutExtensionOfFile(char *fileName);	/* Function to get name of file without extension. */

@interface PrDict : NSObject

/* Class Methods */
/* Initiialization */
+ initialize;

/* Supported file type methods. */
+ (const char **)fileTypes;
+ (int)numFileTypes;
+ (int)getTagOfFileType:(const char *)fileName;
+ (BOOL)acceptsFileType:(const char *)fileName;

/* Instance Methods. */
/* Initialization */
- (id)init;
- (id)initWithContentsOfFile:(NSString *)path;

/* Dictionary Methods */
- (void)removeWord:(NSString *)aWord;
- (void)setPhone:(NSString *)phoneString
        partsOfSpeech:(NSString *)posString
        forWord:(NSString *)aWord;
- (NSString *)phoneForWord:(NSString *)aWord;
- (NSString *)partsOfSpeechForWord:(NSString *)aWord;
- (BOOL)containsWord:(NSString *)aWord;
- (unsigned)count;

/* Archiving dictionaries in different formats. */
- (BOOL)writeToFile:(NSString *)path;

/* Archiving PrDict object */
//- awake;
//- write:(NXTypedStream *)stream;
//- read:(NXTypedStream *)stream;

@end




