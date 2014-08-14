#import <Foundation/Foundation.h>

#import <GnuSpeech/GnuSpeech.h>
#import "GSTextParser-Private.h"
#import "NXStream.h"

int main(int argc, const char *argv[])
{
    @autoreleasepool
    {
        NSLog(@"Hey");
        init_parser_module();
#if 0
        {
            char input[1000] = "I'm %tb 1234 %te sorry David, I'm afraid I can't do that.";
            char output[1000];
            long outputLength = sizeof(output);
            gs_pm_mark_modes(input, output, strlen(input), &outputLength);
        }
#endif
        {
            char buffer[1000] = "foo) plus 5, or foo) + 5";

            NXStream *stream1 = [[NXStream alloc] init];
            gs_pm_strip_punctuation_pass1(buffer, 1000);
            gs_pm_strip_punctuation_pass2(buffer, 1000, stream1);
            NSLog(@"output: %s", [stream1 mutableBytes]);
//            const char *ptr;
//            parser(buffer, &ptr);
//            NSLog(@"output: '%s'", ptr);
        }
        {
            NSLog(@"-------");
            GSTextParser *p1 = [[GSTextParser alloc] init];
            NSString *str = @"foo + bar";
            NSString *result = [p1 punc1_deleteSingleCharacters:str];
            NSLog(@"result: '%@'", result);
        }
    }

    return 0;
}
