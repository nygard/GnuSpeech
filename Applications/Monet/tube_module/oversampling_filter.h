/*  REVISION INFORMATION  *****************************************************

_Author: rao $
_Date: 2002/03/21 16:49:47 $
_Revision: 1.1 $
_Source: /cvsroot/gnuspeech/gnuspeech/trillium/ObjectiveC/Monet/tube_module/oversampling_filter.h,v $
_State: Exp $


_Log: oversampling_filter.h,v $
Revision 1.1  2002/03/21 16:49:47  rao
Initial import.

 * Revision 1.1.1.1  1994/09/06  21:45:53  len
 * Initial archive into CVS.
 *

******************************************************************************/



/*  HEADER FILES  ************************************************************/
#import <dsp/dsp.h>                      /*  for function prototypes, below  */


/*  GLOBAL FUNCTIONS *********************************************************/
extern DSPFix24 *initializeFIR(double beta, double gamma, double cutoff,
			       int *numberTaps, DSPFix24 *FIRCoef);


/*  GLOBAL DEFINES  **********************************************************/

/*  OVERSAMPLING FIR FILTER CHARACTERISTICS  */
#define FIR_BETA             .2
#define FIR_GAMMA            .1
#define FIR_CUTOFF           .00000011921              /*  equal to 2^(-23)  */
