/*  HEADER FILES  ************************************************************/
#import "GSPronunciationDictionary.h"		/*  NEEDED FOR DECLARATIONS BELOW  */ 


/*  LOCAL DEFINES  ***********************************************************/
#define TTS_PARSER_SUCCESS       (-1)
#define TTS_PARSER_FAILURE       0              /*  OR GREATER THAN 0 IF     */
                                                /*  POSITION OF ERROR KNOWN  */


/*  GLOBAL FUNCTIONS *********************************************************/
extern void init_parser_module(void);
extern int set_escape_code(char new_escape_code);
extern int set_dict_data(const short order[4], GSPronunciationDictionary *userDict, GSPronunciationDictionary *appDict, GSPronunciationDictionary *mainDict, NSDictionary *specialAcronymsDict);
extern int parser(const char *input, const char **output);
extern const char *lookup_word(const char *word, short *dict);

