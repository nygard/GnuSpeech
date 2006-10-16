/*
 *    Filename:	PrEditorDocument.h 
 *    Created :	Thu Jan  9 21:31:43 1992 
 *    Author  :	Vince DeMarco
 *		<vince@whatnxt.cuc.ab.ca>
 *    Updated : Michael Forbes
 *      <mforbes@unixg.ubc.ca>
 *    Ported to Mac OS X : Eric Zoerner
 *      <eric.zoerner@mac.com>
 *
 *
 * Revision 2.0  1992/04/08  03:43:23  vince
 * Initial-Release
 *
 * Revision 2.1  1992/06/10  14:34:54  vince
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
 * The entered pronunciation is checked by the Speech object
 * if an error occurs this object will put up a panel notifying
 * the user, which character position is wrong. (On the To Do list
                                                 * is to add a textfilter to the Phone Field to ensure that the
                                                 * user can only type in correct things.)
 *
 * Revision 2.2  1995/08/08  Michael Forbes.
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
 * BUGS:
 *
 * Some of the display updating is quite slow.  This may be able to be improved slightly
 * with more efficient updating only when neccessary.
 * The accessory view should be dynamically updated based on the list of file types
 * provided by the PrDict object.
 *
 *
 */

#import <Cocoa/Cocoa.h>
// Carbon needed for KeyboardLayoutRef
#import <Carbon/Carbon.h>

#import "ResponderNotifyingWindow.h"
#import "PrDict.h"

@interface PrEditorDocument: NSDocument
{
  IBOutlet NSTextField* wordField;
  IBOutlet NSTextField* phonField;
  IBOutlet NSTableView* posField;

  // Field to indicate in which knowledge base the pronunciation
  // was found in, and where messages (not error messages)
  // get presented to the user.
  IBOutlet NSTextField* messageField;
  
  IBOutlet NSTableView* wordList;
  
  // Dictionary Object
  PrDict* prDictionary;	
  
  BOOL	dirty;
  KeyboardLayoutRef oldKeyboardLayoutRef;
}

- (void)storeWord:sender;
- (void)window:(ResponderNotifyingWindow*)aWindow madeFirstResponder:(NSResponder*)aResponder;
- (NSString*)getPos:(NSIndexSet*)partsOfSpeech;

- (void)swapInIPAKeyboard;
- (void)swapOutIPAKeyboard;
+ (bool)initIPAKeyboardLayout;


@end

