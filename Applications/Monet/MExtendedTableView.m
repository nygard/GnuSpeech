//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MExtendedTableView.h"

@interface NSObject (MExtendedTableViewMethods)
- (BOOL)control:(NSControl *)aControl shouldProcessCharacters:(NSString *)characters;
@end

@implementation MExtendedTableView
{
    NSTimeInterval lastTimestamp;
    NSMutableString *combinedCharacters;
}

- (id)initWithFrame:(NSRect)frameRect;
{
    if ([super initWithFrame:frameRect] == nil)
        return nil;

    lastTimestamp = 0.0;
    combinedCharacters = [[NSMutableString alloc] init];

    return self;
}

- (void)dealloc;
{
    [combinedCharacters release];

    [super dealloc];
}

#pragma mark -

// This doesn't get init'd when loaded from a nib, so we need to initialize the instance variables here.
- (void)awakeFromNib;
{
    lastTimestamp = 0.0;
    if (combinedCharacters == nil)
        combinedCharacters = [[NSMutableString alloc] init];
}

#define COMBINE_INTERVAL 0.2

- (void)keyDown:(NSEvent *)keyEvent;
{
    //NSLog(@" > %s", _cmd);
    //NSLog(@"characters: %@", [keyEvent characters]);
    //NSLog(@"characters ignoring modifiers: %@", [keyEvent charactersIgnoringModifiers]);
    //NSLog(@"character count: %d", [[keyEvent characters] length]);

    if ([keyEvent timestamp] - lastTimestamp > COMBINE_INTERVAL)
        [combinedCharacters setString:@""];

    lastTimestamp = [keyEvent timestamp];
    [combinedCharacters appendString:[keyEvent characters]];

    if ([[self delegate] respondsToSelector:@selector(control:shouldProcessCharacters:)] == NO ||
        [(MExtendedTableView *)[self delegate] control:self shouldProcessCharacters:combinedCharacters] == YES) {
        [super keyDown:keyEvent];
        [combinedCharacters setString:@""];
    }

    //NSLog(@"<  %s", _cmd);
}

- (void)doNotCombineNextKey;
{
    lastTimestamp = 0;
}

@end
