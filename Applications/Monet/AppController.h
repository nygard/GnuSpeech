//
// $Id: AppController.h,v 1.5 2004/03/05 03:38:14 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class NSMutableDictionary;
@class CategoryList, ParameterList, PhoneList, StringParser, SymbolList;
@class BrowserManager, DefaultMgr, EventListView, Inspector, IntonationView, PrototypeManager, RuleManager, TransitionView;

@interface AppController : NSObject
{
    //Inspector *inspectorController;
    //NSPanel *infoPanel;

    NSMutableDictionary *namedObjects;

    PhoneList *mainPhoneList;
    CategoryList *mainCategoryList;
    SymbolList *mainSymbolList;
    ParameterList *mainParameterList;
    ParameterList *mainMetaParameterList;

    IBOutlet BrowserManager *dataBrowser;
    IBOutlet RuleManager *ruleManager;
    IBOutlet PrototypeManager *prototypeManager;
    IBOutlet TransitionView *transitionBuilder;
    IBOutlet TransitionView *specialTransitionBuilder;
    IBOutlet StringParser *stringParser;
    //IBOutlet EventListView *eventListView;
    IBOutlet IntonationView *intonationView; // TODO (2004-03-03): This might be an NSScrollView.

    //DefaultMgr *defaultManager;

    /* Window pointers */
    //IBOutlet NSWindow *transitionWindow;
    //IBOutlet NSWindow *ruleManagerWindow;
    //IBOutlet NSWindow *phonesWindow;
    //IBOutlet NSWindow *ruleParserWindow;
    //IBOutlet NSWindow *prototypeWindow;
    //IBOutlet NSWindow *synthesisWindow;
    //IBOutlet NSWindow *specialWindow;
    //IBOutlet NSWindow *synthParmWindow;
}

- (id)init;
- (void)dealloc;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;

- (void)setObject:(id)object forKey:(id)key;
- (id)objectForKey:(id)key;
- (void)removeObjectForKey:(id)key;

@end
