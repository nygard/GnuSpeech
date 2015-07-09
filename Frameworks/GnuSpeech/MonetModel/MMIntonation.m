//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMIntonation.h"

#import "MMIntonationParameters.h"
#import "MMToneGroup.h"

// A: Unused
// B: Notional pitch
// C: Pitch range of pre-tonic
// D: Pre-tonic target perturbation range.  ie 4 st = +/- 2 st
// E: Unused
// F: Tonic range.
// G: Tonic perturbation range.
// H: Unused
// I: Unused
// J: Unused
//
//
//
// TG 3 -- 0
// BBBB CCCC DDD FFFF GGG
//  2.0 -2.0 4.0 -8.0 4.0
// -3.0  3.0 4.0 -8.0 4.0
//  1.0 -2.0 4.0 -7.0 4.0
//
// TG 8 -- 1
// BBBB CCCC DDD FFFF GGG
// -2.0  1.0 4.0 4.0 4.0
// -2.0  1.0 4.0 3.0 4.0
// -3.0  4.0 4.0 3.0 4.0
//  0.0  0.0 4.0 4.0 4.0
//  1.0 -4.0 4.0 5.0 4.0
//  2.0 -4.0 4.0 6.0 4.0
//  2.0 -3.0 4.0 5.0 4.0
//  0.0  0.0 4.0 5.0 4.0
//
// TG 8 -- 2
// BBBB CCCC DDD FFFF GGG
// -3.0  1.0 4.0 2.0 4.0
// -2.0  1.0 4.0 2.0 4.0
//  0.0 -2.0 4.0 2.0 4.0
//  0.0  1.0 4.0 2.0 4.0
//  0.5 -3.0 4.0 4.0 4.0
//  0.0 -2.0 4.0 4.0 4.0
// -1.0  0.0 4.0 2.0 4.0
//  0.0  0.0 4.0 4.0 4.0
//
// TG 1 -- 3
// BBBB CCCC DDD FFFF GGG
//  0.0  0.0 4.0 -4.0 4.0
//
// TG 1 -- 4
// BBBB CCCC DDD FFFF GGG
//  0.0  0.0 4.0 -4.0 4.0

static NSDictionary *toneGroupIntonationParameterArrays;

@implementation MMIntonation

+ (void)initialize;
{
    if (self == [MMIntonation class]) {
        NSURL *url = [[NSBundle bundleForClass:self] URLForResource:@"intonation" withExtension:@"xml"];

        NSError *error;
        NSXMLDocument *document = [[NSXMLDocument alloc] initWithContentsOfURL:url options:0 error:&error];
        if (document == nil) {
            NSLog(@"Error: Unable to load intonation paramters from %@: %@", url, error);
        } else {
            NSError *xpathError;
            NSArray *toneGroupElements = [document nodesForXPath:@"/intonation/tone-groups/tone-group" error:&xpathError];
            if (toneGroupElements == nil) {
                NSLog(@"Error: %@", xpathError);
            } else {
                // This is a dictionary of arrays of MMIntonationParameters, keyed by @(toneGroupType).
                NSMutableDictionary *toneGroupIntonationParametersByType = [[NSMutableDictionary alloc] init];

                for (NSXMLElement *node in toneGroupElements) {
                    NSXMLNode *nameAttribute = [node attributeForName:@"name"];
                    if (nameAttribute != nil) {
                        NSMutableArray *parameters = [[NSMutableArray alloc] init];

                        NSError *e2;
                        NSArray *intonationParameterElements = [node nodesForXPath:@"intonation-parameters" error:&e2];
                        if (intonationParameterElements == nil) {
                            NSLog(@"Error: %@", e2);
                        } else {
                            for (NSXMLElement *intonationParametersElement in intonationParameterElements) {
                                MMIntonationParameters *intonationParameters = [[MMIntonationParameters alloc] init];
                                // TODO: (2015-07-08) Make sure all five attributes are there first.
                                intonationParameters.notionalPitch             = [intonationParametersElement attributeForName:@"notional-pitch"].stringValue.floatValue;
                                intonationParameters.pretonicPitchRange        = [intonationParametersElement attributeForName:@"pretonic-pitch-range"].stringValue.floatValue;
                                intonationParameters.pretonicPerturbationRange = [intonationParametersElement attributeForName:@"pretonic-perturbation-range"].stringValue.floatValue;
                                intonationParameters.tonicPitchRange           = [intonationParametersElement attributeForName:@"tonic-pitch-range"].stringValue.floatValue;
                                intonationParameters.tonicPerturbationRange    = [intonationParametersElement attributeForName:@"tonic-perturbation-range"].stringValue.floatValue;
                                [parameters addObject:intonationParameters];
                            }
                        }

                        if (MMToneGroupTypeFromString(nameAttribute.stringValue) != MMToneGroupType_Unknown) {
                            toneGroupIntonationParametersByType[ nameAttribute.stringValue ] = [parameters copy];
                        } else {
                            NSLog(@"Error: Unknown tone group type: %@", nameAttribute.stringValue);
                        }
                    }
                }

                toneGroupIntonationParameterArrays = [toneGroupIntonationParametersByType copy];
                NSLog(@"toneGroupIntonationParameterArrays:\n%@", toneGroupIntonationParameterArrays);
            }
        }
    }
}

- (id)init;
{
    if ((self = [super init])) {
        _shouldUseMacroIntonation = YES;
        _shouldUseMicroIntonation = YES;
        _shouldUseSmoothIntonation = YES;

        _shouldUseDrift = YES;
        _driftDeviation = 1.0;
        _driftCutoff = 4;

        _tempo = 1.0;
        _radiusMultiply = 1.0;
    }
    
    return self;
}

- (MMIntonationParameters *)intonationParametersForToneGroup:(MMToneGroup *)toneGroup;
{
    NSArray *array = toneGroupIntonationParameterArrays[ MMToneGroupTypeName(toneGroup.type) ];
    NSParameterAssert(array != nil);
    NSParameterAssert([array count] > 0);
    if ([array count] == 1) {
        return array[0];
    }

    NSUInteger index = random() % [array count];
    return array[index];
}

@end
