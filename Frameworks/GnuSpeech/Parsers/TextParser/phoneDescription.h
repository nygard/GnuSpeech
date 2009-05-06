#import "template.h"
#import <stdio.h>


#define T_DURATION_FIXED         0
#define T_DURATION_PROP          1


/*  DATA STRUCTURES  */
struct _target {
  int is_default;
  float value;
  struct _target *next;
};
typedef struct _target target;
typedef target *targetPtr;

struct _category {
  char symbol[SYMBOL_LENGTH_MAX+1];
  struct _category *next;
};
typedef struct _category category;
typedef category *categoryPtr;

struct _phoneDescription {
  char symbol[SYMBOL_LENGTH_MAX+1];
  int duration;
  struct {
      int type;
      int fixed;
      float prop;
  } transition_duration;
  struct _phoneDescription *next;
  targetPtr targetHead;
  categoryPtr categoryHead;
  int number_of_categories;
};
typedef struct _phoneDescription phoneDescription;
typedef phoneDescription *phoneDescriptionPtr;


extern void initPhoneDescription(void);
extern int matchPhone(char *phone,char *category);
extern float getTarget(char *phone,char *parameter);
extern int getPhoneLength(char *phone);
extern int getTransitionType(char *phone);
extern int getTransitionDurationFixed(char *phone);
extern float getTransitionDurationProp(char *phone);
extern void readFromFilePhoneDescription(FILE *fp1);
#if DEBUG
extern void printPhoneDescription(void);
#endif
