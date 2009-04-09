////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: Vince DeMarco, Eric Zoerner, Dalmazio Brisinda
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
////////////////////////////////////////////////////////////////////////////////
//
//  PrDict.h
//  PrEditor
//
//  Created by Eric Zoerner on 03/06/2006.
//
//	Version: 0.1
//
////////////////////////////////////////////////////////////////////////////////

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

@interface PrDict:NSObject
{
    NSMutableDictionary*  dictionary;
    BOOL  has_changed;
}

/* Class Methods */
/* Initiialization */
+ initialize;

/* Supported file type methods. */
+ (const char **)fileTypes;
+ (int)numFileTypes;
+ (int)getTagOfFileType:(const char *)fileName;
+ (BOOL)acceptsFileType:(const char*)fileName;

/* Instance Methods. */
/* Initialization */
- init;
- (id)initWithContentsOfFile:(NSString *)path;

/* Dictionary Methods */
- (void)removeWord:(NSString*)aWord;
- (void)setPhone:(NSString*)phoneString
        partsOfSpeech:(NSString*)posString
        forWord:(NSString*)aWord;
- (NSString*)phoneForWord:(NSString*)aWord;
- (NSString*)partsOfSpeechForWord:(NSString*)aWord;
- (BOOL)containsWord:(NSString*)aWord;
- (unsigned)count;

/* Archiving dictionaries in different formats. */
- (BOOL)writeToFile:(NSString *)path;

/* Archiving PrDict object */
//- awake;
//- write:(NXTypedStream *)stream;
//- read:(NXTypedStream *)stream;

@end




