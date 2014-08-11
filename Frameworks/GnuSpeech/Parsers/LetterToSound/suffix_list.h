//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

/***********************************************************************

A list of suffixes to look for when searching in the main dictionary.
The following steps are taken when a word is not found in the
dictionary:

The "suffix" field is a suffix to identify.  If that suffix is
present, it is replaced with the contents of the "replacement" field,
and searched for again.  If found, the pronunciation returned from the
dictionary is augmented with the contents of the "pronunciation"
field, and returned as the pronunciation of the word.  Otherwise, the
other suffixes in this list are tried in order.  If none match, we
assume that no inflected form of the word is in the dictionary, and we
return NULL.

The list is organized with more specific cases first, falling through
to the more general ones.

There are certain exceptions that cannot be handled and should be put
in the dictionary.   "houses".

These SHOULD be ordered according to frequency, for speed.  However,
note the importance of keeping more specific cases first.  (The linear
order adopted here is a total ordering of the poset formed by this
requirement, and could be optimized as such.)

Modified by David Hill April 1995 to fix the dreaded /uh_d/ for dinal "-ed" in words like "dreaded".

Modified by David Hill, 95-05-18/19 to correct problems (e.g. using /t/ for final "-ed" in words like "defined"), and to add many new endings.

Modified again by David Hill 95-08-05 to add rules for "beaches" , "stresses", and "finishes".

***********************************************************************/


/*  DATA TYPES  *******************************************************/

struct SL {
    char *suffix;
    char *replacement;
    char *pronunciation;
};
typedef struct SL suffix_list_t;



/*  SUFFIX LIST  ******************************************************/

