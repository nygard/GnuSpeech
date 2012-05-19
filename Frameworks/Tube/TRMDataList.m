//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "TRMDataList.h"

#import "TRMInputParameters.h"

@interface TRMDataList ()
@end

#pragma mark -

@implementation TRMDataList
{
    TRMInputParameters *m_inputParameters;
    NSMutableArray *m_values;
}

- (id)init;
{
    if ((self = [super init])) {
        m_inputParameters = [[TRMInputParameters alloc] init];
        m_values = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc;
{
    [m_inputParameters release];
    [m_values release];

    [super dealloc];
}

#pragma mark -

@synthesize inputParameters = m_inputParameters;
@synthesize values = m_values;

@end
