#ifndef __FIR_H
#define __FIR_H

/*  OVERSAMPLING FIR FILTER CHARACTERISTICS  */
#define FIR_BETA                  .2
#define FIR_GAMMA                 .1
#define FIR_CUTOFF                .00000001

/*  VARIABLES FOR FIR LOWPASS FILTER  */
typedef struct {
    double *FIRData, *FIRCoef;
    int FIRPtr, numberTaps;
} TRMFIRFilter;

TRMFIRFilter *TRMFIRFilterCreate(double beta, double gamma, double cutoff);
void TRMFIRFilterFree(TRMFIRFilter *filter);

double FIRFilter(TRMFIRFilter *filter, double input, int needOutput);


#endif
