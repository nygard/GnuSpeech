//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MDocument.h"

#import "MModel.h"

@implementation MDocument
{
    MModel *_model;
}

#pragma mark -

- (id)initWithXMLFile:(NSString *)filename error:(NSError **)error;
{
    if ((self = [super init])) {
        if (filename == nil) {
            // TODO: (2014-08-09) Set error.
            NSLog(@"%s, no filename", __PRETTY_FUNCTION__);
            return nil;
        }

        NSURL *fileURL = [NSURL fileURLWithPath:filename];
        NSError *xmlError;
        NSXMLDocument *xmlDocument = [[NSXMLDocument alloc] initWithContentsOfURL:fileURL options:0 error:&xmlError];
        if (xmlDocument == nil) {
            NSLog(@"%s, error loading xml doc: %@", __PRETTY_FUNCTION__, xmlError);
            // TODO: (2014-08-09) Set error.
            return nil;
        }

        NSLog(@"root: %@", xmlDocument.rootElement);
        _model = [[MModel alloc] initWithXMLElement:xmlDocument.rootElement error:error];
    }

    return self;
}

@end
