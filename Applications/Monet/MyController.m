
#import "MyController.h"
#import "PrototypeManager.h"
#import "RuleManager.h"

@implementation MyController

- init
{
#ifdef HAVE_DSP
	initialize_synthesizer_module();
#endif
	initStringParser();
	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
#ifdef NeXT
  NXTypedStream *stream= 0;
#else
  NSArchiver *stream= 0;
#endif

	mainPhoneList = [[PhoneList alloc] initWithCapacity:15];
	mainCategoryList = [[CategoryList alloc] initWithCapacity: 15];
	mainSymbolList = [[SymbolList alloc] initWithCapacity: 15];
	mainParameterList = [[ParameterList alloc] initWithCapacity:15];
	mainMetaParameterList = [[ParameterList alloc] initWithCapacity:15];

	[mainSymbolList addNewValue:"duration"];

	NXNameObject("mainPhoneList", mainPhoneList, NSApp);
	NXNameObject("mainCategoryList", mainCategoryList, NSApp);
	NXNameObject("mainSymbolList", mainSymbolList, NSApp);
	NXNameObject("mainParameterList", mainParameterList, NSApp);
	NXNameObject("mainMetaParameterList", mainMetaParameterList, NSApp);

	NXNameObject("ruleManager", ruleManager, NSApp);
	NXNameObject("prototypeManager", prototypeManager, NSApp);
	NXNameObject("transitionBuilder", transitionBuilder, NSApp);
	NXNameObject("specialTransitionBuilder", specialTransitionBuilder, NSApp);
	NXNameObject("intonationView", intonationView, NSApp);
	NXNameObject("stringParser",stringParser, NSApp);

	[[mainCategoryList addCategory:"phone"] setComment:"This is the static phone category.  It cannot be changed or removed"];

	[dataBrowser applicationDidFinishLaunching: notification];
	if (inspectorController)
		[inspectorController applicationDidFinishLaunching: notification];

	[prototypeManager applicationDidFinishLaunching: notification];

#ifdef NeXT	
	stream = 
	  NXOpenTypedStreamForFile("DefaultPrototypes", NX_READONLY);
	if (stream)
	  {
	    [prototypeManager _readPrototypesFrom:stream];
	    NXCloseTypedStream(stream);
	  }
#else
	stream = [[NSUnarchiver alloc] initForReadingWithData:
		     [NSData dataWithContentsOfFile:@"DefaultPrototypes"]];
	if (stream)
	{
		[prototypeManager readPrototypesFrom:stream];
		[stream release];
	}
#endif

	[ruleManager applicationDidFinishLaunching: notification];
	[transitionBuilder applicationDidFinishLaunching: notification];
	[specialTransitionBuilder applicationDidFinishLaunching: notification];
	[eventListView applicationDidFinishLaunching: notification];
	[intonationView applicationDidFinishLaunching: notification];

	[stringParser applicationDidFinishLaunching: notification];

	[transitionWindow setFrameAutosaveName:@"TransitionWindow"];
	[ruleManagerWindow setFrameAutosaveName:@"RuleManagerWindow"];
	[phonesWindow setFrameAutosaveName:@"DataEntryWindow"];
	[ruleParserWindow setFrameAutosaveName:@"RuleParserWindow"];
	[prototypeWindow setFrameAutosaveName:@"PrototypeManagerWindow"];
	[synthesisWindow setFrameAutosaveName:@"SynthesisWindow"];
	[specialWindow setFrameAutosaveName:@"SpecialTransitionWindow"];
	[synthParmWindow setFrameAutosaveName:@"SynthParameterWindow"];
}

- (void)displayInfoPanel:sender
{
	if (!infoPanel)
	{
		[NSBundle loadNibNamed:@"Info.nib" owner:self];
	}

	[infoPanel makeKeyAndOrderFront:self]; 
}

- (void)displayInspectorWindow:sender
{
	if (!inspectorController)
	{
		[NSBundle loadNibNamed:@"Inspector.nib" owner:self];
		[inspectorController applicationDidFinishLaunching:sender];
	}

	[[inspectorController window] makeKeyAndOrderFront:self]; 
}

