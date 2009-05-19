/*******************************************************************************
 *
 *  Copyright (c) 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
 *  
 *  Contributors: 
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
 *  clusters.h
 *  GnuSpeech
 *
 *  Version: 0.9.1
 *
 ******************************************************************************/


/*  LIST OF PHONEME PATTERNS THAT CAN BEGIN A SYLLABLE  */
static char *begin_syllable[] = {
"s_p_l",
"s_p_r",
"s_p_y",
"s_p",
"s_t_r",
"s_t_y",
"s_t",
"s_k_l",
"s_k_r",
"s_k_y",
"s_k_w",
"s_k",
"p_l",
"p_r",
"p_y",
"t_r",
"k_l",
"k_r",
"k_y",
"k_w",
"sh_r",
"sh_l",
"sh",
"b_l",
"b_r",
"b_y",
"b_w",
"d_r",
"d_y",
"d_w",
"g_l",
"g_r",
"g_y",
"g_w",
"d_r",
"d_y",
"d_w",
"dh",
"b",
"d",
"f",
"g",
"h",
"j",
"k",
"l",
"m",
"n",
"p",
"r",
"s",
"t",
"v",
"w",
"y",
"z",
0
};


/*  LIST OF PHONEME PATTERNS THAT CAN END A SYLLABLE  */
static char *end_syllable[] = {
"b",
"d",
"er",
"f",
"g",
"h",
"j",
"k",
"l",
"m",
"n",
"p",
"r",
"s",
"f_t",
"s_k",
"s_p",
"r_b",
"r_d",
"r_g",
"l_b",
"l_d",
"n_d",
"ng_k",
"ng_z",
"n_z",
"l_f",
"r_f",
"l_v",
"r_v",
"l_th",
"r_th",
"m_th",
"ng_th",
"r_dh",
"p_s",
"t_s",
"l_p",
"r_p",
"m_p",
"l_ch",
"r_ch",
"n_ch",
"l_k",
"r_k",
"ng_k",
"l_j",
"r_j",
"n_j",
"r_l",
"r_l_d",
"r_n_d",
"r_n_t",
"r_l_z",
"r_n_z",
"r_m_z",
"r_m_th",
"r_n",
"r_m",
"r_s",
"l_s",
"l_th",
"r_f",
"r_t",
"l_t",
"r_k",
"k_s",
"d_z",
"t_th",
"k_t",
"p_t",
"r_k",
"s_t",
"th",
"sh",
"zh",
"t",
"v",
"w",
"y",
"z",
0
};
