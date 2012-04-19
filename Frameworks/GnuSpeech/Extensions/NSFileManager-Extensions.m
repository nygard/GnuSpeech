//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "NSFileManager-Extensions.h"

#import <Foundation/Foundation.h>

@implementation NSFileManager (Extensions)

//  TODO (2012-04-18) Just call the new method directly
- (BOOL)createDirectoryAtPath:(NSString *)path attributes:(NSDictionary *)attributes createIntermediateDirectories:(BOOL)shouldCreateIntermediateDirectories;
{
    return [self createDirectoryAtPath:path withIntermediateDirectories:shouldCreateIntermediateDirectories attributes:attributes error:NULL];
}

@end