- inspector
{
	return inspectorController;
}


- (void)openFile:(id)sender;
{
int i, count;
NSArray *types;
NSArray *fnames;
NSString *directory;
char buf[1024+1];
FILE *fp;
unsigned int magic;

	types = [NSArray arrayWithObject: @"degas"];
	[[NSOpenPanel openPanel] setAllowsMultipleSelection:NO];
	if ([[NSOpenPanel openPanel] runModalForTypes:types])
	{
		fnames = [[NSOpenPanel openPanel] filenames];
		directory = [[NSOpenPanel openPanel] directory];
		count = [fnames count];
		for (i = 0; i < count; i++)
		{
			strcpy(buf, [directory cString]);
			strcat(buf, "/");
			strcat(buf, [[fnames objectAtIndex: i] cString]);

			fp = fopen(buf, "r");

			fread(&magic, sizeof(int), 1, fp);
			if (magic == 0x2e646567)
			{
				printf("Loading DEGAS File \n");
				[mainParameterList readDegasFileFormat:fp];
				[mainCategoryList readDegasFileFormat:fp];
				[mainPhoneList readDegasFileFormat:fp];
				[ruleManager readDegasFileFormat:fp];
				[dataBrowser updateBrowser];
			}
			else
			{
				printf("Not a DEGAS file \n");
			}
			fclose(fp);
		}
	}
}

- (void)importTRMData:sender
{
	[mainPhoneList importTRMData:sender]; 
}

- (void)printData:sender
{
const char *temp;
NSSavePanel *myPanel;
FILE *fp;

	myPanel = [NSSavePanel savePanel];
	if ([myPanel runModal])
	{
		temp = [[myPanel filename] cString];
		fp = fopen(temp,"w");
		if (fp)
		{
			[mainCategoryList printDataTo:fp];
			[mainParameterList printDataTo:fp];
			[mainSymbolList printDataTo:fp];
			[mainPhoneList printDataTo:fp];
			fclose(fp);
		}
	} 
}

- (void)archiveToDisk:sender
{
const char *temp;
NSMutableData *mdata;
NSSavePanel *myPanel;
NSArchiver *stream;

	myPanel = [NSSavePanel savePanel];
	if ([myPanel runModal])
	{
		temp = [[myPanel filename] cString];
		printf("Temp = |%s|\n", temp);

		mdata = [NSMutableData dataWithCapacity: 16];
		stream = [[NSArchiver alloc] 
			initForWritingWithMutableData: mdata];

		if (stream)
		{
			[stream setObjectZone: [self zone]];
			[stream encodeRootObject:mainCategoryList];
			[stream encodeRootObject:mainSymbolList];
			[stream encodeRootObject:mainParameterList];
			[stream encodeRootObject:mainMetaParameterList];
			[stream encodeRootObject:mainPhoneList];
			[prototypeManager writePrototypesTo:stream];
			[ruleManager writeRulesTo:stream];
			[mdata writeToFile: [myPanel filename] atomically: NO];
			[stream release];
		}
		else
		{
			printf("Not a MONET file\n");
		}
	} 
}

