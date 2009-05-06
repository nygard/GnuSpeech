/*  HEADER FILES TO IMPORT  */
#import <mach/vm_types.h>     /*  NEEDED FOR DECLARATION BELOW  */

/*  DEFINES  */
#define CACHE_SIZE      400    /* CAN BE CHANGED HERE  */

/*  FUNCTION PROTOTYPES  */
extern int init_diphone_module(char *degas_file_path,
			       char **parameters,
			       char *cache_preload_file_path);
extern vm_address_t paged_diphone(char *phone1, char *phone2);
extern int diphone_duration(char *phone1, char *phone2);
extern int phoneInCategory(char *phone, char *category);
extern float targetValue(char *phone, char *parameter);
extern int validPhone(char *phone);
