//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMGroupedObject.h"

#import "GSXMLFunctions.h" // To get MMPhoneType

@class MMEquation, MMPoint, MMGroup;

@interface MMTransition : MMGroupedObject

- (void)addInitialPoint;

@property (strong) NSMutableArray *points;
- (void)addPoint:(id)newPoint;

- (BOOL)isTimeInSlopeRatio:(double)aTime;
- (void)insertPoint:(MMPoint *)aPoint;

@property (assign) MMPhoneType type;

- (BOOL)isEquationUsed:(MMEquation *)anEquation;

- (void)appendXMLToString:(NSMutableString *)resultString level:(NSUInteger)level;

- (NSString *)transitionPath;

@end
