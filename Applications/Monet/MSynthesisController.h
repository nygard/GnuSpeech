//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MWindowController.h"

@class MModel;

@interface MSynthesisController : MWindowController

- (id)initWithModel:(MModel *)model;

@property (nonatomic, strong) MModel *model;

- (NSUndoManager *)undoManager;

- (IBAction)showIntonationWindow:(id)sender;

- (IBAction)synthesize:(id)sender;
- (IBAction)synthesizeToFile:(id)sender;
- (IBAction)fileTypeDidChange:(id)sender;
- (IBAction)parseText:(id)sender;

- (IBAction)synthesizeWithContour:(id)sender;

- (IBAction)generateGraphImages:(id)sender;

- (IBAction)addTextString:(id)sender;

- (void)updateGraphTracking:(NSDictionary *)userInfo;

@end
