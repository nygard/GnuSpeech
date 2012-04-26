//  This file is part of STFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004-2012 Steve Nygard.  All rights reserved.

#import "STLogger.h"

@interface STLogger ()
@property (strong) NSFileHandle *outputFileHandle;
@property (strong) NSString *linePrefix;
@property (strong) NSString *lineSuffix;
@property (readonly) NSMutableArray *indentations;
@end

#pragma mark -

@implementation STLogger
{
    NSFileHandle *m_outputFileHandle;
    NSString *m_linePrefix;
    NSString *m_lineSuffix;
    NSMutableArray *m_indentations;
}

- (id)init;
{
    if ((self = [super init])) {
        m_outputFileHandle = [NSFileHandle fileHandleWithStandardOutput];
        m_indentations = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (id)initWithOutputToPath:(NSString *)path error:(NSError **)error;
{
    if ((self = [self init])) {
        int fd = open([path fileSystemRepresentation], O_WRONLY|O_CREAT|O_TRUNC);
        if (fd == -1) {
            if (error != NULL) *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil];
            return nil;
        } else {
            self.outputFileHandle = [[NSFileHandle alloc] initWithFileDescriptor:fd closeOnDealloc:YES];
        }
    }
    
    return self;
}

- (void)dealloc;
{
    [m_outputFileHandle closeFile];
    [m_outputFileHandle release];
    [m_linePrefix release];
    [m_lineSuffix release];
    [m_indentations release];
    
    [super dealloc];
}

#pragma mark -

@synthesize outputFileHandle = m_outputFileHandle;
@synthesize linePrefix = m_linePrefix;
@synthesize lineSuffix = m_lineSuffix;
@synthesize indentations = m_indentations;

- (void)log:(NSString *)format, ...;
{
    if (format != nil) {
        va_list argList;
        
        va_start(argList, format);
        NSString *string = [[NSString alloc] initWithFormat:format arguments:argList];
        va_end(argList);

        if (self.linePrefix != nil && [string length] > 0) [self.outputFileHandle writeData:[self.linePrefix dataUsingEncoding:NSUTF8StringEncoding]];

        [self.outputFileHandle writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];

        if (self.lineSuffix != nil) {
            [self.outputFileHandle writeData:[self.lineSuffix dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            // Always want at least a newline.
            [self.outputFileHandle writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
}

- (void)pushIndentation:(NSString *)str;
{
    [self.indentations addObject:str];
    self.linePrefix = [self.indentations componentsJoinedByString:@""];
}

- (void)popIndentation;
{
    [self.indentations removeLastObject];
    self.linePrefix = [self.indentations componentsJoinedByString:@""];
}

@end
