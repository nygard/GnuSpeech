/*  REVISION INFORMATION  *****************************************************

_Author: rao $
_Date: 2002/03/21 16:49:47 $
_Revision: 1.1 $
_Source: /cvsroot/gnuspeech/gnuspeech/trillium/ObjectiveC/Monet/tube_module/synthesizer_module.h,v $
_State: Exp $


_Log: synthesizer_module.h,v $
Revision 1.1  2002/03/21 16:49:47  rao
Initial import.

 * Revision 1.9  1995/04/04  01:57:56  len
 * Added "median pitch" volume scaling.
 *
 * Revision 1.8  1995/03/26  18:53:37  len
 * Optimized code and raised output volume.
 *
 * Revision 1.7  1995/03/02  02:55:32  len
 * Added means to call user-supplied page_consumed function, added means to
 * set the pad page to user-specified silence, and changed the controlRate
 * variable to a float.
 *
 * Revision 1.6  1995/02/27  17:29:26  len
 * Added support for Intel MultiSound DSP.  Module now compiles FAT.
 *
 * Revision 1.5  1994/11/18  04:28:42  len
 * Added high/low (22050/44100 Hz.) output sample rate switch.
 *
 * Revision 1.4  1994/10/20  20:11:31  len
 * Changed nose and mouth aperture filter coefficients, so now specified
 * as Hz values (which scale appropriately as the tube length changes), rather
 * than arbitrary coefficient values (which don't scale).
 *
 * Revision 1.3  1994/10/03  04:06:02  len
 * Optimized crossmix calculations, added linear interpolation to glottal
 * volume, and added (optional) linear interpolation to radii.
 *
 * Revision 1.2  1994/09/19  18:50:52  len
 * Resectioned the TRM to have 10 sections in 8 regions.  Also changed
 * the frication to be continuous from sections 3 to 10.  Tube lengths
 * down to 15.8 cm are possible, with everything enabled.
 *
 * Revision 1.1.1.1  1994/09/06  21:45:51  len
 * Initial archive into CVS.
 *

******************************************************************************/


/*  COMPILATION FLAGS (MUST MATCH DSP)  */
#define OVERSAMPLE_OSC       1     /*  1 FOR 2X OVERSAMPLING OSC   */
#define VARIABLE_GP          1     /*  1 FOR VARIABLE GP  */
#define FIXED_CROSSMIX       0     /*  1 FOR FIXED CROSSMIX (60 dB)  */
#define SYNC_DMA             1     /*  1 FOR SYNCHRONOUS DMA OUTPUT  */



/*  INCLUDE FILES (NECESSARY FOR PROTOTYPES)  ********************************/
#import <dsp/dsp.h>



/*  FUNCTION PROTOTYPES  *****************************************************/
/*  THESE FUNCTIONS CONTROL THE SYNTHESIS MODULE  */
extern int initialize_synthesizer_module(void);
extern int free_synthesizer_module(void);
extern void set_synthesizer_output(char *path, int uid, int gid,
				   int number_chunks);
#if VARIABLE_GP
extern void set_utterance_rate_parameters(float outputSampleRate,
                                          float controlRate, float volume,
					  int channels, float balance,
					  int waveform, float tp, float tnMin,
					  float tnMax, float breathiness,
					  float length, float temperature,
					  float lossFactor, float apScale,
					  float mouthCoef, float noseCoef,
					  float n1, float n2, float n3,
					  float n4, float n5,
					  float throatCutoff, float throatVol,
					  int modulation, float mixOffset,
                                          float medianPitch,
                                          float silenceParameterTable[]);
#else
extern void set_utterance_rate_parameters(float outputSampleRate,
                                          float controlRate, float volume,
					  int channels, float balance,
					  int waveform, float tp, float tn,
					  int topHarmonic, float breathiness,
					  float length, float temperature,
					  float lossFactor, float apScale,
					  float mouthCoef, float noseCoef,
					  float n1, float n2, float n3,
					  float n4, float n5,
					  float throatCutoff, float throatVol,
					  int modulation, float mixOffset,
                                          float medianPitch,
                                          float silenceParameterTable[]);
