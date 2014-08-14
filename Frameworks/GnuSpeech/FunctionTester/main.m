#import <Foundation/Foundation.h>

#import <GnuSpeech/GnuSpeech.h>
#import "GSTextParser-Private.h"

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
            char buffer[1000] = "' one's twos' 1' '2 '3' 'a a' '4' testing [123 ' ] one two three i'll i' it's steves' o'tt'";
            gs_pm_strip_punctuation_pass1(buffer, 1000);
            NSLog(@"output: '%s'", buffer);
        }
        {
            GSTextParser *p1 = [[GSTextParser alloc] init];
            NSString *str = @"'one two' foo's ' three '";
            NSString *result = [p1 punc1_singleQuote:str];
            NSLog(@"result: '%@'", result);
        }
    }

    return 0;
}
