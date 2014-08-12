//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

/*  Dictionary Ordering Definitions  */
#define TTS_EMPTY                       (0)
#define TTS_NUMBER_PARSER               (1)
#define TTS_USER_DICTIONARY             (2)
#define TTS_APPLICATION_DICTIONARY      (3)
#define TTS_MAIN_DICTIONARY             (4)
#define TTS_LETTER_TO_SOUND             (5)

#if 0
/*  Error return typedef  */
typedef int tts_error_t;


/*  Error Return Codes from the TextToSpeech Object  */
#define TTS_SERVER_HUNG                 (-2)
#define TTS_SERVER_RESTARTED            (-1)
#define TTS_OK                          0
#define TTS_OUT_OF_RANGE                1
#define TTS_SPEAK_QUEUE_FULL            2
#define TTS_PARSE_ERROR                 3
#define TTS_ALREADY_PAUSED              4
#define TTS_UTTERANCE_ERASED            5
#define TTS_NO_UTTERANCE                6
#define TTS_NO_FILE                     7
#define TTS_WARNING                     8
#define TTS_ILLEGAL_STREAM              9
#define TTS_INVALID_PATH                10
#define TTS_OBSOLETE_SERVER             11
#define TTS_DSP_TOO_SLOW                12
#define TTS_SAMPLE_RATE_TOO_LOW         13


/*  Output Sample Rate Definitions  */
#define TTS_SAMPLE_RATE_LOW             22050.0
#define TTS_SAMPLE_RATE_HIGH            44100.0
#define TTS_SAMPLE_RATE_DEF             22050.0


/*  Number Channels Definitions  */
#define TTS_CHANNELS_1                  1
#define TTS_CHANNELS_2                  2
#define TTS_CHANNELS_DEF                2


/*  Stereo Balance Definitions  */
#define TTS_BALANCE_MIN                 (-1.0)
#define TTS_BALANCE_MAX                 1.0
#define TTS_BALANCE_DEF                 0.0
#define TTS_BALANCE_LEFT                (-1.0)
#define TTS_BALANCE_RIGHT               1.0
#define TTS_BALANCE_CENTER              0.0


/*  Speed Control Definitions  */
#define TTS_SPEED_MIN                   0.2
#define TTS_SPEED_MAX                   2.0
#define TTS_SPEED_DEF                   1.0
#define TTS_SPEED_FAST                  1.5
#define TTS_SPEED_NORMAL                1.0
#define TTS_SPEED_SLOW                  0.5


/*  Intonation Definitions  */
#define TTS_INTONATION_DEF              0x1f
#define TTS_INTONATION_NONE             0x00
#define TTS_INTONATION_MICRO            0x01
#define TTS_INTONATION_MACRO            0x02
#define TTS_INTONATION_DECLIN           0x04
#define TTS_INTONATION_CREAK            0x08
#define TTS_INTONATION_RANDOMIZE        0x10
#define TTS_INTONATION_ALL              0x1f


/*  Voice Type Definitions  */
#define TTS_VOICE_TYPE_DEF              0
#define TTS_VOICE_TYPE_MALE             0
#define TTS_VOICE_TYPE_FEMALE           1
#define TTS_VOICE_TYPE_LARGE_CHILD      2
#define TTS_VOICE_TYPE_SMALL_CHILD      3
#define TTS_VOICE_TYPE_BABY             4


/*  Pitch Offset Definitions  */
#define TTS_PITCH_OFFSET_MIN            (-12.0)
#define TTS_PITCH_OFFSET_MAX            12.0
#define TTS_PITCH_OFFSET_DEF            0.0


/*  Vocal Tract Length Offset Definitions  */
#define TTS_VTL_OFFSET_MIN              (-3.0)
#define TTS_VTL_OFFSET_MAX              3.0
#define TTS_VTL_OFFSET_DEF              0.0


/*  Breathiness Definitions  */
#define TTS_BREATHINESS_MIN             0.0
#define TTS_BREATHINESS_MAX             10.0
#define TTS_BREATHINESS_DEF             0.5


/*  Volume Level Definitions  */
#define TTS_VOLUME_MIN                  0.0
#define TTS_VOLUME_MAX                  60.0
#define TTS_VOLUME_DEF                  60.0
#define TTS_VOLUME_LOUD                 60.0
#define TTS_VOLUME_MEDIUM               54.0
#define TTS_VOLUME_SOFT                 48.0
#define TTS_VOLUME_OFF                  0.0

/*  Escape Character Definition  */
#define TTS_ESCAPE_CHARACTER_DEF        0x1B


/*  TTS NXDefaults Definitions  */
#define TTS_NXDEFAULT_OWNER             "TextToSpeech"
#define TTS_NXDEFAULT_SAMPLE_RATE       "sampleRate"
#define TTS_NXDEFAULT_CHANNELS          "channels"
#define TTS_NXDEFAULT_BALANCE           "balance"
#define TTS_NXDEFAULT_SPEED             "speed"
#define TTS_NXDEFAULT_INTONATION        "intonation"
#define TTS_NXDEFAULT_VOICE_TYPE        "voiceType"
#define TTS_NXDEFAULT_PITCH_OFFSET      "pitchOffset"
#define TTS_NXDEFAULT_VTL_OFFSET        "vtlOffset"
#define TTS_NXDEFAULT_BREATHINESS       "breathiness"
#define TTS_NXDEFAULT_VOLUME            "volume"
#define TTS_NXDEFAULT_USER_DICT_PATH    "userDictPath"


/*  TTS Defines for server access  */
#define TTS_NXDEFAULT_ROOT_USER         "root"
#define TTS_NXDEFAULT_SYSTEM_PATH       "systemPath"
#define TTS_SERVER_NAME                 "TTS_Server"
#define TTS_CLIENT_SLOTS_MAX            50
#endif
