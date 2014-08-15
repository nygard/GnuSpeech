#import <Foundation/Foundation.h>

#import <GnuSpeech/GnuSpeech.h>
#import "GSTextParser-Private.h"
#import "NXStream.h"
#import "GSTextGroup.h"
#import "GSTextRun.h"

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
//            char buffer[1000] = "foo) plus 5, or foo) + 5";
//            char buffer[1000] = "blah 1 2+ +3 4+5 6 + 7 or ++ and +++ so a+ +b c5+ +6d 7e+ +f8 +_9 9_+";
//            char buffer[1000] = " $a $a0 $1 $$2 $$3 ";
            char buffer[1000] = "one. two.. three... four.... five..... six...... seven";

            NXStream *stream1 = [[NXStream alloc] init];
            gs_pm_strip_punctuation_pass1(buffer, 1000);
            gs_pm_strip_punctuation_pass2(buffer, 1000, stream1);
            NSLog(@"output: '%s'", [stream1 mutableBytes]);
//            const char *ptr;
//            parser(buffer, &ptr);
//            NSLog(@"output: '%s'", ptr);
        }
        {
            NSLog(@"-------");
            GSTextRun *run1 = [[GSTextRun alloc] initWithMode:GSTextParserMode_Normal];
//            NSString *str = @"blah 1 2+ +3 4+5 6 + 7 or ++ and +++ so a+ +b c5+ +6d 7e+ +f8 +_9 9_+";
//            NSString *str = @"blah 1 2+ +3 4+5 6 + 7 or ++ and +++ so a+ +b c5+ +6d 7e+ +f8 +_9 9_+";
            NSString *str = @"+ a+ +a   a+   +a   +";
            [run1.string appendString:str];
            [run1 stripPunctuation];
//            [run1 _punc1_deleteSingleCharacters];
            NSLog(@"result: '%@'", run1.string);
        }
    }

    return 0;
}
