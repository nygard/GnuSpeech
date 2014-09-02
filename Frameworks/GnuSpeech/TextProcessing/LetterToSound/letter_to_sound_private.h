//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

int apply_stress(char *buffer, char *orthography);
int check_word_list(char *string, char **eow);
char *ends_with(char *in, char *end, char *set);
char final_s(char *in, char **eow);
int ie_to_y(char *in, char **end);
void insert_mark(char **end, char *at);
void isp_trans(char *string, char *result);
int long_medial_vowels(char *in, char **eow);
void mark_final_e(char *in, char **eow);
void medial_s(char *in, char *end);
void medial_silent_e(char *in, char **eow);
int member(char element, char *set);
char *suffix(char *in, char *end, char *suflist);
long syllabify(char *word);
char *vowel_before(char *start, char *position);
int word_to_patphone(char *word);

#define isvowel(c)     (((c)=='a') || ((c)=='e') || ((c)=='i') || ((c)=='o') || ((c)=='u') )


void reprint_isp_trie(void);
void reprint_cwl_trie(void);
