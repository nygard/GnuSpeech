
/*  OROPHARYNX REGIONS  */
#define R1                        0      /*  S1  */
#define R2                        1      /*  S2  */
#define R3                        2      /*  S3  */
#define R4                        3      /*  S4 & S5  */
#define R5                        4      /*  S6 & S7  */
#define R6                        5      /*  S8  */
#define R7                        6      /*  S9  */
#define R8                        7      /*  S10  */
#define TOTAL_REGIONS             8

typedef struct {
    double glotPitch;
    double glotVol;
    double aspVol;
    double fricVol;
    double fricPos;
    double fricCF;
    double fricBW;
    double radius[TOTAL_REGIONS];
    double velum;
} TRMParameters;
