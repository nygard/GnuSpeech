#import <AppKit/NSResponder.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class NSBrowser, NSFont, NSForm, NSPopUpButton;
@class MonetList;
@class AppController;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================



*/

@interface BrowserManager : NSResponder
{
    IBOutlet NSBrowser *browser;
    IBOutlet AppController *controller;
    IBOutlet NSPopUpButton *popUpList; // TODO (2004-03-04): Looks like this isn't used.

    MonetList *list[5];
    int currentList;

    IBOutlet NSButton *addButton;
    IBOutlet NSButton *renameButton;
    IBOutlet NSButton *removeButton;

    IBOutlet NSForm *nameField;

    NSFont *courierFont;
    NSFont *courierBoldFont;
}

- (void)dealloc;

//- (BOOL)acceptsFirstResponder;
//- (BOOL)becomeFirstResponder;
//- (BOOL)resignFirstResponder;

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (void)setCurrentList:(id)sender;
- (void)updateBrowser;
- (void)updateLists;
- (void)addObjectToCurrentList:tempEntry;

/* Browser Delegate Methods */
- (void)browserHit:(id)sender;
- (void)browserDoubleHit:(id)sender;
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;

// Actions
- (void)add:(id)sender;
- (void)rename:(id)sender;
- (void)remove:(id)sender;

- (void)cut:(id)sender;
- (void)copy:(id)sender;
- (void)paste:(id)sender;

/* Window Delegate Methods */
- (void)windowDidBecomeMain:(NSNotification *)notification;
- (BOOL)windowShouldClose:(id)sender;
- (void)windowDidResignMain:(NSNotification *)notification;

@end
