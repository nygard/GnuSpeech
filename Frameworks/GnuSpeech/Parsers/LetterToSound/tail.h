//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

/*  DATA TYPES  **************************************************************/
typedef struct {
    char               *tail;
    char               *type;
} tail_entry;


/*  GLOBAL VARIABLES (LOCAL TO THIS FILE)  ***********************************/
static tail_entry tail_list[] = {
    { "ly",   "d"  },
    { "er",   "ca" },
    { "ish",  "c"  },
    { "ing",  "cb" },
    { "se",   "b"  },
    { "ic",   "c"  },
    { "ify",  "b"  },
    { "ment", "a"  },
    { "al",   "c"  },
    { "ed",   "bc" },
    { "es",   "ab" },
    { "ant",  "ca" },
    { "ent",  "ca" },
    { "ist",  "a"  },
    { "ism",  "a"  },
    { "gy",   "a"  },
    { "ness", "a"  },
    { "ous",  "c"  },
    { "less", "c"  },
    { "ful",  "c"  },
    { "ion",  "a"  },
    { "able", "c"  },
    { "en",   "c"  },
    { "ry",   "ac" },
    { "ey",   "c"  },
    { "or",   "a"  },
    { "y",    "c"  },
    { "us",   "a"  },
    { "s",    "ab" },
    { 0,      0    },
};
