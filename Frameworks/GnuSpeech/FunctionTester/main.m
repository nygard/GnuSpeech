#import <Foundation/Foundation.h>

#import <GnuSpeech/GnuSpeech.h>

int main(int argc, const char *argv[])
{
    @autoreleasepool
    {
        NSLog(@"Hey");
        init_parser_module();
        char input[1000] = "one %tb 123 two %te three";
        char output[1000];
        long outputLength = sizeof(output);
        gs_pm_mark_modes(input, output, strlen(input), &outputLength);
    }

    return 0;
}
