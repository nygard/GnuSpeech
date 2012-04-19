//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock

#import <AppKit/NSScrollView.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class MAIntonationScaleView;

@interface MAIntonationScrollView : NSScrollView
{
    IBOutlet MAIntonationScaleView *scaleView;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)dealloc;

- (void)awakeFromNib;
- (void)addScaleView;

- (void)tile;

- (NSView *)scaleView;

- (NSSize)printableSize;

@end
