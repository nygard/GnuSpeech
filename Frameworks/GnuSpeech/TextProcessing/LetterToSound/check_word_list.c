//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "letter_to_sound_private.h"
#import <stdio.h>


/*  LOCAL DEFINES  ***********************************************************/
#define MAX_TERM_VAL   105
#define MAX_ORIGIN     376
#define TRIE_NODES     441
#define MIN_INDEX      '!'
#define index(x)       (x - MIN_INDEX)


/*  DATA TYPES  **************************************************************/
typedef struct _pktrie {
    char                val;
    unsigned char       term_state;
    short               next_org;
} pktrie;


/*  GLOBAL VARIABLES (LOCAL TO THIS FILE)  ***********************************/
static char *m_string[] = {
    /* [a] = */         "uh_",
    /* [alkali] = */    "aa_l_k_uh_l_ah_i_",
    /* [always] = */    "aw_l_w_e_i_z_",
    /* [any] = */       "e_n_ee_",
    /* [april] = */     "e_i_p_r_i_l_",
    /* [are] = */       "ar_r_",
    /* [as] = */        "aa_z_",
    /* [because] = */   "b_i_k_a_z_",
    /* [been] = */      "b_ee_n_",
    /* [being] = */     "b_ee_i_ng_",
    /* [below] = */     "b_i_l_uh_uu_",
    /* [body] = */      "b_o_d_ee_",
    /* [bath] = */      "b_aa_th_",                 // Not in 1977 revision.
    /* [busy] = */      "b_i_z_ee_",
    /* [copy] = */      "k_o_p_ee_",
    /* [do] = */        "d_uu_",
    /* [does] = */      "d_a_z_",
    /* [dosn't] = */    "d_a_z_uh_n_t_",
    /* [doing] = */     "d_uu_i_ng_",
    /* [done] = */      "d_a_n_",
    /* [dr] = */        "d_o_k_t_uh_r_",
    /* [early] = */     "uh_r_l_ee_",
    /* [earn] = */      "uh_r_n_",
    /* [eleven] = */    "i_l_e_v_uh_n_",
    /* [enable] = */    "e_n_e_i_b_uh_l_",
    /* [engine] = */    "e_n_j_i_n_",
    /* [etc] = */       "e_t_s_e_t_uh_r_uh_",
    /* [evening] = */   "ee_v_n_i_ng_",
    /* [every] = */     "e_v_r_ee_",
    /* [everyone] = */  "e_v_r_ee_w_uh_n_",
    /* [eye] = */       "ah_i_",
    /* [february] = */  "f_e_b_r_uu_e_r_ee_",
    /* [finally] = */   "f_ah_i_n_uh_l_ee_",
    /* [friday] = */    "f_r_ah_i_d_e_i_",
    /* [gas] = */       "g_aa_s_",
    /* [guest] = */     "g_e_s_t_",
    /* [has] = */       "h_aa_z_",
    /* [have] = */      "h_aa_v_",
    /* [having] = */    "h_aa_v_i_ng_",
    /* [heard] = */     "h_uh_r_d_",
    /* [his] = */       "h_i_z_",
    /* [imply] = */     "i_m_p_l_ah_i_",
    /* [into] = */      "i_n_t_uu_",
    /* [is] = */        "i_z_",
    /* [island] = */    "ah_i_l_uh_n_d_",
    /* [john] = */      "j_o_n_",
    /* [july] = */      "j_uh_l_ah_i_",
    /* [live] = */      "l_i_v_",
    /* [lived] = */     "l_i_v_d_",
    /* [living] = */    "l_i_v_i_ng_",
    /* [many] = */      "m_e_n_ee_",
    /* [maybe] = */     "m_e_i_b_ee_",
    /* [meant] = */     "m_e_n_t_",
    /* [moreover] = */  "m_aw_r_uh_uu_v_uh_r_",
    /* [mr] = */        "m_i_s_t_uh_r_",
    /* [mrs] = */       "m_i_s_uh_z_",
    /* [nature] = */    "n_e_i_ch_uh_r_",
    /* [none] = */      "n_a_n_",
    /* [nothing] = */   "n_a_th_i_ng_",
    /* [nowhere] = */   "n_uh_uu_w_e_r_",
    /* [nuisance] = */  "n_uu_s_uh_n_s_",
    /* [of] = */        "uh_v_",
    /* [on] = */        "o_n_",
    /* [once] = */      "w_a_n_s_",
    /* [one] = */       "w_a_n_",
    /* [only] = */      "uh_uu_n_l_ee_",
    /* [over] = */      "uh_uu_v_uh_r_",
    /* [people] = */    "p_ee_p_uh_l_",
    /* [read] = */      "r_ee_d_",
    /* [reader] = */    "r_ee_d_uh_r_",
    /* [refer] = */     "r_i_f_er_r_",
    /* [says] = */      "s_e_z_",
    /* [seven] = */     "s_e_v_uh_n_",
    /* [shall] = */     "sh_aa_l_",
    /* [someone] = */   "s_a_m_w_uh_n_",
    /* [something] = */ "s_a_m_th_i_ng_",
    /* [than] = */      "dh_aa_n_",
    /* [that] = */      "dh_aa_t_",
    /* [the] = */       "dh_uh_",
    /* [their] = */     "dh_e_r_",
    /* [them] = */      "dh_e_m_",
    /* [there] = */     "dh_e_r_",
    /* [thereby] = */   "dh_e_r_b_ah_i_",
    /* [these] = */     "dh_ee_z_",
    /* [they] = */      "dh_e_i_",
    /* [this] = */      "dh_i_s_",
    /* [those] = */     "dh_uh_uu_z_",
    /* [to] = */        "t_uu_",
    /* [today] = */     "t_uh_d_e_i_",
    /* [tomorrow] = */  "t_uh_m_aw_r_uh_uu_",
    /* [tuesday] = */   "t_uu_z_d_e_i_",
    /* [two] = */       "t_uu_",
    /* [upon] = */      "uh_p_o_n_",
    /* [very] = */      "v_e_r_ee_",
    /* [water] = */     "w_o_t_uh_r_",
    /* [wednesday] = */ "_w_e_n_z_d_e_i_",
    /* [were] = */      "w_uh_r_",
    /* [who] = */       "h_uu_",
    /* [whom] = */      "h_uu_m_",
    /* [whose] = */     "h_uu_z_",
    /* [woman] = */     "w_u_m_uh_n_",
    /* [women] = */     "w_i_m_uh_n_",
    /* [yes] = */       "y_e_s_",
    /* [you] = */       "y_uu_",                      // Not in 1977 revision.
    /* [your] = */      "y_aw_r_",                    // Not in 1977 revision.
};