#ifndef NeXT
- (void)readFromDisk:sender
{
  int i, count;
NSArray *types;
NSArray *fnames;
NSString *directory;
char buf[MAXPATHLEN+1];
NSArchiver *stream;

	types = [NSArray arrayWithObject: @"monet"];
	[[NSOpenPanel openPanel] setAllowsMultipleSelection:NO];
	if ([[NSOpenPanel openPanel] runModalForTypes:types])
	{
		fnames = [[NSOpenPanel openPanel] filenames];
		directory = [[NSOpenPanel openPanel] directory];
		count = [fnames count];
		for (i = 0; i < count; i++)
		{
			strcpy(buf, [directory cString]);
			strcat(buf, "/");
			strcat(buf, [[fnames objectAtIndex: i] cString]);

			stream = [[NSUnarchiver alloc] initForReadingWithData:[NSData dataWithContentsOfFile: [NSString stringWithCString: buf]]];

			if (stream)
			{
				NXUnnameObject("mainCategoryList", NSApp);
				NXUnnameObject("mainSymbolList", NSApp);
				NXUnnameObject("mainParameterList", NSApp);
				NXUnnameObject("mainMetaParameterList", NSApp);
				NXUnnameObject("mainPhoneList", NSApp);

				[mainPhoneList release];
				[mainCategoryList release];
				[mainSymbolList release];
				[mainParameterList release];
				[mainMetaParameterList release];

				/* Category list must be named immediately */
				mainCategoryList = [[stream decodeObject] retain];
				NXNameObject("mainCategoryList", mainCategoryList, NSApp);

				mainSymbolList = [[stream decodeObject] retain];
				mainParameterList = [[stream decodeObject] retain];
				mainMetaParameterList = [[stream decodeObject] retain];
				mainPhoneList = [[stream decodeObject] retain];

				NXNameObject("mainSymbolList", mainSymbolList, NSApp);
				NXNameObject("mainParameterList", mainParameterList, NSApp);
				NXNameObject("mainMetaParameterList", mainMetaParameterList, NSApp);
				NXNameObject("mainPhoneList", mainPhoneList, NSApp);

				[prototypeManager readPrototypesFrom:stream];
				[ruleManager readRulesFrom:stream];


				[dataBrowser updateLists];

				[dataBrowser updateBrowser];
				[transitionBuilder applicationDidFinishLaunching: nil];
				[specialTransitionBuilder applicationDidFinishLaunching: nil];

				[stream release];
				initStringParser();
			}
			else
			{
				printf("Not a MONET file\n");
			}

		}
	} 
}

#else
- (void)readFromDisk:sender
{
  int i, count;
NSArray *types;
NSArray *fnames;
NSString *directory;
char buf[1024+1];
NXTypedStream *stream;

	types = [NSArray arrayWithObject: @"monet"];
	[[NSOpenPanel openPanel] setAllowsMultipleSelection:NO];
	if ([[NSOpenPanel openPanel] runModalForTypes:types])
	{
		fnames = [[NSOpenPanel openPanel] filenames];
		directory = [[NSOpenPanel openPanel] directory];
		count = [fnames count];
		for (i = 0; i < count; i++)
		{
			strcpy(buf, [directory cString]);
			strcat(buf, "/");
			strcat(buf, [[fnames objectAtIndex: i] cString]);

			stream = NXOpenTypedStreamForFile(buf, NX_READONLY);

			if (stream)
			{
				NXUnnameObject("mainCategoryList", NSApp);
				NXUnnameObject("mainSymbolList", NSApp);
				NXUnnameObject("mainParameterList", NSApp);
				NXUnnameObject("mainMetaParameterList", NSApp);
				NXUnnameObject("mainPhoneList", NSApp);

				[mainPhoneList release];
				[mainCategoryList release];
				[mainSymbolList release];
				[mainParameterList release];
				[mainMetaParameterList release];

				/* Category list must be named immediately */
				mainCategoryList = NXReadObject(stream);
				NXNameObject("mainCategoryList", mainCategoryList, NSApp);

				mainSymbolList = NXReadObject(stream);
				mainParameterList = NXReadObject(stream);
				mainMetaParameterList = NXReadObject(stream);
				mainPhoneList = NXReadObject(stream);

				NXNameObject("mainSymbolList", mainSymbolList, NSApp);
				NXNameObject("mainParameterList", mainParameterList, NSApp);
				NXNameObject("mainMetaParameterList", mainMetaParameterList, NSApp);
				NXNameObject("mainPhoneList", mainPhoneList, NSApp);

				[prototypeManager _readPrototypesFrom:stream];
				[ruleManager _readRulesFrom:stream];


				[dataBrowser updateLists];

				[dataBrowser updateBrowser];
				[transitionBuilder applicationDidFinishLaunching: nil];
				[specialTransitionBuilder applicationDidFinishLaunching: nil];
				NXCloseTypedStream(stream);
				initStringParser();
			}
			else
			{
				printf("Not a MONET file\n");
			}

			fnames++;
		}
	}
}
#endif

