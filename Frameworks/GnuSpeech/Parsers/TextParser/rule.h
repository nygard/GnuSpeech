#import "template.h"
#import <mach/vm_types.h>
#import <stdio.h>
#import <strings.h>

/*  DEFINITIONS  */
#define INTERVALS_MAX           6       /*  CHOSEN PRIMARILY DUE TO WINDOW SIZE  */
#define SUB_INTERVALS_MAX       6       /*  CHOSEN PRIMARILY DUE TO WINDOW SIZE  */

/*  TRANSITION MODE DEFINITIONS  */
#define SLOPE_RATIO_MODE        0
#define FIXED_RISE_MODE         1

/*  SPLIT MODE DEFINITIONS  */
#define SPLIT_MODE_ARBITRARY    0
#define SPLIT_MODE_FORMULA      1

/*  DURATION RULE DEFINES  */
#define DUR_RULE_P1              0
#define DUR_RULE_P2              1
#define DUR_RULE_AVG             2
#define DUR_RULE_NORMAL          3
#define DUR_RULE_T_RIGHT         4
#define DUR_RULE_T_LEFT          5
#define DUR_RULE_T_MIDDLE        6
#define DUR_RULE_FIXED           7
#define DUR_FIXED_DEF            50


/*  DATA STRUCTURES  */
/*  STRUCT TO STORE START TIMES  */
struct _start_time_struct {
    int value;
    int special_event;
    struct _start_time_struct *next;
    struct _start_time_struct *previous;
};
typedef struct _start_time_struct start_timeStruct;
typedef start_timeStruct *start_timePtr;

/*  STRUCT FOR FILTERED INTERVALS  */
struct _f_interval {
    int run;
    double regression_factor;
    double abs_value;
    double rise;
    int special_event;
    struct _f_interval *next;
    struct _f_interval *previous;
};
typedef struct _f_interval f_interval;
typedef f_interval *f_intervalPtr;

/*  STRUCT FOR EACH FILTERED PARAMETER  */
struct _f_parameter {
    char symbol[SYMBOL_LENGTH_MAX+1];
    int number_of_f_intervals;
    f_intervalPtr f_intervalHead;
    struct _f_parameter *next;
};
typedef struct _f_parameter f_parameter;
typedef f_parameter *f_parameterPtr;

/*  STRUCT FOR EACH SPECIAL EVENT SUB-INTERVAL  */
struct _sub_interval {
  short int proportional;
  union _dur {
    int ival;
    float fval;
  } duration;
  float rise;
  struct _sub_interval *next;
  struct _sub_interval *previous;
};
typedef struct _sub_interval sub_interval;
typedef sub_interval *sub_intervalPtr;


/*  STRUCT FOR EACH SPECIAL EVENT INTERVAL  */
struct _se_interval {
  sub_intervalPtr sub_intervalHead;
  int number_of_sub_intervals;
  struct _se_interval *next;
  struct _se_interval *previous;
};
typedef struct _se_interval se_interval;
typedef se_interval *se_intervalPtr;


/*  STRUCT FOR EACH SPECIAL EVENT PROFILE  */
struct _specialEventStruct {
  char symbol[SYMBOL_LENGTH_MAX+1];
  se_intervalPtr se_intervalHead;
  struct _specialEventStruct *next;
};
typedef struct _specialEventStruct specialEventStruct;
typedef specialEventStruct *specialEventStructPtr;


/*  STRUCT FOR EACH TRANSITION INTERVAL  */
struct _t_interval {
  short int proportional;
  short int regression;
  union _duration {
    int   ival;
    float fval;
  } duration;
  float rise;
  float slope_ratio;
  struct _t_interval *next;
  struct _t_interval *previous;
};
typedef struct _t_interval t_interval;
typedef t_interval *t_intervalPtr;


/*  STRUCT FOR EACH TRANSITION SPECIFIER  */
struct _specifierStruct {
  char *category1;
  char *category2;
  t_intervalPtr t_intervalHead;
  int number_of_t_intervals;
  short int t_interval_mode;
  short int split_mode;
  specialEventStructPtr specialEventHead;
  int number_of_special_events;
  struct {
      int rule;
      int fixed_length;
  } duration;
  struct _specifierStruct *next;
};
typedef struct _specifierStruct specifierStruct;
typedef specifierStruct *specifierStructPtr;

/*  ORIGINALLY TAKEN FROM Generate.h  */
struct _filterParam {
  char symbol[SYMBOL_LENGTH_MAX+1];
  struct _filterParam *next;
};
typedef struct _filterParam filterParam;
typedef filterParam *filterParamPtr;


extern void initRule(void);
extern specifierStructPtr governingRule(char *phone1,char *phone2);
extern void writeDiphone(char *phone1,char *phone2,specifierStructPtr g_rule,
              filterParamPtr filter_paramHead,FILE *fp,vm_address_t page);
extern void readFromFileRule(FILE *fp1);
#if DEBUG
extern void printRule(void);
#endif
extern int nint(float value);