#endif
extern int start_synthesizer(void);
void await_request_new_page(int blocking_request, int last_page, 
			    void (*ptr_update_function)(),
			    void (*page_consumed_function)());

/*  THESE FUNCTIONS HELP TO CREATE SYNTHESIZER CONTROL TABLES  */
extern void convert_parameter_table(float parameterTable[],
				    DSPFix24 *dspTable);
extern DSPFix24 *new_dsp_pad_table(float silenceParameterTable[]);
extern DSPFix24 *new_dsp_default_table(void);



/*  GLOBAL VARIABLES  ********************************************************/
/*  GLOBAL VARIABLE USED BY SYNTHESIZER THREAD TO READ A PAGE OF
    SYNTHESIZER CONTROL TABLES  */
extern vm_address_t synth_read_ptr;

/*  VARIABLE TO SIGNAL TO OTHER THREAD WHEN SYNTHESIZER ACTIVE  */
extern int synth_status;



/*  GLOBAL DEFINITIONS  *****************************************************/

/*  SYNTH THREAD CONSTANTS USED FOR SIGNALLING BETWEEN MODULES  */
#define ST_PAUSE             0
#define ST_RUN               1

#define ST_NO                0
#define ST_YES               1

#define ST_NO_ERROR          0
#define ST_ERROR             1

#define ST_OUT_DSP           0
#define ST_OUT_FILE          1

#define ST_NO_PAGE_REQUEST   0
#define ST_PAGE_REQUEST      1


/*  # PAGES BETWEEN CHUNKS (FILE ONLY)  */
#define INTER_CHUNK_SILENCE  3      /*  ADJUSTED FOR 4 MS CONTROL INCREMENT  */


/*  DMA TRANSFER VARIABLES (MUST MATCH DSP)  */
#define DMA_IN_SIZE          2048     /*  DMA-IN BUFFER SIZE (4 BYTE WORDS)  */

#if SYNC_DMA
#define DMA_OUT_SIZE         1024     /*  DMA-OUT BUFFER SIZE (2 BYTE WORDS) */
#else
#define DMA_OUT_SIZE         512      /*  DMA-OUT BUFFER SIZE (2 BYTE WORDS) */
#endif

#define LOW_WATER            (48*1024)
#define HIGH_WATER           (512*1024)

#define DATA_TABLE_SIZE      32          /*  SIZE OF DSP CONTROL-RATE TABLE  */
#define JUNK_SKIP            13     /*  UNUSED PART OF TABLE (32 - 19 = 13)  */
#define TABLES_PER_PAGE      64                   /*  TABLES_PER_DMA TO DSP  */
#define PREFILL_SIZE         6        /*  NO. PAGES BEFORE SOUND OUT STARTS  */

/*  OSCILLATOR WAVETABLE SIZES (MUST MATCH DSP)  */
#define GP_TABLE_SIZE        256
#define SINE_TABLE_SIZE      256

#if !VARIABLE_GP
#define ROLLOFF_FACTOR       0.5
#endif

#if OVERSAMPLE_OSC
#define OVERSAMPLE           2.0             /*  2X OVERSAMPLING OSCILLATOR  */
#else
#define OVERSAMPLE           1.0                        /*  NO OVERSAMPLING  */
#endif

/*  HOST COMMANDS (MUST MATCH DSP)  */
#define HC_START             (0x2E>>1)
#define HC_STOP              (0x30>>1)
#define HC_LOAD_FIR_COEF     (0x32>>1)
#define HC_LOAD_SRC_COEF     (0x34>>1)
#define HC_LOAD_WAVETABLE    (0x36>>1)
#define HC_LOAD_UR_DATA      (0x38>>1)

/*  DIVISORS FOR CONVERSION SCALING (MUST MATCH DSP)  */
#define AMPLITUDE_SCALE      64.0
#define CROSSMIX_SCALE       32.0
#define POSITION_SCALE       8.0

