/*  REVISION INFORMATION  *****************************************************

_Author: rao $
_Date: 2002/03/21 16:49:47 $
_Revision: 1.1 $
_Source: /cvsroot/gnuspeech/gnuspeech/trillium/ObjectiveC/Monet/tube_module/fft.h,v $
_State: Exp $


_Log: fft.h,v $
Revision 1.1  2002/03/21 16:49:47  rao
Initial import.

 * Revision 1.1.1.1  1994/09/06  21:45:54  len
 * Initial archive into CVS.
 *

******************************************************************************/

extern void realfft(float *table, int tablesize);
extern void four1(float *data, int nn, int isign);
