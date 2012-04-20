//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

/*
 *    Filename:	PrEditorDocument.m 
 *    Created :	Thu Jan  9 21:31:35 1992 
 *    Author  :	Vince DeMarco
 *		<vince@whatnxt.cuc.ab.ca>
 *    Updated : Michael Forbes
 *      <mforbes@unixg.ubc.ca>
 *    Updated : Eric Zoerner
 *      <eric.zoerner@mac.com>
 *
 * Revision 2.0  1992-08-04  03:43:23  vince
 * Initial-Release
 *
 * Revision 2.1  1992-10-06  14:34:54  vince
 * newLocation function is gone, instead the tileing is done by
 * looking at what is currently on the screen instead.
 *
 * Support for the Contents viewer Object has been added.
 *
 * Bugs in the updateFont method have been fixed the font is
 * now properly set.
 *
 * The disabled scrollers have been removed from the word type
 * display.
 *
 * The entered pronunciation is checked by the Speech objectß
 * if an error occurs this object will put up a panel notifying
 * the user, which character position is wrong.
 * (On the To Do list
 * is to add a textfilter to the Phone Field to ensure that the
 * user can only type in correct things.)
 *
 * Revision 2.2  1995-08-15  Michael Forbes
 * The document object has been stripped of the core of its saving
 * methods and file manipulations are now handled by the PrDict object.
 * The document object still maintains the user interface and coordinates
 * various actions and updates.  Three methods now query various objects
 * like the AppPrefMgr of the application or the text fields about the state
 * of the document and update the interface accordingly.  These methods are:
 *
 * - updateFont
 * - enableKeyboard
 * - makeField:activeAndSelect:
 *
 * These are called by methods that might alter the state of the interface like
 * getPronunciation: and speakWord: which possible make a different field active.
 * The other place these are called are via the delegation-like methods:
 *
 * - userModeDidChange:
 * - fontDidChange:
 *
 * These are sent to every document via the PrEditorApp object and the window
 * delegates.
 *
 * The document no longer maintains a connection to the speech server.  This
 * task has been handed over to the PrEditorApp object.
 *
 * Most of these chnges have been attempted with the following phylosophy:
 * - Manipulations should be carried out by the related objects with the document
 * communicating through a simple interface.  ie. the document gives the dictionary
 * a filename, and the dictionary saves the file in the specified format.
 * - Code to perform specific tasks should be grouped together in one place so that
 * modifications are only needed in a few methods rather than in many spots.
 * - The document should keep an updated interface and be able to respond to outside
 * changes via notification messages.
 * - Features should be expandible. ie. if there are 2 possible file types now, there
 * may be more in the future so 2 should not be hard-wired in.  In this respect,
 * dynamic responses to things like file-types has been considered.
 *
 * Revision X.X 2006-10-13 Eric Zoerner
 * Port from NEXTstep to Mac OS X 10.4 (Tiger)
 * Use of C strings and Foundation classes (such as NXHashTable)
 * changed to use Objective-C Application Kit classes
 * (NSString, NSDictionary, etc.).
 *
 * As part of multilingual support, a move to use IPA and SAMPA-X notation for
 * postures is in progress throughout gnuspeech. This version of PrEditor offers
 * the use of these two notations in addition to the legacy notation ("Trillium")
 * to the user. Support for Websters notation has been eliminated.
 *
 * The keyboard widget was totally removed, favoring the use of the
 * Keyboard Viewer built into OS X combined with the use of an IPA Keyboard
 * layout. When the current notation is set to IPA in the Preferences pane, then
 * when the focus goes into the Phone text field, an IPA Keyboard layout is
 * automatically made active, and when focus leaves, the previous keybord layout
 * is restored. An IPA Keyboard layout is packaged with PrEditor, but any
 * keyboard layout whose name starts with the prefix "IPA" will be used by
 * PrEditor when in IPA mode.
 *
 * BUGS:
 *
 * Some of the display updating is quite slow.  This may be able to be improved slightly
 * with more efficient updating only when neccessary.
 * The accessory view should be dynamically updated based on the list of file types
 * provided by the PrDict object.
 */

