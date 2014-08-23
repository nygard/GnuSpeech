//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

/// Generate a pronunciation for a word using letter to sound rules.  The type of word
/// is indicated after the pronunciation, separated by a percent.  There may be multiple
/// types, in which case the most common comes first.
///
/// The possible types are:
///     NOUN                'a'
///     VERB                'b'
///     ADJECTIVE           'c'
///     ADVERB              'd'
///     PRONOUN             'e'
///     ARTICLE             'f'
///     PREPOSITION         'g'
///     CONJUNCITON         'h'
///     INTERJECTION        'i'
///     UNKNOWN             'j'
///     PROPERNAME (NOUN)   'k'
///     LOCATIONNAME (NOUN) 'l'
///     CONCEPTNAME (NOUN)  'm'
///
/// @return Pronunciation of word, or NULL if any error (rare).
char *letter_to_sound(char *word);