- (void)savePrototypes:sender
{
const char *temp;
NSSavePanel *myPanel;
NSArchiver *stream;
NSMutableData *mdata;

	myPanel = [NSSavePanel savePanel];
	if ([myPanel runModal])
	{
		temp = [[myPanel filename] cString];

		mdata = [NSMutableData dataWithCapacity: 16];
		stream = [[NSArchiver alloc] 
			initForWritingWithMutableData: mdata];

		if (stream)
		{
			[prototypeManager writePrototypesTo:stream];
			[mdata writeToFile: [myPanel filename] atomically: NO];
			[stream release];
		}
		else
		{
			printf("Not a MONET file\n");
		}
	} 
}

#ifndef NeXT
- (void)loadPrototypes:sender
{
NSArray *fnames;
NSArray *types;
char buf[MAXPATHLEN+1];
NSString *directory;
NSArchiver *stream;

	types = [NSArray array];
	[[NSOpenPanel openPanel] setAllowsMultipleSelection:NO];
	if ([[NSOpenPanel openPanel] runModalForTypes:types])
	{
		fnames = [[NSOpenPanel openPanel] filenames];
		directory = [[NSOpenPanel openPanel] directory];
		strcpy(buf, [directory cString]);
		strcat(buf, "/");
		strcat(buf, [[fnames objectAtIndex: 0] cString]);

		stream = [[NSUnarchiver alloc] initForReadingWithData:[NSData dataWithContentsOfFile: [NSString stringWithCString: buf]]];

		if (stream)
		{
			[prototypeManager readPrototypesFrom:stream];
			[stream release];
		}
		else
		{
			printf("Not a MONET file\n");
		}
	} 
}

#else
- loadPrototypes: sender
{
NSArray *fnames;
NSArray *types;
char buf[1024+1];
NSString *directory;
NXTypedStream *stream;

	types = [NSArray array];
	[[NSOpenPanel openPanel] setAllowsMultipleSelection:NO];
	if ([[NSOpenPanel openPanel] runModalForTypes:types])
	{
		fnames = [[NSOpenPanel openPanel] filenames];
		directory = [[NSOpenPanel openPanel] directory];
		strcpy(buf, [directory cString]);
		strcat(buf, "/");
		strcat(buf, [[fnames objectAtIndex: 0] cString]);

		stream = NXOpenTypedStreamForFile(buf, NX_READONLY);

		if (stream)
		{
			[prototypeManager _readPrototypesFrom:stream];
			NXCloseTypedStream(stream);
		}
		else
		{
			printf("Not a MONET file\n");
		}
	}
	return self;

}
#endif

- (void)addCategory
{
	 
}

- (void)addParameter
{
	[(PhoneList *) mainPhoneList addParameter];
	[(RuleManager *) ruleManager addParameter]; 
}

- (void)addMetaParameter
{
	[(PhoneList *) mainPhoneList addMetaParameter];
	[(RuleManager *) ruleManager addMetaParameter]; 
}

- (void)addSymbol
{
	[(PhoneList *) mainPhoneList addSymbol]; 
}

- (int)removeCategory: (int) index
{
  return 0;
}

- (void)removeParameter:(int)index
{
	[(PhoneList *) mainPhoneList removeParameter:index];
	[(RuleManager *) ruleManager removeParameter:index];
}

- (void)removeMetaParameter:(int)index
{
	[(PhoneList *) mainPhoneList removeMetaParameter:index];
	[(RuleManager *) ruleManager removeMetaParameter:index];
}

- (void)removeSymbol:(int)index
{
}

- (void)setObject: object forKey: key
{
  if (namedDict == nil)
    namedDict = [[NSMutableDictionary dictionary] retain];
  [namedDict setObject: object forKey: key];
}

- objectForKey: key
{
  if (namedDict == nil)
    return nil;
  return [namedDict objectForKey: key];
}

- (void)removeObjectForKey: key
{
  if (namedDict != nil)
    [namedDict removeObjectForKey: key];
}


@end
