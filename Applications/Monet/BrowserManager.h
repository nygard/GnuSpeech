#import <AppKit/NSResponder.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class NSBrowser, NSFont, NSForm, NSPopUpButton;
@class MonetList;
@class MyController;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================



*/

@interface BrowserManager : NSResponder
{
    IBOutlet NSBrowser *browser;
    MyController *controller;
    NSPopUpButton *popUpList;

    MonetList *list[5];
    int currentList;

    IBOutlet NSButton *addButton;
    IBOutlet NSButton *renameButton;
    IBOutlet NSButton *removeButton;

    IBOutlet NSForm *nameField;

    NSFont *courier;
    NSFont *courierBold;
}

- (BOOL)acceptsFirstResponder;
- (BOOL)becomeFirstResponder;
- (BOOL)resignFirstResponder;

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (void)setCurrentList:sender;
- (void)updateBrowser;
- (void)updateLists;
- (void)addObjectToCurrentList:tempEntry;


/* Browser Delegate Methods */
- (void)browserHit:sender;
- (void)browserDoubleHit:sender;
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;

- (void)add:sender;
- (void)rename:sender;
- (void)remove:sender;

- (void)cut:(id)sender;
- (void)copy:(id)sender;
- (void)paste:(id)sender;


/* Window Delegate Methods */
- (void)windowDidBecomeMain:(NSNotification *)notification;
- (BOOL)windowShouldClose:(id)sender;
- (void)windowDidResignMain:(NSNotification *)notification;

@end
