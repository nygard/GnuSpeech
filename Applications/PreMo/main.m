//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#ifdef GNUSTEP
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

int main(int argc, const char *argv[])
{
    return NSApplicationMain(argc,  (const char **) argv);
}
