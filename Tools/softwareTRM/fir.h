#ifndef __FIR_H
#define __FIR_H

/*  VARIABLES FOR FIR LOWPASS FILTER  */
typedef struct {
    double *coefficients; // There are tapCount * 2 coefficients, values are repeated once
    double *middlePtr;
    int tapCount;

    double *data; // And tapCount data elements
    int dataIndex;
} TRMFIRFilter;

TRMFIRFilter *TRMFIRFilterCreate(double beta, double gamma, double cutoff);
void TRMFIRFilterFree(TRMFIRFilter *filter);

double FIRFilter(TRMFIRFilter *filter, double input, int needOutput);

#endif
