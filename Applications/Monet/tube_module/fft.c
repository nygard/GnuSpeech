/*  REVISION INFORMATION  *****************************************************

_Author: rao $
_Date: 2002/03/21 16:49:47 $
_Revision: 1.1 $
_Source: /cvsroot/gnuspeech/gnuspeech/trillium/ObjectiveC/Monet/tube_module/fft.c,v $
_State: Exp $


_Log: fft.c,v $
Revision 1.1  2002/03/21 16:49:47  rao
Initial import.

 * Revision 1.1.1.1  1994/09/06  21:45:53  len
 * Initial archive into CVS.
 *

******************************************************************************/

/******************************************************************************
*
*     fft.c
*     
*     Package to find positive spectrum (in terms of magnitude only) of input
*     data.  Import the file "fft.h" for external references to this code.
*
******************************************************************************/


/*  HEADER FILES  ************************************************************/
#include "fft.h"
#include <math.h>


/*  LOCAL DEFINES  ***********************************************************/
#define SWAP(a,b)  tempr=(a);(a)=(b);(b)=tempr
#define SQR(a)     ((a)*(a))

#define PI         3.141592653589793



/******************************************************************************
*
*	function:	realfft
*
*	purpose:	Finds the positive spectrum of the input data, and
*                       returns it as a list of magnitudes in the first half
*                       of the data array.  The upper half of the array
*                       contains garbage.  Only magnitude is calculated---the
*                       function would have to be rewritten to also return
*                       the phase.  Also note that the DC component is not
*                       returned in the magnitude list---the list ranges from
*                       the first harmonic to nyquist.  This routine is based
*                       on the realft() function in Numerical Recipes in C,
*                       but altered so that only a forward transform can be
*                       done, using a zero-indexed array, with magnitude
*                       calculation.
*			
*       arguments:      table - pointer to data array to be transformed,
*                               assumed to be real (not complex) data.
*                       tablesize - size of the array; must be a power of 2
*
*	internal
*	functions:	four1
*
*	library
*	functions:	sin, sqrt, fabs
*
******************************************************************************/

void realfft(float *table, int tablesize)
{
    int i, i1, i2, i3, i4, n2p3, n;
    float c1 = 0.5, c2 = -0.5, hir, h1i, h2r, h2i, nyquist, *data;
    double wr, wi, wpr, wpi, wtemp, theta;

    /*  INITIALIZE CONSTANTS  */
    data = table - 1;
    n = tablesize / 2;
    theta = PI / (double)n;

    /*  DO FOURIER TRANSFORM ON TABLE (WITH INDEXING STARTING AT 0)  */
    four1(table, n, 1);

    /*  REPACK THE TRANSFORMED DATA INTO STANDARD ORDER  */
    wtemp = sin(0.5 * theta);
    wpr = -2.0 * wtemp * wtemp;
    wpi = sin(theta);
    wr = 1.0 + wpr;
    wi = wpi;
    n2p3 = 2 * n + 3;
    for (i = 2; i <= n/2; i++) {
	i4 = 1 + (i3 = n2p3 - (i2 = 1 + (i1 = i + i - 1)));
	hir = c1 * (data[i1] + data[i3]);
	h1i = c1 * (data[i2] - data[i4]);
	h2r = -c2 * (data[i2] + data[i4]);
	h2i = c2 * (data[i1] - data[i3]);
	data[i1] = hir + wr * h2r - wi * h2i;
	data[i2] = h1i + wr * h2i + wi * h2r;
	data[i3] = hir - wr * h2r + wi * h2i;
	data[i4] = -h1i + wr * h2i + wi * h2r;
	wr = (wtemp = wr) * wpr - wi * wpi + wr;
	wi = wi * wpr + wtemp * wpi + wi;
    }

    /*  CALCULATE THE DC COMPONENT  */
    data[1] = (hir = data[1]) + data[2];

    /*  CALCULATE THE NYQUIST COMPONENT  */
    nyquist = data[2] = hir - data[2];

    /*  CALCULATE THE MAGNITUDE OF EACH COMPONENT BY TAKING THE GEOMETRIC
	MEAN OF THE REAL AND IMAGINARY PARTS, AND SCALING BY n.  ALSO,
	RE-ARRANGE THESE MAGNITUDES SO THAT THEY RANGE FROM HARMONICS 1 TO
	NYQUIST IN THE ORIGINAL DATA ARRAY, LEAVING OUT THE DC COMPONENT
	(SINCE IT IS NOT USUALLY NEEDED).  NOTE THAT THE UPPER HALF OF THE
	ORIGINAL DATA ARRAY WILL CONTAIN GARBAGE, AND SHOULD BE IGNORED  */
    for (i = 1; i < n; i++)
	data[i] = sqrt(SQR(data[(2*i)+1]) + SQR(data[(2*i)+2])) / (float)n;
    
    data[n] = fabs(nyquist) / (float)n;
}



