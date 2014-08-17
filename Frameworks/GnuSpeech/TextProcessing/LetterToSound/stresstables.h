//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

/*  LOCAL DEFINES  ***********************************************************/
#define MAX_SYLLS      (100)
#define isvowel(c)     (((c)=='a') || ((c)=='e') || ((c)=='i') || ((c)=='o') || ((c)=='u') )

/*  SUFFIX TYPES  */
#define LTS_AUTOSTRESSED   (0)
#define LTS_PRESTRESS1     (1)
#define LTS_PRESTRESS2     (2)
#define LTS_PRESTRESS_HALF (3) /* actually prestressed 1/2, but can't use '/' in identifier */
#define LTS_NEUTRAL        (4)


/*  DATA TYPES  **************************************************************/
struct suff_data {
    char *suffix;
    int type;
    int syllableCount;
};


/*  GLOBAL VARIABLES (LOCAL TO THIS FILE)  ***********************************/
static struct suff_data suffix_list[] =
{
    //  AUTOSTRESSED: (2nd entry 0)
    { "ade",     LTS_AUTOSTRESSED,   1 },
    { "aire",    LTS_AUTOSTRESSED,   1 },
    { "aise",    LTS_AUTOSTRESSED,   1 },
    { "arian",   LTS_AUTOSTRESSED,   1 },
    { "arium",   LTS_AUTOSTRESSED,   1 },
    { "cidal",   LTS_AUTOSTRESSED,   2 },
    { "cratic",  LTS_AUTOSTRESSED,   2 },
    { "ee",      LTS_AUTOSTRESSED,   1 },
    { "een",     LTS_AUTOSTRESSED,   1 },
    { "eer",     LTS_AUTOSTRESSED,   1 },
    { "elle",    LTS_AUTOSTRESSED,   1 },
    { "enne",    LTS_AUTOSTRESSED,   1 },
    { "ential",  LTS_AUTOSTRESSED,   2 },
    { "esce",    LTS_AUTOSTRESSED,   1 },
    { "escence", LTS_AUTOSTRESSED,   2 },
    { "escent",  LTS_AUTOSTRESSED,   2 },
    { "ese",     LTS_AUTOSTRESSED,   1 },
    { "esque",   LTS_AUTOSTRESSED,   1 },
    { "esse",    LTS_AUTOSTRESSED,   1 },
    { "et",      LTS_AUTOSTRESSED,   1 },
    { "ette",    LTS_AUTOSTRESSED,   1 },
    { "eur",     LTS_AUTOSTRESSED,   1 },
    { "faction", LTS_AUTOSTRESSED,   2 },
    { "ician",   LTS_AUTOSTRESSED,   2 },
    { "icious",  LTS_AUTOSTRESSED,   2 },
    { "icity",   LTS_AUTOSTRESSED,   3 },
    { "ation",   LTS_AUTOSTRESSED,   2 },
    { "self",    LTS_AUTOSTRESSED,   1 },

    // PRESTRESS1: (2nd entry 1)
    { "cracy",   LTS_PRESTRESS1,     2 },
    { "erie",    LTS_PRESTRESS1,     2 },
    { "ety",     LTS_PRESTRESS1,     2 },
    { "ic",      LTS_PRESTRESS1,     1 },
    { "ical",    LTS_PRESTRESS1,     2 },
    { "ssion",   LTS_PRESTRESS1,     1 },
    { "ia",      LTS_PRESTRESS1,     1 },
    { "metry",   LTS_PRESTRESS1,     2 },

    // PRESTRESS2: (2nd entry 2)
    { "able",    LTS_PRESTRESS2,     1 },   //  NOTE: McIl GIVES WRONG SYLL. CT.
    { "ast",     LTS_PRESTRESS2,     1 },
    { "ate",     LTS_PRESTRESS2,     1 },
    { "atory",   LTS_PRESTRESS2,     3 },
    { "cide",    LTS_PRESTRESS2,     1 },
    { "ene",     LTS_PRESTRESS2,     1 },
    { "fy",      LTS_PRESTRESS2,     1 },
    { "gon",     LTS_PRESTRESS2,     1 },
    { "tude",    LTS_PRESTRESS2,     1 },
    { "gram",    LTS_PRESTRESS2,     1 },

    // PRESTRESS 1/2: (2nd entry 3)
    { "ad",      LTS_PRESTRESS_HALF, 1 },
    { "al",      LTS_PRESTRESS_HALF, 1 },
    { "an",      LTS_PRESTRESS_HALF, 1 },   //  OMIT?
    { "ancy",    LTS_PRESTRESS_HALF, 2 },
    { "ant",     LTS_PRESTRESS_HALF, 1 },
    { "ar",      LTS_PRESTRESS_HALF, 1 },
    { "ary",     LTS_PRESTRESS_HALF, 2 },
    { "ative",   LTS_PRESTRESS_HALF, 2 },
    { "ator",    LTS_PRESTRESS_HALF, 2 },
    { "ature",   LTS_PRESTRESS_HALF, 2 },
    { "ence",    LTS_PRESTRESS_HALF, 1 },
    { "ency",    LTS_PRESTRESS_HALF, 2 },
    { "ent",     LTS_PRESTRESS_HALF, 1 },
    { "ery",     LTS_PRESTRESS_HALF, 2 },
    { "ible",    LTS_PRESTRESS_HALF, 1 },   //  BUG
    { "is",      LTS_PRESTRESS_HALF, 1 },

    // STRESS NEUTRAL: (2nd entry 4)
    { "acy",     LTS_NEUTRAL,        2 },
    { "age",     LTS_NEUTRAL,        1 },
    { "ance",    LTS_NEUTRAL,        1 },
    { "edly",    LTS_NEUTRAL,        2 },
    { "edness",  LTS_NEUTRAL,        2 },
    { "en",      LTS_NEUTRAL,        1 },
    { "er",      LTS_NEUTRAL,        1 },
    { "ess",     LTS_NEUTRAL,        1 },
    { "ful",     LTS_NEUTRAL,        1 },
    { "hood",    LTS_NEUTRAL,        1 },
    { "less",    LTS_NEUTRAL,        1 },
    { "ness",    LTS_NEUTRAL,        1 },
    { "ish",     LTS_NEUTRAL,        1 },
    { "dom",     LTS_NEUTRAL,        1 },

    { NULL,      0,                  0 }, //  END MARKER
};


/*  STRESS REPELLENT PREFICES  */
static char        *prefices[] = {
    "ex",
    "ac",
    "af",
    "de",
    "in",
    "non",
    0
};
