//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMGroupedObject.h"

#import "GSXMLFunctions.h" // To get MMPhoneType
#import "NSObject-Extensions.h"

@class MMEquation, MMPoint, MMGroup;

@interface MMTransition : MMGroupedObject <GSXMLArchiving>

- (id)initWithModel:(MModel *)model XMLElement:(NSXMLElement *)element error:(NSError **)error;

- (void)addInitialPoint;

@property (strong) NSMutableArray *points;
- (void)addPoint:(id)newPoint;

- (BOOL)isTimeInSlopeRatio:(double)time;
- (void)insertPoint:(MMPoint *)point;

@property (assign) MMPhoneType type;

- (BOOL)isEquationUsed:(MMEquation *)equation;

- (NSString *)transitionPath;

@end
