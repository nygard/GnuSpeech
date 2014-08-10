//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@class MModel;

@interface MMObject : NSObject

- (id)initWithXMLElement:(NSXMLElement *)element error:(NSError **)error;

@property (weak) MModel *model;
@property (nonatomic, readonly) NSUndoManager *undoManager;

@end
