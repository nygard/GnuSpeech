#ifndef __FIR_H
#define __FIR_H

/*  OVERSAMPLING FIR FILTER CHARACTERISTICS  */
#define FIR_BETA                  .2
#define FIR_GAMMA                 .1
#define FIR_CUTOFF                .00000001

void initializeFIR(double beta, double gamma, double cutoff);
double FIRFilter(double input, int needOutput);

#endif
