/*******************************************************************************
 *
 *  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
 *
 *  Contributors: Leonard Manzara, David Hill
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License     
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *******************************************************************************
 *
 *  fft.h
 *  Synthesizer
 *
 *  Created by Lenard Manzara on 5/20/1994
 *
 *  Version: 0.7.3
 *
 ******************************************************************************/


/*  REVISION INFORMATION  *****************************************************

$Author: len $
$Date: 1994/05/20 00:21:51 $
$Revision: 1.1.1.1 $
$Source: /cvsroot/Synthesizer/fft.h,v $
$State: Exp $


$Log: fft.h,v $
 * Revision 1.1.1.1  1994/05/20  00:21:51  len
 * Initial archive of TRM interactive Synthesizer.
 *

******************************************************************************/

extern void realfft(float *table, int tablesize);
extern void four1(float *data, int nn, int isign);