#import "PrEditorDocument.h"

#define NUM_PARTS_OF_SPEECH 9
static NSString *KeyboardLayoutPrefix_IPA = @"IPA";

// cache the keyboard layout for IPA
static TISInputSourceRef ipaKeyboardLayoutRef = NULL;

static NSString* PARTS_OF_SPEECH[9] = {
    @"Noun", @"Verb", @"Adjective", @"Adverb", @"Pronoun", @"Article",
    @"Preposition", @"Conjunction", @"Interjection"
};

static NSString* POS_CODES[9] = {
    @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i"
};

static NSString* UnknownPOS = @"j";

@implementation PrEditorDocument

// Class initialization
+ (void)initialize;
{
    if (ipaKeyboardLayoutRef == NULL) {
        [self initIPAKeyboardLayout];
    }
}



- (id)init;
{
    self = [super init];
    if (self) {
        
        // custom initialization goes here
        // if error occurrs, [self release] and return nil
        
        // if this is not from a file...
        prDictionary = [PrDict new]; /* alloc a PrDict Object */  
    }
    return self;
}

- (NSString *)windowNibName;
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document
    // supports multiple NSWindowControllers, you should remove this method and
    // override -makeWindowControllers instead.
    return @"PrEditorDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController;
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}


- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError;
{
    BOOL readSuccess = NO;
    //  NSAttributedString *fileContents = [[NSAttributedString alloc]
    //            initWithData:data options:NULL documentAttributes:NULL
    //                   error:outError];
    //  if (fileContents) {
    //    readSuccess = YES;
    //    [self setText:fileContents];
    //    [fileContents release];
    //  }
    return readSuccess;
}


- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError;
{
//  NSData *data = [textView RTFFromRange:NSMakeRange(0, 
//                                                    [[textView textStorage] length])];
//  if (!data && outError) {
//    *outError = [NSError errorWithDomain:NSCocoaErrorDomain
//                                    code:NSFileWriteUnknownError userInfo:nil];
//  }
//  return data;
    return NULL;
}