/*  MAXIMUM FIXED POINT VALUE  */
#define MAX_SIZE             0.9999998

/*  PITCH VARIABLES (MIDDLE C = 0.0)  */
#define PITCH_BASE           220.0
#define PITCH_OFFSET         3.0
#define LOG_FACTOR           3.32193

/*  NUMBER OF SECTIONS IN RESONANT SYSTEM (MUST MATCH DSP)  */
#define PHARYNX_REGIONS      3
#define VELUM_REGIONS        1
#define ORAL_REGIONS         5
#define NASAL_REGIONS        5
#define NOSE_REGIONS         (VELUM_REGIONS+NASAL_REGIONS)
#define TOTAL_SECTIONS       10


/*  TABLE FOR THE INPUT (USER) CONTROL-RATE PARAMETERS  */
#define GLOT_PITCH           0
#define GLOT_VOL             1
#define ASP_VOL              2
#define FRIC_VOL             3
#define FRIC_POS             4
#define FRIC_CF              5
#define FRIC_BW              6
#define R1                   7
#define R2                   8
#define R3                   9
#define R4                   10
#define R5                   11
#define R6                   12
#define R7                   13
#define R8                   14
#define VELUM                15

#define INPUT_CR_TABLE_SIZE  16


/*  TABLE FOR THE DSP CONTROL-RATE PARAMETERS (MUST MATCH DSP)  */
#define TABLE_INC_INT        0
#define TABLE_INC_FRAC       1
#define SOURCE_VOLUME        2
#define ASP_VOLUME           3
#define FRICATION_VOLUME     4
#define FRICATION_POSITION   5
#define CENTER_FREQUENCY     6
#define BANDWIDTH            7
#define OPC_1                8
#define OPC_2                9
#define OPC_3                10
#define ALPHA_L              11
#define ALPHA_R              12
#define ALPHA_T              13
#define OPC_4                14
#define OPC_5                15
#define OPC_6                16
#define OPC_7                17
#define OPC_REFL             18
#define OPC_RAD              19
#define NC_1                 20

#define DSP_CR_PARAMETERS    21                /*  BALANCE OF TABLE IGNORED  */



/*  GENERAL RANGES FOR CONTROL-RATE AND UTTERANCE RATE PARAMETERS  */
#define VOLUME_MAX           60.0          /*  RANGE OF ALL VOLUME CONTROLS  */
#define VOLUME_MIN           0.0

#define RADIUS_MIN           0.0     /*  SECTION RADII RANGE (EXCEPT VELUM)  */
#define RADIUS_MAX           3.0


/*  CONTROL-RATE PARAMETER RANGES AND DEFAULTS  */
#define GLOT_PITCH_MIN       (-24.0)
#define GLOT_PITCH_MAX       24.0
#define GLOT_PITCH_DEF       (-12.0)

#define GLOT_VOL_DEF         VOLUME_MAX
#define ASP_VOL_DEF          VOLUME_MIN
#define FRIC_VOL_DEF         VOLUME_MIN

#define FRIC_POS_MIN         0.0
#define FRIC_POS_MAX         7.0
#define FRIC_POS_DEF         FRIC_POS_MAX

#define FRIC_CF_MIN          100.0
#define FRIC_CF_MAX          10000.0
#define FRIC_CF_DEF          2000.0

#define FRIC_BW_MIN          250.0
#define FRIC_BW_MAX          10000.0
#define FRIC_BW_DEF          1000.0

#define R1_DEF               0.82   /*  DEFAULT RADII TO NEUTRAL VOWEL  */
#define R2_DEF               0.885
#define R3_DEF               0.99
#define R4_DEF               0.81
#define R5_DEF               0.755
#define R6_DEF               1.045
#define R7_DEF               1.225
#define R8_DEF               1.12

