#import <Foundation/Foundation.h>

#import <GnuSpeech/GnuSpeech.h>
#import "GSTextParser-Private.h"
#import "NXStream.h"
#import "GSTextGroup.h"
#import "GSTextRun.h"
#import "letter_to_sound.h"
#import "letter_to_sound_private.h"
#import "GSLetterToSound.h"

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
#if 0
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
#endif
#if 0
        {
//            char buf[1000] = "pronunciation";
            char buf[1000] = "doesn't";
            char *ptr = letter_to_sound(buf);
            NSLog(@"ptr: %p", ptr);
            NSLog(@"buf '%s' = '%s'", buf, ptr);
        }
        {
            GSLetterToSound *lts = [[GSLetterToSound alloc] init];
            NSString *p2 = [lts new_pronunciationForWord:@"testing"];
            NSLog(@"p2: '%@'", p2);
            NSString *p3 = [lts pronunciationBySpellingWord:@"#NASA\t\n\r#"];
            NSLog(@"p3: %@ ###", p3);
        }
        {
            char buf[8] = "#Nasa#";
            int result = word_to_patphone(buf);
            NSLog(@"word_to_patphone() result: %d", result);
            NSLog(@"buf: '%s'", buf);
        }
        {
//            reprint_isp_trie();
//            reprint_cwl_trie();
        }
        {
            char buf[1000] = "NASA";
            char *eow = buf + strlen(buf);
            check_word_list(buf, &eow);
        }
#endif
        {
            char buf[1000] = "#engines#";
            int result = word_to_patphone(buf);
            NSLog(@"result: %d", result);
        }
        {
            char buf[1000] = "#fits#";
            char *eow = buf + strlen(buf) - 1;
            char ch;

            ch = final_s(buf, &eow);
            NSLog(@"ch: %c, buf: '%s'", ch, buf);
        }
#if 0
        {
            char buf[1000];

            GSLetterToSound *lts = [[GSLetterToSound alloc] init];

            FILE *fp_old = fopen("/tmp/old.txt", "w");
            lts_log_to_file(fp_old);

            FILE *fp_new = fopen("/tmp/new.txt", "w");
            [lts logToFP:fp_new];

            GSSimplePronunciationDictionary *spd = [GSSimplePronunciationDictionary mainDictionary];
            NSDictionary *dict = [spd pronunciations];
            NSUInteger maxLength = 0;
            for (NSString *key in [[dict allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
//                NSLog(@"key: '%@'", key);
                if (maxLength < [key length])
                    maxLength = [key length];
                memset(buf, 0, 1000);
                if ([key getCString:buf maxLength:1000 encoding:NSASCIIStringEncoding] == NO) {
                    NSLog(@"getCString failed for: '%@'", key);
                } else {
                    letter_to_sound(buf);
                }
                [lts new_pronunciationForWord:key];
            }
            NSLog(@"maxLength: %lu", maxLength);

            fclose(fp_old);
            fclose(fp_new);
        }
#endif
        {
            GSLetterToSound *lts = [[GSLetterToSound alloc] init];

//            NSMutableString *word = [@"she" mutableCopy];
            NSMutableString *word = [@"indeed" mutableCopy];
            NSLog(@"before: %@", word);
            [lts markFinalE:word];
            NSLog(@" after: %@", word);
        }
        {
            char buf[1000] = "#same#";
            char *eow = buf + strlen(buf) - 1;
            mark_final_e(buf, &eow);
            NSLog(@"buf '%s'", buf);
        }
    }

    return 0;
}
