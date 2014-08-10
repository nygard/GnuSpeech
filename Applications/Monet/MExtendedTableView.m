//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MExtendedTableView.h"

@interface NSObject (MExtendedTableViewMethods)
- (BOOL)control:(NSControl *)aControl shouldProcessCharacters:(NSString *)characters;
@end

@implementation MExtendedTableView
{
    NSTimeInterval _lastTimestamp;
    NSMutableString *_combinedCharacters;
}

- (id)initWithFrame:(NSRect)frameRect;
{
    if ((self = [super initWithFrame:frameRect])) {
        _lastTimestamp = 0.0;
        _combinedCharacters = [[NSMutableString alloc] init];
    }

    return self;
}

#pragma mark -

// This doesn't get init'd when loaded from a nib, so we need to initialize the instance variables here.
- (void)awakeFromNib;
{
    _lastTimestamp = 0.0;
    if (_combinedCharacters == nil)
        _combinedCharacters = [[NSMutableString alloc] init];
}

#define COMBINE_INTERVAL 0.2

- (void)keyDown:(NSEvent *)keyEvent;
{
    //NSLog(@" > %s", _cmd);
    //NSLog(@"characters: %@", [keyEvent characters]);
    //NSLog(@"characters ignoring modifiers: %@", [keyEvent charactersIgnoringModifiers]);
    //NSLog(@"character count: %d", [[keyEvent characters] length]);

    if ([keyEvent timestamp] - _lastTimestamp > COMBINE_INTERVAL)
        [_combinedCharacters setString:@""];

    _lastTimestamp = [keyEvent timestamp];
    [_combinedCharacters appendString:[keyEvent characters]];

    if ([[self delegate] respondsToSelector:@selector(control:shouldProcessCharacters:)] == NO ||
        [(MExtendedTableView *)[self delegate] control:self shouldProcessCharacters:_combinedCharacters] == YES) {
        [super keyDown:keyEvent];
        [_combinedCharacters setString:@""];
    }

    //NSLog(@"<  %s", _cmd);
}

- (void)doNotCombineNextKey;
{
    _lastTimestamp = 0;
}

@end