/* Store the currently selected word in the dictionary */
- (void)storeWord:(id)sender;
{
    NSString *phone = [phonField stringValue];
    NSString *word = [wordField stringValue];
    NSString *pos;
    NSString *message;
    BOOL inList = NO;
    //  char  *wordtype;
    //  char  dictentry[1024];
    
    //  DEBUG_METHOD;
    
    if ((phone && word) && ([phone length] > 0 && [word length] > 0)) {
        /* Make sure the word and the pronounciation have been
         * entered by the user before trying to save it
         */
        pos = [self getPos:[posField selectedRowIndexes]];
        //    dictEntry = [NSString stringWithFormat: @"%s%%%s", phone, posString];
        
#ifdef DEBUG
        NSLog(@"storeWord: word = %@ phone = %@ pos = %@\n", word, phone, pos);
#endif
        
        if ([prDictionary containsWord: word]) {
            message = [NSString stringWithFormat:
                       @"\"%@\" is already in the Current Dictionary, replacing old entry",
                       word];
            [messageField setStringValue: message];
            NSBeep();
            inList = YES;
        } else {
            message = [NSString stringWithFormat:
                       @"\"%@\" Stored in Current Dictionary", word];
            [messageField setStringValue:message];
        }
        
        [prDictionary setPhone:phone partsOfSpeech:pos forWord:word];
        
        dirty = YES;
        if (!inList) {
            // Update Contents inspector (PrDictViewer)
            // only if a new word has been added to the
            // dictionary, ie inList == NO
            //      [wordList loadDict: prDictionary];
        }
        //    [documentWindow setDocEdited: dirty];
    } else {
        NSBeep();
    }
}


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
{
    return PARTS_OF_SPEECH[rowIndex];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView;
{
    return NUM_PARTS_OF_SPEECH;
}

/***************************************************************************
 * Given an index set obtained from the parts of speech table,
 * construct a string object containing the parts of speech code characters
 * and return it
 ***************************************************************************/
- (NSString *)getPos:(NSIndexSet*)partsOfSpeech;
{
    NSString* s = [NSString string];
    int i;
    
    // if no part of speech is selected, use UnknownPOS
    if ([partsOfSpeech count] == 0) {
        return UnknownPOS;
    }
    
    for (i = 0; i < NUM_PARTS_OF_SPEECH; i++) {
        if ([partsOfSpeech containsIndex: i]) {
            s = [s stringByAppendingString: POS_CODES[i]]; 
        }
    }
    return s;
}

/////////////////////////////////////
//  Notification methods
/////////////////////////////////////

// Notification from the ResponderNotifyingWindow that firstResponder has changed

- (void)window:(ResponderNotifyingWindow*)aWindow madeFirstResponder:(NSResponder*)aResponder;
{
    // if the responder is the phonField or any view within it then swap
    // in the IPA keyboard
    if (aResponder == phonField ||
        ([aResponder isKindOfClass: [NSView class]] &&
         [((NSView*)aResponder) isDescendantOf: phonField])) {
            [self swapInIPAKeyboard];
        }
    else {
        [self swapOutIPAKeyboard];
    }
}

// Notification that the window is becoming or resigning being key

- (void)windowDidBecomeKey:(NSNotification *)aNotification;
{
    ResponderNotifyingWindow* myWindow = [aNotification object];
    [self window:myWindow madeFirstResponder:[myWindow firstResponder]]; 
}

- (void)windowDidResignKey:(NSNotification *)aNotification;
{
    [self swapOutIPAKeyboard];
}

#pragma mark - Keyboard Swapping

- (void)swapInIPAKeyboard;
{
    if (oldKeyboardLayoutRef != NULL) {
        return;
    }
    if (ipaKeyboardLayoutRef != NULL) {
        // save the current keyboard layout
        oldKeyboardLayoutRef = TISCopyCurrentKeyboardLayoutInputSource();
        
        // set the current keyboard layout to be the IPA keyboard layout
        OSStatus osstatus = TISSelectInputSource(ipaKeyboardLayoutRef);
        if (osstatus != noErr) {
            NSLog(@"error in TISSelectInputSource osstatus=%d\n", osstatus);
        }
    } 
    else {
        NSLog(@"Error: PrEditorDocument -swapInIPAKeyboard: ipa layout is NULL");
    }
}


// Notification to end editing
- (void)swapOutIPAKeyboard;
{
    if (oldKeyboardLayoutRef != NULL) {
        if (ipaKeyboardLayoutRef != NULL) {
            // set the current keyboard layout to be the saved layout
            OSStatus osstatus = TISSelectInputSource (oldKeyboardLayoutRef);
            if (osstatus != noErr) {
                NSLog(@"error in KLSetCurrentKeyboardLayout osstatus=%d\n", osstatus);    
            }
            oldKeyboardLayoutRef = NULL;
        } else {
            NSLog(@"Error: PrEditorDocument -swapOutIPAKeyboard: ipa layout is NULL");
        }
    } 
}


// Class method to find and cache the IPA keyboard layout
// Looks for a keyboard layout that starts with the KeyboardLayoutPrefix_IPA

// See <https://developer.apple.com/library/mac/#documentation/TextFonts/Reference/TextInputSourcesReference/Reference/reference.html>
+ (BOOL)initIPAKeyboardLayout;
{
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:(id)kTISTypeKeyboardLayout, kTISPropertyInputSourceType, nil];
    NSArray *keyboards = (NSArray *)TISCreateInputSourceList((CFDictionaryRef)properties, false);
    //NSLog(@"keyboards: %@", keyboards);
    for (id inputSource in keyboards) {
        NSString *name = TISGetInputSourceProperty((TISInputSourceRef)inputSource, kTISPropertyLocalizedName);
        if ([name hasPrefix:KeyboardLayoutPrefix_IPA]) {
            ipaKeyboardLayoutRef = (TISInputSourceRef)inputSource;
            return YES;
        }
    }
    
    // no IPA keyboard layout was found, ref left as NULL
    return NO;
}


@end