//#define R1_DEF               0.8   /*  DEFAULT RADII TO "AW" VOWEL  */
//#define R2_DEF               0.8
//#define R3_DEF               0.79
//#define R4_DEF               0.5
//#define R5_DEF               1.28
//#define R6_DEF               2.01
//#define R7_DEF               1.83
//#define R8_DEF               1.62

#define VELUM_MIN            RADIUS_MIN
#define VELUM_MAX            1.5
#define VELUM_DEF            0.0


/*  UTTERANCE-RATE PARAMETER RANGES AND DEFAULTS  */
#define OUTPUT_SRATE_LOW     22050.0
#define OUTPUT_SRATE_HIGH    44100.0
#define OUTPUT_SRATE_DEF     OUTPUT_SRATE_LOW

#define CONTROL_RATE_MIN     1.0
#define CONTROL_RATE_MAX     1000.0
#define CONTROL_RATE_DEF     500.0

#define MASTER_VOLUME_DEF    VOLUME_MAX

#define CHANNELS_MIN         1
#define CHANNELS_MAX         2
#define CHANNELS_DEF         CHANNELS_MAX

#define STEREO_BALANCE_MIN   (-1.0)
#define STEREO_BALANCE_MAX   1.0
#define STEREO_BALANCE_DEF   0.0

#define WAVEFORM_TYPE_GP     0
#define WAVEFORM_TYPE_SINE   1
#define WAVEFORM_TYPE_DEF    WAVEFORM_TYPE_GP

#define TP_MIN               5.0
#define TP_MAX               50.0
#define TP_DEF               40.0

#define TN_MIN_MIN           5.0
#define TN_MIN_MAX           50.0
#define TN_MIN_DEF           12.0

#if VARIABLE_GP
#define TN_MAX_MIN           5.0
#define TN_MAX_MAX           50.0
#define TN_MAX_DEF           35.0
#else
#define TOP_HARMONIC_MIN     1
#define TOP_HARMONIC_MAX     (GP_TABLE_SIZE/2)
#define TOP_HARMONIC_DEF     25
#endif

#define BREATHINESS_MIN      0.0
#define BREATHINESS_MAX      10.0
#define BREATHINESS_DEF      1.5

#define LENGTH_MIN           10.0
#define LENGTH_MAX           20.0
#define LENGTH_DEF           17.5

#define TEMPERATURE_MIN      25.0
#define TEMPERATURE_MAX      40.0
#define TEMPERATURE_DEF      32.0

#define LOSS_FACTOR_MIN      0.0
#define LOSS_FACTOR_MAX      5.0
#define LOSS_FACTOR_DEF      0.8

#define APERTURE_SCALE_MIN   (RADIUS_MAX+0.05)
#define APERTURE_SCALE_MAX   12.0
#define APERTURE_SCALE_DEF   APERTURE_SCALE_MIN

#define MOUTH_COEF_MIN       100.0
#define MOUTH_COEF_MAX       10000.0
#define MOUTH_COEF_DEF       5000.0

#define NOSE_COEF_MIN        100.0
#define NOSE_COEF_MAX        10000.0
#define NOSE_COEF_DEF        5000.0

#define N1_DEF               1.35                    /*  DEFAULT NOSE RADII  */
#define N2_DEF               1.96
#define N3_DEF               1.91
#define N4_DEF               1.30
#define N5_DEF               0.73

#define THROAT_CUTOFF_MIN    50.0
#define THROAT_CUTOFF_MAX    10000.0
#define THROAT_CUTOFF_DEF    1500.0

#define THROAT_VOLUME_MIN    VOLUME_MIN
#define THROAT_VOLUME_MAX    48.0
#define THROAT_VOLUME_DEF    12.0

#define PULSE_MODULATION_OFF 0
#define PULSE_MODULATION_ON  1
#define PULSE_MODULATION_DEF PULSE_MODULATION_ON

#define CROSSMIX_OFFSET_MIN  30.0
#define CROSSMIX_OFFSET_MAX  VOLUME_MAX
#define CROSSMIX_OFFSET_DEF  CROSSMIX_OFFSET_MAX
