#import <stdio.h>

/*  DEFINITIONS  */
#define SYMBOL_LENGTH_MAX       12
#define SAMPLE_SIZE_DEF         2

/*  DATA STRUCTURES  */
struct _phoneStruct {
  char symbol[SYMBOL_LENGTH_MAX+1];
  struct _phoneStruct *next;
};
typedef struct _phoneStruct phoneStruct;
typedef phoneStruct *phoneStructPtr;

struct _parameterStruct {
  char symbol[SYMBOL_LENGTH_MAX+1];
  float minimum;
  float maximum;
  float Default;
  struct _parameterStruct *next;
};
typedef struct _parameterStruct parameterStruct;
typedef parameterStruct *parameterStructPtr;

extern void initTemplate(void);
extern int sampleValue(void);
extern char *parameterSymbol(int number);
extern float parameterSymMinimum(char *parameter);
extern float parameterSymMaximum(char *parameter);
extern void readFromFileTemplate(FILE *fp1);
extern int legalPhone(char *phone);
extern int legalParameter(char *parameter);
#if DEBUG
extern void printTemplate(void);
#endif
