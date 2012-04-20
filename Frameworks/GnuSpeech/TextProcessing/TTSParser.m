//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "TTSParser.h"

#import "NSScanner-Extensions.h"
#import "NSString-Extensions.h"
#import "GSPronunciationDictionary.h"

#import "parser_module.h"
#import "TTS_types.h"  // Required for dictionary ordering definitions.

static NSDictionary * specialAcronyms;  // static class variable

@implementation TTSParser
{
    GSPronunciationDictionary *mainDictionary;
	GSPronunciationDictionary *userDictionary;
	GSPronunciationDictionary *appDictionary;
}

+ (void)initialize;
{
	NSString * path = [[NSBundle bundleForClass:[self class]] pathForResource:@"SpecialAcronyms" ofType:@"plist"];
    NSLog(@"path: %@", path);
	
    specialAcronyms = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSLog(@"specialAcronyms: %@", [specialAcronyms description]);	
}

- (id)initWithPronunciationDictionary:(GSPronunciationDictionary *)aDictionary;
{
    [super init];
	
	userDictionary = [aDictionary retain];
	appDictionary = [aDictionary retain];
    mainDictionary = [aDictionary retain];	
	
    //[mainDictionary loadDictionary];

    return self;
}

- (void)dealloc;
{
    [mainDictionary release];
    [appDictionary release];
    [userDictionary release];	
		
    [super dealloc];
}

- (NSString *)parseString:(NSString *)aString;
{
	NSLog(@"> %s", __PRETTY_FUNCTION__);

	int16_t order[4];
	
	/*  INITIALIZE PARSER MODULE  */
	init_parser_module();
	
	/*  SET ESCAPE CODE  */
	set_escape_code('%');
			
	order[0] = TTS_NUMBER_PARSER;
	order[1] = TTS_USER_DICTIONARY;
	order[2] = TTS_APPLICATION_DICTIONARY;
	order[3] = TTS_MAIN_DICTIONARY;
	
	set_dict_data(order, userDictionary, appDictionary, mainDictionary, specialAcronyms);
		
	// The contents of aString cannot be losslessly converted if it contains non-ascii information.
	// In this case NULL is returned. We need to check for this, and then perform lossy conversion
	// if required.
	
	const char * input;
	const char * output;
	
	if ([aString canBeConvertedToEncoding:NSASCIIStringEncoding]) {
		
		input = [aString cStringUsingEncoding:NSASCIIStringEncoding];
		
	} else {  // strip the non-ascii-convertible characters

		NSLog(@"parseString: String cannot be converted without information loss.");
		NSData * lossyInput = [aString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
		NSString * stringInput = [[[NSString alloc] initWithData:lossyInput encoding:NSASCIIStringEncoding] autorelease];  // this needs to stick around at least as long as 'input'
		input = [stringInput cStringUsingEncoding:NSASCIIStringEncoding];
	}
	
	NSLog(@"input: %s", input);
	
	if (parser(input, &output) != TTS_PARSER_SUCCESS) {
		NSLog(@"parseString: Parsing failed.");
		return nil;
	}
	
	NSLog(@"output: %s", output);
	
    NSString * resultString = [NSString stringWithCString:output encoding:NSASCIIStringEncoding];	

    NSLog(@"< %s", __PRETTY_FUNCTION__);

	return resultString;	
}

@end
