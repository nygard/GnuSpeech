
#import <AppKit/AppKit.h>
#import "Inspector.h"
#import "BrowserManager.h"
#import "PhoneList.h"
#import "CategoryList.h"
#import "SymbolList.h"
#import "ParameterList.h"

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================

	Object: MyController
	Purpose: Oversees the functioning of MONET

	Date: March 23, 1994

History:
	March 23, 1994
		Integrated into MONET.

===========================================================================*/

@interface MyController:NSObject
{
	id	inspectorController;
	id	infoPanel;

	PhoneList	*mainPhoneList;
	CategoryList	*mainCategoryList;
	SymbolList	*mainSymbolList;
	ParameterList	*mainParameterList;
	ParameterList	*mainMetaParameterList;

	id	dataBrowser;
	id	ruleManager;
	id	prototypeManager;
	id	transitionBuilder;
	id	specialTransitionBuilder;
	id	stringParser;
	id	eventListView;
	id	intonationView;

	id	defaultManager;

	/* Window pointers */
	id	transitionWindow;
	id	ruleManagerWindow;
	id	phonesWindow;
	id	ruleParserWindow;
	id	prototypeWindow;
	id	synthesisWindow;
	id	specialWindow;
	id	synthParmWindow;

  NSMutableDictionary *namedDict;

}

- init;
- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (void)openFile:(id)sender;
- (void)importTRMData:sender;
- (void)printData:sender;

- (void)displayInfoPanel:sender;
- (void)displayInspectorWindow:sender;
- inspector;

- (void)archiveToDisk:sender;
- (void)readFromDisk:sender;

- (void)savePrototypes:sender;
- (void)loadPrototypes:sender;

/* List maintenance Methods */
- (void)addCategory;
- (void)addParameter;
- (void)addMetaParameter;
- (void)addSymbol;

- (int)removeCategory: (int) index;
- (void)removeParameter:(int)index;
- (void)removeMetaParameter:(int)index;
- (void)removeSymbol:(int)index;

- (void)setObject: object forKey: key;
- objectForKey: key;
- (void)removeObjectForKey: key;

@end

/* Replace some obsolete NeXT functions */
#define NXNameObject(key, object, controller)				\
  [[controller delegate] 						\
    setObject: object forKey: [NSString stringWithCString: key]]

#define NXUnnameObject(key, controller)				\
  [[controller delegate] 					\
    removeObjectForKey: [NSString stringWithCString: key]]

#define NXGetNamedObject(key, controller)                               \
  [[controller delegate] objectForKey: [NSString stringWithCString: key]]

/* NeXT Streams */
#undef NXRead
#define NXRead(fp, buf, size) fread(buf, size, 1, fp)
