#import <Foundation/NSObject.h>

#ifdef PORTING
#import "Inspector.h"
#import "BrowserManager.h"
#endif

@class NSMutableDictionary;
@class CategoryList, ParameterList, PhoneList, SymbolList;

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

@interface MyController : NSObject
{
    id inspectorController;
    id infoPanel;

    PhoneList *mainPhoneList;
    CategoryList *mainCategoryList;
    SymbolList *mainSymbolList;
    ParameterList *mainParameterList;
    ParameterList *mainMetaParameterList;

    id dataBrowser;
    id ruleManager;
    id prototypeManager;
    id transitionBuilder;
    id specialTransitionBuilder;
    id stringParser;
    id eventListView;
    id intonationView;

    id defaultManager;

    /* Window pointers */
    id transitionWindow;
    id ruleManagerWindow;
    id phonesWindow;
    id ruleParserWindow;
    id prototypeWindow;
    id synthesisWindow;
    id specialWindow;
    id synthParmWindow;

    NSMutableDictionary *namedDict;
}

- (id)init;
- (void)applicationDidFinishLaunching:(NSNotification *)notification;

- (void)displayInfoPanel:(id)sender;
- (void)displayInspectorWindow:(id)sender;
- inspector;

- (void)openFile:(id)sender;
- (void)importTRMData:(id)sender;
- (void)printData:(id)sender;


- (void)archiveToDisk:(id)sender;
- (void)readFromDisk:(id)sender;

- (void)savePrototypes:(id)sender;
- (void)loadPrototypes:(id)sender;

/* List maintenance Methods */
- (void)addCategory;
- (void)addParameter;
- (void)addMetaParameter;
- (void)addSymbol;

- (int)removeCategory:(int)index;
- (void)removeParameter:(int)index;
- (void)removeMetaParameter:(int)index;
- (void)removeSymbol:(int)index;

- (void)setObject:(id)object forKey:(id)key;
- (id)objectForKey:(id)key;
- (void)removeObjectForKey:(id)key;

@end

/* Replace some obsolete NeXT functions */
#define NXNameObject(key, object, controller) \
  [[controller delegate] setObject:object forKey:key]

#define NXUnnameObject(key, controller) \
  [[controller delegate] removeObjectForKey:key]

#define NXGetNamedObject(key, controller) \
  [[controller delegate] objectForKey:key]

/* NeXT Streams */
#undef NXRead
#define NXRead(fp, buf, size) fread(buf, size, 1, fp)