/******************************************************************************
*
*	function:	four1
*
*	purpose:	Tuned complex FFT taken from "Performance Tuning a
*                       Complex FFT" in the May, 1993 issue of The C Users
*                       Journal.  This version uses the unrolled inner loop.
*                       The original algorithm is from Numerical Recipes in C,
*                       but note that the indexing starts at 0 in this version,
*                       and that the arguments nn and isign are passed in by
*                       value, not by reference.
*                       
*       arguments:      data - pointer to (complex) data array to be
*                              transformed.  Data is stored as interleaved
*                              real and imaginary parts.
*                       nn - number of complex numbers in the array; must be a
*                            power of 2.  Since the array contains real and
*                            imaginary parts (represented as pairs of floats),
*                            the array ranges from 0..(2*nn)-1.
*                       isign - set to 1 for normal transform, -1 for IFFT
*                       
*	internal
*	functions:	none
*
*	library
*	functions:	sin
*
******************************************************************************/

void four1(float *data, int nn, int isign)
{
    int n, mmax, m, j = 0, i;
    double wtemp, wr, wpr, wpi, wi, theta, wpin = 0;
    float tempr, tempi, datar, datai;
    float data1r, data1i;
    
    n = nn * 2;
    for (i = 0; i < n; i += 2) {
	if (j > i) {
	    SWAP(data[j], data[i]);
	    SWAP(data[j + 1], data[i + 1]);
	}
	m = nn;
	while (m >= 2 && j >= m) {
	    j -= m;
	    m >>= 1;
	}
	j += m;
    }

    theta = PI * 0.5;

    if (isign < 0)
	theta = -theta;

    for (mmax = 2; n > mmax; mmax *= 2) {
	wpi = wpin;
	wpin = sin(theta);
	wpr = 1 - wpin * wpin - wpin * wpin;    /* cos(theta*2) */
	theta *= .5;
	wr = 1;
	wi = 0;
	/*  UNROLLED INNER LOOP  */
	for (m = 0; m < mmax; m += 2) {
	    j = m + mmax;
	    tempr = (float) wr *(data1r = data[j]);
	    tempi = (float) wi *(data1i = data[j + 1]);
	    for (i = m; i < n - mmax * 2; i += mmax * 2) {
		tempr -= tempi;
		tempi = (float) wr *data1i + (float) wi *data1r;
		data1r = data[j + mmax * 2];
		data1i = data[j + mmax * 2 + 1];
		data[i] = (datar = data[i]) + tempr;
		data[i + 1] = (datai = data[i + 1]) + tempi;
		data[j] = datar - tempr;
		data[j + 1] = datai - tempi;
		tempr = (float) wr *data1r;
		tempi = (float) wi *data1i;
		j += mmax * 2;
	    }
	    tempr -= tempi;
	    tempi = (float) wr *data1i + (float) wi *data1r;
	    data[i] = (datar = data[i]) + tempr;
	    data[i + 1] = (datai = data[i + 1]) + tempi;
	    data[j] = datar - tempr;
	    data[j + 1] = datai - tempi;
	    wr = (wtemp = wr) * wpr - wi * wpi;
	    wi = wtemp * wpi + wi * wpr;
	}
    }
}
