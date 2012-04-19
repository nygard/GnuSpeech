//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock

#import <AppKit/NSTableView.h>
#import <Foundation/NSDate.h> // To get NSTimeInterval

@class NSMutableString;

@interface MExtendedTableView : NSTableView
{
    NSTimeInterval lastTimestamp;
    NSMutableString *combinedCharacters;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)dealloc;

- (void)awakeFromNib;

- (void)keyDown:(NSEvent *)keyEvent;

- (void)doNotCombineNextKey;

@end
