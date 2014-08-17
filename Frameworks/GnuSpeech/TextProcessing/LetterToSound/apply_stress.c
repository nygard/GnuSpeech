//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "letter_to_sound_private.h"
#import "stresstables.h"
#import <stdio.h>
#import <strings.h>

static int stress_suffix(char *orthography, int *type);
static int light(char *sb);
static int prefix(char *orthography);




/// Find all syllables and make an array of pointers to them.  Mark each as either weak or strong in a separate
/// array;  use the table of stress-affecting affices to find any.  If none, look for stress-repellent prefices.
/// Decide which syllable gets the stress marker;  insert it at the pointer to that syllable.  Returns nonzero
/// if an error occurred.

int apply_stress(char *buffer, char *orthography)
{
    char *syll_array[MAX_SYLLS];
    char *spt;
    int index;

    {
        int last_was_break = 1;

        for (index = 0, spt = buffer; *spt; spt++) {
            if (last_was_break) {
                last_was_break = 0;
                syll_array[index++] = spt;
            }
            if (*spt == '.')
                last_was_break = 1;
        }
    }

    if (index > MAX_SYLLS) {
        return 1;
    }

    int type, syll = -1;

    /*  RETURNS SYLLABLE NO. (FROM THE END) THAT IS THE START OF A STRESS-AFFECTING
     SUFFIX, 0 IF NONE; AND TYPE  */
    int t = stress_suffix(orthography, &type);
    if (t)
    {
        if (type == LTS_AUTOSTRESSED)            syll = index - t;
        else if (type == LTS_PRESTRESS1)         syll = index - t - 1;
        else if (type == LTS_PRESTRESS2)         syll = index - t - 2;
        else if (type == LTS_PRESTRESS_HALF)
        {
            syll = index - t - 1;
            if (syll >= 0 && light(syll_array[syll]))
                syll--;
        }
        else if (type == LTS_NEUTRAL) {
            index -= t;
        }
    }

    if ((syll < 0) && prefix(orthography) && (index >= 2))
        syll = 1;

    if (syll < 0)
    {             /* if as yet unsuccessful */
        syll = index - 2;
        if (syll < 0)
            syll = 0;
        if (light(syll_array[syll]))
            syll--;
    }

    if (syll < 0)
        syll = 0;

    spt = syll_array[syll];
    /*  strcpy(spt+1,spt); */
    char ich = '\'';
    while (ich)
    {
        char temp = *spt;
        *spt = ich;
        ich = temp;
        spt++;
    }
    *spt = '\0';
    return 0;
}

static int stress_suffix(char *orthography, int *type)
{
    long t = 0;

    long c = strlen(orthography);
    while (suffix_list[t].suffix) {
        char *b = suffix_list[t].suffix;
        long a = strlen(b);
        if ((a <= c) && !strcmp(b, orthography + c - a)) {
            *type = suffix_list[t].type;
            return(suffix_list[t].syllableCount);
        }
        t++;
    }

    return 0;
}



/// Determine if a syllable is light.
static int light(char *sb)
{
    while (!isvowel(*sb))
        sb++;

    while (isvowel(*sb) || (*sb == '_') || (*sb == '.'))
        sb++;

    if (!*sb)
        return 1;

    while ((*sb != '_') && (*sb != '.') && *sb)
        sb++;

    if (!*sb)
        return 1;

    while (((*sb == '_') || (*sb == '.')) && *sb)
        sb++;

    if (!*sb)
        return 1;

    return isvowel(*sb);
}

static int prefix(char *orthography)
{
    long t = 0, l;
    char *a;

    long m = strlen(orthography);
    while ((a = prefices[t++])) {
        if (((l = strlen(a)) <= m) && !strncmp(a, orthography, l))
            return 1;
    }

    return 0;
}