/*  STRUCTURE MAY BE MODIFIED IF MAX_ORGIN OR MAX_TERM_VAL CAN BE CONTAINED IN LESS THAN AN INT  */
static pktrie trie[TRIE_NODES] = {
    { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { '\'', 0,   49   },
    { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    },
    { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    },
    { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    },
    { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    },
    { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    },
    { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    },
    { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    },
    { 'a',  1,   12   }, { 'b',  0,   40   }, { 'c',  0,   50   }, { 'd',  0,   55   }, { 'e',  0,   78   }, { 'f',  0,   107  }, { 'g',  0,   127  }, { 'h',  0,   133  },
    { 'i',  0,   137  }, { 'j',  0,   146  }, { 'a',  0,   15   }, { 'l',  0,   159  }, { 'm',  0,   172  }, { 'n',  0,   185  }, { 'o',  0,   212  }, { 'p',  0,   219  },
    { 'k',  0,   10   }, { 'r',  0,   224  }, { 's',  0,   240  }, { 't',  0,   256  }, { 'u',  0,   283  }, { 'v',  0,   298  }, { 'w',  0,   304  }, { 'l',  0,   6    },
    { 'y',  0,   322  }, { 'n',  0,   11   }, { 'l',  0,   23   }, { 'p',  0,   19   }, { 'w',  0,   32   }, { 'r',  0,   35   }, { 's',  7,   0    }, { 'i',  2,   0    },
    { 'a',  0,   9    }, { 'y',  0,   16   }, { 's',  3,   0    }, { 'y',  4,   0    }, { 'r',  0,   29   }, { 'i',  0,   27   }, { 'l',  5,   0    }, { 'e',  6,   0    },
    { 'a',  0,   43   }, { 'c',  0,   42   }, { 'a',  0,   25   }, { 'e',  0,   36   }, { 'e',  0,   39   }, { 'u',  0,   28   }, { 's',  0,   44   }, { 'i',  0,   38   },
    { 'e',  8,   0    }, { 'n',  9,   0    }, { 'l',  0,   41   }, { 'n',  0,   46   }, { 'g',  10,  0    }, { 'w',  11,  0    }, { 'o',  0,   53   }, { 'o',  0,   31   },
    { 'd',  0,   33   }, { 'y',  12,  0    }, { 'h',  13,  0    }, { 'b',  0,   81   }, { 'u',  0,   45   }, { 'y',  14,  0    }, { 't',  0,   51   }, { 's',  0,   37   },
    { 'o',  0,   52   }, { 'g',  19,  0    }, { 'e',  0,   56   }, { 'p',  0,   47   }, { 't',  18,  0    }, { 'o',  16,  62   }, { 'i',  0,   63   }, { 'y',  15,  0    },
    { 'r',  21,  0    }, { 'n',  0,   1    }, { 's',  17,  0    }, { 'n',  0,   73   }, { 'n',  0,   59   }, { 'e',  20,  0    }, { 'a',  0,   64   }, { 'e',  0,   65   },
    { 's',  0,   60   }, { 'r',  0,   71   }, { 'l',  0,   61   }, { 'e',  0,   74   }, { 'n',  23,  0    }, { 'y',  22,  0    }, { 'v',  0,   79   }, { 'n',  24,  0    },
    { 'a',  0,   58   }, { 'l',  0,   75   }, { 'e',  25,  0    }, { 'n',  0,   88   }, { 'l',  0,   86   }, { 'i',  0,   82   }, { 'g',  0,   85   }, { 'n',  0,   92   },
    { 'e',  26,  0    }, { 't',  0,   188  }, { 'e',  0,   87   }, { 'v',  0,   94   }, { 'n',  0,   93   }, { 'i',  0,   90   }, { 'y',  0,   104  }, { 'n',  0,   99   },
    { 'r',  0,   83   }, { 'g',  28,  0    }, { 'e',  30,  0    }, { 'y',  29,  95   }, { 'e',  31,  0    }, { 'o',  0,   97   }, { 'n',  0,   102  }, { 'e',  0,   111  },
    { 'b',  0,   96   }, { 'r',  0,   98   }, { 'a',  0,   100  }, { 'i',  0,   103  }, { 'n',  0,   119  }, { 'r',  0,   101  }, { 'u',  0,   114  }, { 'a',  0,   109  },
    { 'l',  0,   110  }, { 'l',  0,   105  }, { 'a',  0,   106  }, { 'i',  0,   123  }, { 'r',  0,   115  }, { 'y',  32,  0    }, { 'd',  0,   122  }, { 'a',  0,   113  },
    { 'e',  0,   116  }, { 'y',  33,  0    }, { 'y',  34,  0    }, { 's',  35,  0    }, { 'g',  39,  0    }, { 'a',  0,   121  }, { 's',  0,   117  }, { 'a',  0,   128  },
    { 't',  36,  0    }, { 'e',  0,   135  }, { 'n',  0,   126  }, { 's',  37,  0    }, { 'e',  38,  0    }, { 'i',  0,   130  }, { 'v',  0,   136  }, { 'd',  40,  0    },
    { 'i',  0,   125  }, { 'r',  0,   140  }, { 'p',  0,   141  }, { 'u',  0,   124  }, { 's',  41,  0    }, { 'm',  0,   131  }, { 'n',  0,   132  }, { 't',  0,   142  },
    { 'l',  0,   129  }, { 'y',  42,  0    }, { 'l',  0,   157  }, { 's',  44,  143  }, { 'o',  43,  0    }, { 'a',  0,   145  }, { 'n',  0,   156  }, { 'd',  45,  0    },
    { 'o',  0,   154  }, { 'h',  0,   149  }, { 'n',  46,  0    }, { 'l',  0,   144  }, { 'd',  49,  0    }, { 'a',  0,   168  }, { 'u',  0,   152  }, { 'i',  0,   148  },
    { 'y',  47,  0    }, { 'v',  0,   166  }, { 'e',  48,  161  }, { 'n',  0,   167  }, { 'a',  0,   164  }, { 'g',  50,  0    }, { 'i',  0,   158  }, { 'y',  51,  0    },
    { 'e',  0,   165  }, { 'n',  0,   151  }, { 'b',  0,   175  }, { 'e',  52,  0    }, { 'e',  0,   169  }, { 'n',  0,   163  }, { 't',  53,  0    }, { 'o',  0,   171  },
    { 'e',  0,   174  }, { 'a',  0,   179  }, { 'o',  0,   170  }, { 'r',  0,   176  }, { 'y',  0,   177  }, { 'r',  55,  178  }, { 'c',  27,  0    }, { 'r',  54,  0    },
    { 'v',  0,   180  }, { 'u',  0,   183  }, { 'e',  58,  0    }, { 'n',  0,   190  }, { 's',  56,  0    }, { 'i',  0,   193  }, { 't',  0,   173  }, { 'o',  0,   182  },
    { 'r',  0,   282  }, { 't',  0,   195  }, { 'h',  0,   189  }, { 'g',  59,  0    }, { 'w',  0,   200  }, { 'u',  0,   203  }, { 'n',  0,   197  }, { 'h',  0,   204  },
    { 'e',  0,   192  }, { 'r',  0,   206  }, { 'e',  60,  0    }, { 'i',  0,   194  }, { 's',  0,   213  }, { 'a',  0,   201  }, { 'n',  0,   214  }, { 'e',  61,  0    },
    { 'c',  0,   211  }, { 'f',  62,  0    }, { 'c',  0,   215  }, { 'e',  64,  0    }, { 'e',  65,  0    }, { 'e',  0,   207  }, { 'y',  66,  0    }, { 'e',  0,   218  },
    { 'r',  67,  0    }, { 'n',  63,  216  }, { 'e',  68,  0    }, { 'l',  0,   198  }, { 'e',  0,   231  }, { 'd',  69,  233  }, { 'v',  0,   237  }, { 'a',  0,   226  },
    { 'o',  0,   220  }, { 'v',  0,   217  }, { 'l',  0,   222  }, { 'p',  0,   223  }, { 'f',  0,   235  }, { 'e',  0,   221  }, { 'r',  70,  0    }, { 'e',  0,   225  },
    { 'a',  0,   227  }, { 'e',  0,   230  }, { 'r',  71,  0    }, { 'n',  73,  0    }, { 'e',  0,   209  }, { 'a',  0,   238  }, { 's',  72,  0    }, { 'h',  0,   245  },
    { 'm',  0,   248  }, { 'l',  0,   239  }, { 'l',  74,  0    }, { 'y',  0,   228  }, { 'e',  0,   241  }, { 'e',  75,  0    }, { 'o',  0,   236  }, { 'o',  0,   243  },
    { 'n',  0,   249  }, { 'h',  0,   251  }, { 'a',  0,   254  }, { 'i',  0,   252  }, { 't',  0,   250  }, { 'g',  76,  0    }, { 'e',  79,  263  }, { 'h',  0,   258  },
    { 'r',  80,  0    }, { 'n',  0,   255  }, { 'i',  0,   261  }, { 'n',  77,  0    }, { 'e',  82,  268  }, { 'b',  0,   253  }, { 'o',  88,  281  }, { 'i',  0,   247  },
    { 'o',  0,   265  }, { 't',  78,  0    }, { 'e',  84,  0    }, { 'm',  81,  0    }, { 'u',  0,   284  }, { 'y',  83,  0    }, { 'w',  0,   286  }, { 's',  86,  0    },
    { 'r',  0,   264  }, { 's',  0,   270  }, { 'e',  87,  0    }, { 's',  0,   278  }, { 'd',  0,   376  }, { 'o',  0,   272  }, { 'e',  57,  0    }, { 'y',  85,  0    },
    { 'e',  0,   279  }, { 'r',  0,   274  }, { 'y',  89,  0    }, { 'r',  0,   280  }, { 'd',  0,   296  }, { 'm',  0,   271  }, { 'o',  0,   273  }, { 'w',  90,  0    },
    { 'a',  0,   275  }, { 's',  0,   289  }, { 'p',  0,   287  }, { 'y',  91,  0    }, { 'o',  92,  0    }, { 'o',  0,   290  }, { 'e',  0,   288  }, { 'n',  93,  0    },
    { 'a',  0,   291  }, { 'r',  0,   285  }, { 'e',  0,   295  }, { 'n',  0,   311  }, { 'e',  0,   310  }, { 'y',  94,  0    }, { 't',  0,   302  }, { 'h',  0,   306  },
    { 'r',  95,  0    }, { 'd',  0,   294  }, { 'a',  0,   297  }, { 'e',  0,   299  }, { 'd',  0,   314  }, { 's',  0,   313  }, { 'o',  0,   316  }, { 'e',  97,  0    },
    { 'o',  98,  312  }, { 'y',  96,  0    }, { 'e',  100, 0    }, { 's',  103, 0    }, { 'm',  99,  0    }, { 'a',  0,   319  }, { 'e',  0,   305  }, { 'r',  0,   315  },
    { 'm',  0,   325  }, { 'e',  0,   320  }, { 's',  0,   318  }, { 0,    0,   0    }, { 'n',  101, 0    }, { 'n',  102, 0    }, { 0,    0,   0    }, { 0,    0,   0    },
    { 'o',  0,   317  }, { 'u',  104, 321  }, { 'r',  105, 0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    },
    { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    },
    { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    },
    { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    },
    { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    }, { 0,    0,   0    },
    { 'a',  0,   266  },
};


int check_word_list(char *string, char **eow)
{
    int i = 0;
    char *t = string;

    string++;
    *(*eow) = 0;

    while (*string) {
        if (trie[index(*string) + i].val == *string) {
            int term = trie[index(*string) + i].term_state;
            if (!*(string + 1)) {
                if (!term)
                    break;
                string = m_string[term - 1];
                while (*string)
                    *t++ = *string++;
                *eow = t - 1;
                return(1);
            }
            i = trie[index(*string++) + i].next_org;
            if (!i)
                break;
        } else
            break;
    }

    *(*eow) = '#';
    return(0);
}

// escaped: \" \\ \'
void reprint_cwl_trie(void)
{
    for (int index = 0; index < TRIE_NODES; index++) {
        char ch = trie[index].val;
        if (ch == '"' || ch == '\\' || ch == '\'') {
            printf("{ '\\%c', ", ch);
        } else if (ch == 0) {
            printf("{ 0,    ");
        } else {
            printf("{ '%c',  ", ch);
        }
        assert(trie[index].term_state < 1000);
        printf("%-3d, %-4d }, ", trie[index].term_state, trie[index].next_org);
        if (((index + 1) % 8) == 0) {
            printf("\n");
        }
    }
    printf("\n");
}
