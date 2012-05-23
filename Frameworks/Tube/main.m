#include <stdio.h>
#include <stdlib.h>
#include <sys/param.h>
#include <math.h>
#include <string.h>

//#include "output.h"

#import "TRMTubeModel.h"
#import "TRMDataList.h"

BOOL verbose;

int main(int argc, char *argv[])
{
    @autoreleasepool {
        NSString *inputFile = nil;
        NSString *outputFile = nil;;
        
        if (argc == 3) {
            inputFile = [[[NSString alloc] initWithUTF8String:argv[1]] autorelease];
            outputFile = [[[NSString alloc] initWithUTF8String:argv[2]] autorelease];
        } else if ((argc == 4) && (!strcmp("-v", argv[1]))) {
            verbose = YES;
            inputFile = [[[NSString alloc] initWithUTF8String:argv[2]] autorelease];
            outputFile = [[[NSString alloc] initWithUTF8String:argv[3]] autorelease];
        } else {
            fprintf(stderr, "Usage:  %s [-v] inputFile outputFile\n", argv[0]);
            exit(-1);
        }
        
        TRMDataList *inputData = [[[TRMDataList alloc] initWithContentsOfFile:inputFile error:NULL] autorelease];
        if (inputData == nil) {
            fprintf(stderr, "Aborting...\n");
            exit(-1);
        }
        
        // Initialize the synthesizer
        TRMTubeModel *tube = [[[TRMTubeModel alloc] initWithInputData:inputData] autorelease];
        if (tube == nil) {
            fprintf(stderr, "Aborting...\n");
            exit(-1);
        }
        
        if (verbose) {
            // Print out parameter information
            printf("input file:\t\t%s\n\n", [inputFile UTF8String]);
            [tube printInputData];
            printf("\nCalculating floating point samples...");
            printf("\nStarting synthesis\n");
            fflush(stdout);
        }

        [tube synthesize];

        if (verbose)
            printf("done.\n");
        
        NSError *error = nil;
        if (![tube saveOutputToFile:outputFile error:&error]) {
            NSLog(@"Failed to save output: %@", error);
        }

        if (verbose)
            printf("\nWrote scaled samples to file:  %s\n", [outputFile UTF8String]);
    }
        
    return 0;
}