static suffix_list_t suffix_list[] = {
  {"ses","se",".i_z"},	   //   "horses" = "horse" + "es"
  {"ces","ce",".i_z"},	   //   "spices" = "spice" + "es"

/* 
 *  The next two are WRONG for voiced preceding cons, or preceding vowel;
 *   "candies", "ranges", "bids". Must add all relevant cases.
 *  {"es","e","_s"},	        "bites" = "bite" + "s"
 *  {"s","","_s"},	        "baits" = "bait" + "s"
 *
 *  The following fixes this:
 */

  {"aes","ae","_z"},
  {"bes","be","_z"},
  {"ches","ch","_i_z"},		//"beaches" = "beach" + "s"
  {"des","de","_z"},
  {"ees","ee","_z"},
  {"fes","fe","_s"},
  {"ges","ge",".i_z"},
  {"ies","y","_z"},
  {"ies","ie","_z"},
  {"kes","ke","_s"},
  {"les","le","_z"},
  {"mes","me","_z"},
  {"nes","ne","_z"},
  {"oes","oe","_z"},
  {"oes","o","_z"},
  {"pes","pe","_s"},
  {"phes","phe","_z"},
  {"res","re","_z"},
  {"sses","ss","_i_z"},		//"stresses" = "stress" + "s"
  {"shes","sh","_i_z"},		//"finishes" = "finish" + "s"
  {"tes","te","_s"},
  {"thes","the","_z"},
  {"ques","que","_s"},   	// "techniques" = "technique" + "s"
  {"ues","ue","_z"},
  {"ves","ve","_z"},
  {"wes","we","_z"},
  {"xes","x",".i_z"},		//"boxes" = "box" + "s"
  {"yes","ye","_z"},
  {"zes","ze",".i_z"},      	// "blazes" = "blaze" + "s"

  {"as","a","_z"},
  {"bs","b","_z"},
  {"cs","c","_s"},
  {"ds","d","_z"},
  {"es","e",".i_z"},	     //  because all other cases were caught above
  {"fs","f","_s"},
  {"gs","g","_z"},
  {"hs","h","_s"},	     //   "baths" pronounced "ba(theta)s" 
  {"is","i","_z"},
  {"ks","k","_s"},
  {"ls","l","_z"},
  {"ms","m","_z"},
  {"ns","n","_z"},
  {"os","o","_z"},
  {"ps","p","_s"},
  {"qs","q","_s"},	     //  "there are many Iraqs in the world today..."
  {"rs","r","_z"},
  {"ts","t","_s"},
  {"us","u","_z"},
  {"vs","v","_z"},	     //  how many words end in "v"? "revs"?
  {"ws","w","_z"},
  {"ys","y","_z"},

  {"ic","",".i_k"},	     //   "chauvinistic" = "chauvinist" + "ic"    

  {"ly","",".l_i"},	     //   "badly" = "bad" + "ly"

  {"iment","y",".m_uh_n_t"}, //   "embodiment" = "embody" + "ment"
  {"ment","",".m_uh_n_t"},   //   "banishment" = "banish" + "ment"

  {"ness","",".n_e_s"},	     //   "fairness" = "fair" + "ness"

  {"iest","y",".i_s_t"},  //   "heaviest" = "heavy" + "est"
  {"bbest","b",".i_s_t"}, //   "drabbest" = "drab" + "est"
  {"ddest","d",".i_s_t"}, //   "baddest" = "bad" + "est"
  {"dest","d",".i_s_t"},  //   "damndest" = "damned" + "est"
  {"ggest","g",".i_s_t"}, //   "biggest" = "big" + "est"
  {"iest","y",".i_s_t"},  //   "noisiest" = "noisy" + "est"
  {"mmest","m",".i_s_t"}, //   "slimmest"
  {"nnest","n",".i_s_t"}, //   "thinnest"
  {"ppest","p",".i_s_t"}, //   "flippest" = "flip" + "est"
  {"ttest","t",".i_s_t"}, //   "hottest"
  {"est","e",".i_s_t"},   //   "largest" = "large" + "est"
  {"est","",".i_s_t"},	  //   "hardest" = "hard" + "est"


  {"lled","l","_d"},	  //   "jewelled" = "jewel" + "ed"
  {"rred","r","_d"},	  //   "sparred" = "spar" + "ed"
  {"bbed","b","_d"},	  //   "robbed" = "rob" + "ed"
  {"dded","d",".i_d"},    //   "padded" = "pad" + "ed"
  {"gged","g","_d"},      //   "bagged" = "bag" + "ed"
  {"mmed","m","_d"},	  //   "slammed" = "slam" + "ed"
  {"nned","n","_d"},      //   "gunned" = "gun" + "ed"
  {"tted","t",".i_d"},    //   "batted" = "bat" + "ed"

  {"bed","be","_d"},	   //   "robed" = "robe" + "ed"
  {"ded","de",".i_d"},	   //   "noded" = "node" + "ed"
  {"ded","d",".i_d"},	   //   "loaded" = "load" + "ed"
  {"ged","ge","_d"},	   //   "swaged" = "swage" + "ed"
  {"ged","g","_d"},	   //   "banged" = "bang" + "ed"
  {"led","le","_d"},	   //   "riled" = "rile" + "ed"
  {"led","l","_d"},        //   "snarled" = "snarl" + "ed"
  {"med","me","_d"},	   //   "tamed" = "tame" + "ed"
  {"med","m","_d"},	   //   "aimed" = "aim" + "ed"
  {"ned","ne","_d"},       //   "defined" = "define" + "ed"
  {"ned","n","_d"},        //   "resigned" = "resign" + "ed"
  {"red","re","_d"},	   //   "fired" = "fire" + "ed"
  {"red","r","_d"},	   //   "aired" = "air" + "ed"
  {"ted","te",".i_d"},	   //   "spited" = "spite" + "ed"
  {"ted","t",".i_d"},	   //   "waited" = "wait" + "ed"
  {"ved","ve","_d"},       //   "grooved" = "groove" + "ed"
  {"wed","w","_d"},        //   "bowed" = "bow" + "ed"
  {"yed","ye","_d"},       //   "eyed" = "eye" + "ed"
  {"yed","y","_d"},        //   "boyed" = "boy" + "ed"
  {"zed","z","_d"},        //   "buzzed" = "buzz" + "ed"

  {"aed","a","_d"},	   //   "ouijaed" = "ouija" + "ed"
  {"aed","","_d"},	   //   
  {"eed","ee","_d"},	   //   "peed" = "pee" + "d"
  {"ied","i","_d"},        //   "hied" = "hi" + "ed"
  {"oed","oe","_d"},	   //   "hoed" = "hoe" + "ed"
  {"oed","o","_d"},	   //   "potatoed" = "potato" + "ed"
  {"ued","ue","_d"},       //   "hued" = "hue" + "ed"

  {"pped","p","_t"},       //   "slapped" = "slap" + "ed"
  {"ed","e","_t"},	   //   "faced" = "face" + "ed"
  {"ed","","_t"},	   //   "walked" = "walk" + "ed"

  {"bber","b",".uh_r"},	   //   "bobber" = "bob" + "er"
  {"dder","d",".uh_r"},	   //   "padder" = "pad" + "er"
  {"gger","g",".uh_r"},	   //   "bagger" = "bag" + "er"
  {"ier","y",".uh_r"},	   //   "happier" = "happy" + "er"
  {"ller","l",".uh_r"},	   //   "jeweller" = "jewel" + "er"
  {"mmer","m",".uh_r"},	   //   "slammer" = "slam" + "er"
  {"nner","n",".uh_r"},	   //   "runner" = "run" + "er"
  {"pper","p",".uh_r"},	   //   "flipper" = "flip" + "er"
  {"rrer","r",".uh_r"},	   //   "sparrer" = "spar" + "er"
  {"tter","t",".uh_r"},	   //   "batter" = "bat" + "er"
  {"er","e",".uh_r"},	   //   "slider" = "slide" + "er"
  {"er","",".uh_r"},	   //   "smaller" = "small" + "er"

  {"bbers","b",".uh_r_z"}, //   "bobbers" = "bob" + "ers"
  {"dders","d",".uh_r_z"}, //   "padders" = "pad" + "ers"
  {"ggers","g",".uh_r_z"}, //   "baggers" = "bag" + "ers"
  {"llers","l",".uh_r_z"}, //   "jewellers" = "jewel" + "ers"
  {"mmers","m",".uh_r_z"}, //   "slammers" = "slam" + "ers"
  {"nners","n",".uh_r_z"}, //   "runners" = "run" + "ers"
  {"ppers","p",".uh_r_z"}, //   "flippers" = "flip" + "ers"
  {"rrers","r",".uh_r_z"}, //   "sparrers" = "spar" + "ers"
  {"tters","t",".uh_r_z"}, //   "batters" = "bat" + "ers"
  {"ers","e",".uh_r_z"},   //   "sliders" = "slide" + "ers"
  {"ers","",".uh_r_z"},	   //   "derailers" = "derail" + "ers"

  {"cing","ck",".i_ng"},   //   "picnicing" = "picnick" + "ing"
  {"bbing","b",".i_ng"},   //   "bobbing" = "bob" + "ing"
  {"dding","d",".i_ng"},   //   "padding" = "pad" + "ing"
  {"gging","g",".i_ng"},   //   "bagging" = "bag" + "ing"
  {"lling","l",".i_ng"},   //   "quarrelling" = "quarrel" + "ing"
  {"mming","m",".i_ng"},   //   "slamming" = "slam" + "ing"
  {"nning","n",".i_ng"},   //   "running" = "run" + "ing"
  {"pping","p",".i_ng"},   //   "flipping" = "flip" + "ing"
  {"rring","r",".i_ng"},   //   "starring" = "star" + "ing"
  {"tting","t",".i_ng"},   //   "batting" = "bat" + "ing"
  {"ying","ye",".i_ng"},   //   "eying" = "eye" + "ing"
  {"ing","e",".i_ng"},	   //   "bouncing" = "bounce" + "ing"
  {"ing","",".i_ng"},	   //   "eating" = "eat" + "ing"
 
  {"iable","y",".uh_b_ll"},     //   "enviable" = "envy" + "able"
  {"ceable","ce","_s.uh.b_ll"}, //   "traceable" = "trace" + "able"
  {"geable","ge",".j_uh.b_ll"}, //   "changeable" = "change" + "able"
  {"rrable","r",".uh.b_ll"},    //   "conferrable" = "confer" + "able"
  {"bbable","b",".uh.b_ll"},    //   "grabbable" = "grab" + "able"
  {"ddable","d",".uh.b_ll"},	//   "kiddable" = "kid" + "able"
  {"ggable","g",".uh.b_ll"},	//   "baggable" = "bag" + "able"
  {"mmable","m",".uh.b_ll"},	//   "slammable" = "slam" + "able"
  {"nnable","n",".uh.b_ll"},	//   "runnable" = "run" + "able"
  {"ppable","p",".uh.b_ll"},	//   "flappable" = "flap" + "able"
  {"ttable","t",".uh.b_ll"},	//   "battable" = "bat" + "able"
  {"able","e",".uh.b_ll"},      //   "movable" = "move" + "able"
  {"able","",".uh.b_ll"},       //   "questionable" = "question" + "able"

  {"iable","y",".uh_b_l_i"},     //   "enviably" = "envy" + "ably"
  {"ceably","ce","_s.uh.b_l_i"}, //   "traceably" = "trace" + "ably"
  {"geably","ge",".j_uh.b_l_i"}, //   "changeably" = "change" + "ably"
  {"rrably","r",".uh.b_l_i"},    //   "conferrably" = "confer" + "ably"
  {"bbably","b",".uh.b_l_i"},    //   "grabbable" = "grab" + "ably"
  {"ddably","d",".uh.b_l_i"},	 //   "kiddably" = "kid" + "ably"
  {"ggably","g",".uh.b_l_i"},	 //   "baggably" = "bag" + "ably"
  {"mmably","m",".uh.b_l_i"},	 //   "slammably" = "slam" + "ably"
  {"nnably","n",".uh.b_l_i"},	 //   "runnably" = "run" + "ably"
  {"ppably","p",".uh.b_l_i"},	 //   "flappably" = "flap" + "ably"
  {"ttably","t",".uh.b_l_i"},	 //   "battably" = "bat" + "ably"
  {"ably","e",".uh.b_l_i"},      //   "palpably" = "palpable" + "ably"
  {"ably","",".uh.b_l_i"},       //   "questionably" = "question" + "ably"

  {"rry","r",".i"},              //   "furry" = "fur" + "y"
  {"bby","b",".i"},              //   "grabby" = "grab" + "y"
  {"bbie","b",".i"},	         //   "cabbie" = "cab" + "y"
  {"ddy","d",".i"},	         //   "kiddy" = "kid" + "y"
  {"ddie","d",".i"},	         //   "kiddie" = "kid" + "y"
  {"ggy","g",".i"},	         //   "buggy" = "bug" + "y"
  {"mmy","m",".i"},	         //   "tummy" = "tum" + "y"  (How frequent
  {"nny","n",".i"},	         //   "runny" = "run" + "y"   are these??)
  {"nnie","n",".i"},	         //   "bunnie" = "bun" + "y"
  {"ppy","p",".i"},	         //   "puppy" = "pup" + "y"
  {"tty","t",".i"},	         //   "ratty" = "rat" + "y"
  {"ttie","t",".i"},	         //   "rattie" = "rat" + "y"
  {"y","",".i"},                 //   "thrifty" = "thrift" + "y"

  {"ttance","t",".aa_n_s"},      //   "remittance" = "remit" + "ance"
  {"ance","e",".aa_n_s"},        //   "observance" = "observe" + "ance"
  {"ttances","t",".aa_n_s_i_z"}, //   "remittances" = "remit" + "ances"
  {"ances","e",".aa_n_s_i_z"},   //   "observances" = "observe" + "ances"

  {"iation","y",".e_i.sh_uh_n"},    //   "variation" = "vary" + "ation"
  {"iations","y",".e_i.sh_uh_n_z"}, //   "variations" = "vary" + "ations"
  {"ation","e",".e_i.sh_uh_n"},     //   "condensation" = "condense" + "ation"
  {"ation","",".e_i.sh_uh_n"},      //   "damnation" = "damn" + "ation"

  {"ate","e",".e_i_t"},          //   "condensate" = "condense" + "ate"
  {"ate","",".e_i_t"},           //   "condensate" = "condense" + "ate"

  {"ates","e",".e_i_t_s"},          //   "condensates" = "condense" + "ates"
  {"ates","",".e_i_t_s"},           //   "condensates" = "condense" + "ates"

  {"aholic","",".uh.h_o_l,i_k"}, //   "workaholic" = "work" + "aholic"
  {"aholics","",".uh.h_o_l,i_k_s"}, //   "workaholics" = "work" + "aholics"
  {"ality","e",".aa_l.i.t_i"},   //   "modality" = "mode" + "ality"
  {"ality","",".aa_l.i.t_i"},    //   "commonality" = "common" + "ality"
  {"alities","e",".aa_l.i.t_i_z"}, //   "modalities" = "mode" + "alities"
  {"alities","",".aa_l.i.t_i_z"},  //   "commonalities" = "common" + "alities"
  {"dom","",".d_uh_m"},	           //   "kingdom" = "king" + "dom"
  {"doms","",".d_uh_m_z"},          //   "kingdoms" = "king" + "doms"
  {"hood","",".h_u_d"},	           //   "sainthood" = "saint" + "hood"
  {"hoods","",".h_u_d_z"},	   //   "sainthoods" = "saint" + "hoods"
  {"like","",".l_ah_i_k"},         //   "birdlike" = "bird" + "like"
  {"ling","",".l_i_ng"},           //   "hatchling" = "hatch" + "ling"
  {"lings","",".l_i_ng_z"},        //   "hatchlings" = "hatch" + "lings"
  {"monger","",".m_a_n.g_uh_r"},   //   "warmonger" = "war" + "monger"
  {"mongers","",".m_a_n.g_uh_r_z"}, //   "warmongers" = "war" + "mongers"
  {"ship","",".sh_i_p"},           //   "kinship" = "kin" + "ship"
  {"ships","",".sh_i_p_s"},        //   "kinships" = "kin" + "ships"
  {"ville","",".v_i_ll"},          //   "squaresville" = "squares" + "ville"
  {"villes","",".v_i_ll_z"},       //   "squaresvilles" = "squares" + "villes"
  {"wise","",".w ah i z"},         //   "streetwise" = "street" + "wise"

  {"ie","y",""},	         //   "merrie" = "merry" + "<olde spellinge>"
  {"e","",""},	                 //   "olde" = "old" + "<olde spellinge>"


 {(char *)0,(char *)0,(char *)0}     //  END MARKER
};
