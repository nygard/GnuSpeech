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
 *  rule.c
 *  GnuSpeech
 *
 *  Version: 0.9.1
 *
 ******************************************************************************/

#import "rule.h"
#import "template.h"
#import "categories.h"
#import "phoneDescription.h"
#import "evaluate.h"
#import <stdlib.h>

/*  GLOBAL VARIABLES, LOCAL TO THIS FILE  */
static specifierStructPtr specifierHead;
static int number_of_specifiers;



void initRule(void)
{
	specifierHead = NULL;
	number_of_specifiers = 0;
}



specifierStructPtr governingRule(char *phone1,char *phone2)
{
    int i;
    specifierStructPtr current_specifier_ptr;
	
    /*  RETURN THE GOVERNING RULE FOR THE DIPHONE:  phone1/phone2  */
    current_specifier_ptr = specifierHead;
    for (i = 0; i < number_of_specifiers; i++) {
		if (evaluate(current_specifier_ptr->category1,phone1) &&
			evaluate(current_specifier_ptr->category2,phone2))
			break;
		
		current_specifier_ptr = current_specifier_ptr->next;
    }
    /*  IF HERE, WE KNOW THIS SPECIFIER IS THE RULE FOR THE DIPHONE  */
    return(current_specifier_ptr);
}



void writeDiphone(char *phone1,char *phone2,specifierStructPtr g_rule,
				  filterParamPtr filter_paramHead,FILE *fp,vm_address_t page)
{
    f_parameterPtr new_f_parameter();
    void free_f_parameter();
    f_parameterPtr f_parameterHead = NULL;
    f_parameterPtr current_f_parameter_ptr = NULL, temp_f_parameter_ptr;
    int number_of_f_parameters = 0;
	
    f_intervalPtr current_f_interval_ptr = NULL, temp_next_f_interval_ptr, new_f_interval();
    filterParamPtr current_filter_ptr;
    t_intervalPtr current_t_interval_ptr;
	
    int i, j, k;
    double begin_target, end_target, target_diff, current_value;
    int phone_length = 0, fixed_length = 0, proportional_length, excess, 
	regression_length = 0, sample_size;
	
    struct {
		int length;
		double regression_factor;
    } t_int[INTERVALS_MAX];
	
    struct {
		int length;
		double regression_factor;
		double abs_value;
		double rise;
    } t_sub_int[SUB_INTERVALS_MAX];
	
    specialEventStructPtr current_se_ptr;
    se_intervalPtr current_se_interval_ptr;
    sub_intervalPtr current_sub_interval_ptr;
	
    double delta, current_abs_value, held_abs_value = 0, previous_deviation = 0;
	
    start_timePtr start_timeHead, current_start_time_ptr, new_start_time(), temp_start_time_ptr;
    void free_start_time();
    int number_of_start_times;
    int coded_duration;
	
    int *page_offset_i;
    float *page_offset_f;
	
	/*
	 printf("\nDiphone: %s/%s\n",phone1,phone2);
	 printf("  Rule: [%s] >> [%s]\n",g_rule->category1,g_rule->category2);
	 */
	
    /*  GET SAMPLE SIZE FROM TEMPLATE  */
    sample_size = sampleValue();
	/*  printf("  sample_size = %-d\n",sample_size);  */
	
    /*  CALCULATE DIPHONE LENGTH, DEPENDING UPON RULE  */
    if (g_rule->duration.rule == DUR_RULE_P1) {
		/*	printf("  DUR_RULE_P1\n");  */
		phone_length = getPhoneLength(phone1);
    }
    else if (g_rule->duration.rule == DUR_RULE_P2) {
		/*	printf("  DUR_RULE_P2\n");  */
		phone_length = getPhoneLength(phone2);
    }
    else if (g_rule->duration.rule == DUR_RULE_AVG) {
		float p1, p2;
		/*	printf("  DUR_RULE_AVG\n");  */
		p1 = getPhoneLength(phone1);
		p2 = getPhoneLength(phone2);
		phone_length = nint(((p1 + p2) / 2.0) / (float)sample_size) * sample_size;
    }
    else if (g_rule->duration.rule == DUR_RULE_NORMAL) {
		float p1, p2, t1, t2;
		/*	printf("  DUR_RULE_NORMAL\n");  */
		/*  GET PHONE DURATION VALUES  */
		p1 = getPhoneLength(phone1);
		p2 = getPhoneLength(phone2);
		/*  GET TRANSITION DURATION VALUE FOR PHONE1  */
		if (getTransitionType(phone1) == T_DURATION_FIXED) {
			t1 = getTransitionDurationFixed(phone1);
		}
		else {
			t1 = getTransitionDurationProp(phone1) * p1;
		}
		/*  GET TRANSITION DURATION VALUE FOR PHONE2  */
		if (getTransitionType(phone2) == T_DURATION_FIXED) {
			t2 = getTransitionDurationFixed(phone2);
		}
		else {
			t2 = getTransitionDurationProp(phone2) * p2;
		}
		/*	printf("  p1 = %f  p2 = %f  t1 = %f  t2 = %f\n",p1,p2,t1,t2);  */
		/*  CALCULATE LENGTH  */
		phone_length = nint(((((p1-t1)/2.0) + t2 + ((p2-t2)/2.0))) / (float)sample_size)
	    * sample_size;
    }
    else if (g_rule->duration.rule == DUR_RULE_T_RIGHT) {
		float p1, p2, t1, t2;
		/*	printf("  DUR_RULE_T_RIGHT\n");  */
		/*  GET PHONE DURATION VALUES  */
		p1 = getPhoneLength(phone1);
		p2 = getPhoneLength(phone2);
		/*  GET TRANSITION DURATION VALUE FOR PHONE1  */
		if (getTransitionType(phone1) == T_DURATION_FIXED) {
			t1 = getTransitionDurationFixed(phone1);
		}
		else {
			t1 = getTransitionDurationProp(phone1) * p1;
		}
		/*  GET TRANSITION DURATION VALUE FOR PHONE2  */
		if (getTransitionType(phone2) == T_DURATION_FIXED) {
			t2 = getTransitionDurationFixed(phone2);
		}
		else {
			t2 = getTransitionDurationProp(phone2) * p2;
		}
		/*	printf("  p1 = %f  p2 = %f  t1 = %f  t2 = %f\n",p1,p2,t1,t2);  */
		/*  CALCULATE LENGTH  */
		phone_length = nint(((((p1-t1)/2.0) + t2 + (p2/2.0))) / (float)sample_size)
	    * sample_size;
    }
    else if (g_rule->duration.rule == DUR_RULE_T_LEFT) {
		float p1, p2, t1, t2;
		/*	printf("  DUR_RULE_T_LEFT\n");  */
		/*  GET PHONE DURATION VALUES  */
		p1 = getPhoneLength(phone1);
		p2 = getPhoneLength(phone2);
		/*  GET TRANSITION DURATION VALUE FOR PHONE1  */
		if (getTransitionType(phone1) == T_DURATION_FIXED) {
			t1 = getTransitionDurationFixed(phone1);
		}
		else {
			t1 = getTransitionDurationProp(phone1) * p1;
		}
		/*  GET TRANSITION DURATION VALUE FOR PHONE2  */
		if (getTransitionType(phone2) == T_DURATION_FIXED) {
			t2 = getTransitionDurationFixed(phone2);
		}
		else {
			t2 = getTransitionDurationProp(phone2) * p2;
		}
		/*	printf("  p1 = %f  p2 = %f  t1 = %f  t2 = %f\n",p1,p2,t1,t2);  */
		/*  CALCULATE LENGTH  */
		phone_length = nint((((p1/2.0) + t1 + ((p2-t2)/2.0))) / (float)sample_size)
	    * sample_size;
    }
    else if (g_rule->duration.rule == DUR_RULE_T_MIDDLE) {
		float p1, p2, fixed;
		/*	printf("  DUR_RULE_T_MIDDLE\n");  */
		/*  GET PHONE DURATION VALUES  */
		p1 = getPhoneLength(phone1);
		p2 = getPhoneLength(phone2);
		/*  GET FIXED VALUE  */
		fixed = g_rule->duration.fixed_length;
		/*	printf("  p1 = %f  p2 = %f  fixed = %f\n",p1,p2,fixed);  */
		/*  CALCULATE LENGTH  */
		phone_length = nint(((((p1-fixed)/2.0) + fixed + ((p2-fixed)/2.0))) / (float)sample_size)
	    * sample_size;
    }
    else if (g_rule->duration.rule == DUR_RULE_FIXED) {
		phone_length = g_rule->duration.fixed_length;
    }
	/*  printf("  phone_length = %-d\n",phone_length);  */
	
	
    /*  IF ARBITRARY INTERNAL SPLIT, USE PROPORTIONS FOR CALCULATING LENGTHS  */
    if (g_rule->split_mode == SPLIT_MODE_ARBITRARY) {
		/*	printf(" SPLIT_MODE_ARBITRARY\n");  */
		/*  FIND TOTAL FIXED LENGTH OF INTERVALS  */
		current_t_interval_ptr = g_rule->t_intervalHead;
		for (i = 0; i < g_rule->number_of_t_intervals; i++) {
			if (!(current_t_interval_ptr->proportional))
				fixed_length += (current_t_interval_ptr->duration.ival);
			current_t_interval_ptr = current_t_interval_ptr->next;
		}
		
		/*  CALCULATE TOTAL PROPORTIONAL LENGTH  */
		proportional_length = phone_length - fixed_length;
		
		/*  CALCULATE LENGTH OF EACH T_INTERVAL  */
		excess = proportional_length;
		current_t_interval_ptr = g_rule->t_intervalHead;
		for (i = 0; i < g_rule->number_of_t_intervals; i++) {
			if (current_t_interval_ptr->proportional) {
				/*  CALCULATE PROPORTIONAL INTERVAL, ROUND TO NEAREST SAMPLE  */
				t_int[i].length = 
				nint(((double)proportional_length * 
					  (double)current_t_interval_ptr->duration.fval)/
					 (double)sample_size) * sample_size;
				/*  MAKE SURE THE LENGTH IS GREATER THAN ZERO  */
				if (t_int[i].length <= 0)
					t_int[i].length = sample_size;
				/*  KEEP TRACK OF EXCESS  */
				excess -= t_int[i].length;
			}
			else {
				/*  IF FIXED, SIMPLY USE SPECIFIED FIXED DURATION  */
				t_int[i].length = current_t_interval_ptr->duration.ival;
			}
			
			current_t_interval_ptr = current_t_interval_ptr->next;
		}
		
		/*  IF EXCESS, ADJUST PROPORTIONAL INTERVALS SO THAT TOTAL LENGTH IS RIGHT  */
		/*  APPLY EXCESS TO FIRST PROPORTIONAL INTERVAL, IF POSSIBLE  */
		if (excess != 0) {
			int original_length;
			
			current_t_interval_ptr = g_rule->t_intervalHead;
			for (i = 0; i < g_rule->number_of_t_intervals; i++) {
				original_length = t_int[i].length;
				if (current_t_interval_ptr->proportional) {
					/*  APPLY EXCESS, MAKING SURE IT IS SPREAD EVENLY  */
					if (excess < (-sample_size))
						t_int[i].length += (excess + sample_size);
					else if (excess > sample_size)
						t_int[i].length += (excess - sample_size);
					else
						t_int[i].length += excess;
					/*  MAKE SURE THE LENGTH IS GREATER THAN ZERO  */
					if (t_int[i].length <= 0)
						t_int[i].length = sample_size;
					/*  CALCULATE LEFTOVER EXCESS  */
					excess += (original_length - t_int[i].length);
				}
				
				current_t_interval_ptr = current_t_interval_ptr->next;
			}
		}
    }
    /*  ELSE USE FORMULA TO CALCULATE LENGTHS  */
    else {
		int length_error = NO;
		/*	printf(" SPLIT_MODE_FORMULA\n");  */
		if (g_rule->duration.rule == DUR_RULE_NORMAL) {
			float p1, p2, t1, t2;
			/*	    printf("  DUR_RULE_NORMAL\n");  */
			/*  GET PHONE DURATION VALUES  */
			p1 = getPhoneLength(phone1);
			p2 = getPhoneLength(phone2);
			/*  GET TRANSITION DURATION VALUE FOR PHONE1  */
			if (getTransitionType(phone1) == T_DURATION_FIXED) {
				t1 = getTransitionDurationFixed(phone1);
			}
			else {
				t1 = getTransitionDurationProp(phone1) * p1;
			}
			/*  GET TRANSITION DURATION VALUE FOR PHONE2  */
			if (getTransitionType(phone2) == T_DURATION_FIXED) {
				t2 = getTransitionDurationFixed(phone2);
			}
			else {
				t2 = getTransitionDurationProp(phone2) * p2;
			}
			/*	    printf("  p1 = %f  p2 = %f  t1 = %f  t2 = %f\n",p1,p2,t1,t2);  */
			/*  CALCULATE FIRST INTERVAL LENGTH  */
			t_int[0].length = 
			nint(((p1-t1)/2.0)/(double)sample_size) * sample_size;
			/*  MAKE SURE THE LENGTH IS GREATER THAN ZERO  */
			if (t_int[0].length <= 0) {
				t_int[0].length = sample_size;
				length_error = YES;
			}
			/*  CALCULATE SECOND INTERVAL LENGTH  */
			t_int[1].length = 
			nint((t2)/(double)sample_size) * sample_size;
			/*  MAKE SURE THE LENGTH IS GREATER THAN ZERO  */
			if (t_int[1].length <= 0) {
				t_int[1].length = sample_size;
				length_error = YES;
			}
			/*  CALCULATE THIRD INTERVAL LENGTH (IS WHAT IS LEFT OVER)  */
			t_int[2].length = phone_length - (t_int[0].length + t_int[1].length);
			/*  MAKE SURE THE LENGTH IS GREATER THAN ZERO  */
			if (t_int[2].length <= 0) {
				t_int[2].length = sample_size;
				length_error = YES;
			}
			/*  IF LENGTH ERROR, RECALCULATE DIPHONE LENGTH  */
			if (length_error) {
				phone_length = t_int[0].length + t_int[1].length + t_int[2].length;
				/*		printf("   length error;  new phone_length = %-d\n",phone_length);  */
			}
			/*	    printf("  int1 = %d  int2 = %d  int3 = %d\n",
			 t_int[0].length,t_int[1].length,t_int[2].length);  */
		}
		else if (g_rule->duration.rule == DUR_RULE_T_RIGHT) {
			float p1, p2, t1, t2;
			/*	    printf("  DUR_RULE_T_RIGHT\n");  */
			/*  GET PHONE DURATION VALUES  */
			p1 = getPhoneLength(phone1);
			p2 = getPhoneLength(phone2);
			/*  GET TRANSITION DURATION VALUE FOR PHONE1  */
			if (getTransitionType(phone1) == T_DURATION_FIXED) {
				t1 = getTransitionDurationFixed(phone1);
			}
			else {
				t1 = getTransitionDurationProp(phone1) * p1;
			}
			/*  GET TRANSITION DURATION VALUE FOR PHONE2  */
			if (getTransitionType(phone2) == T_DURATION_FIXED) {
				t2 = getTransitionDurationFixed(phone2);
			}
			else {
				t2 = getTransitionDurationProp(phone2) * p2;
			}
			/*	    printf("  p1 = %f  p2 = %f  t1 = %f  t2 = %f\n",p1,p2,t1,t2);  */
			/*  CALCULATE FIRST INTERVAL LENGTH  */
			t_int[0].length = 
			nint(((p1-t1)/2.0)/(double)sample_size) * sample_size;
			/*  MAKE SURE THE LENGTH IS GREATER THAN ZERO  */
			if (t_int[0].length <= 0) {
				t_int[0].length = sample_size;
				length_error = YES;
			}
			/*  CALCULATE SECOND INTERVAL LENGTH  */
			t_int[1].length = 
			nint((t2)/(double)sample_size) * sample_size;
			/*  MAKE SURE THE LENGTH IS GREATER THAN ZERO  */
			if (t_int[1].length <= 0) {
				t_int[1].length = sample_size;
				length_error = YES;
			}
			/*  CALCULATE THIRD INTERVAL LENGTH (IS WHAT IS LEFT OVER)  */
			t_int[2].length = phone_length - (t_int[0].length + t_int[1].length);
			/*  MAKE SURE THE LENGTH IS GREATER THAN ZERO  */
			if (t_int[2].length <= 0) {
				t_int[2].length = sample_size;
				length_error = YES;
			}
			/*  IF LENGTH ERROR, RECALCULATE DIPHONE LENGTH  */
			if (length_error) {
				phone_length = t_int[0].length + t_int[1].length + t_int[2].length;
				/*		printf("   length error;  new phone_length = %-d\n",phone_length);  */
			}
			/*	    printf("  int1 = %d  int2 = %d  int3 = %d\n",
			 t_int[0].length,t_int[1].length,t_int[2].length);  */
		}
		else if (g_rule->duration.rule == DUR_RULE_T_LEFT) {
			float p1, p2, t1, t2;
			/*	    printf("  DUR_RULE_T_LEFT\n");  */
			/*  GET PHONE DURATION VALUES  */
			p1 = getPhoneLength(phone1);
			p2 = getPhoneLength(phone2);
			/*  GET TRANSITION DURATION VALUE FOR PHONE1  */
			if (getTransitionType(phone1) == T_DURATION_FIXED) {
				t1 = getTransitionDurationFixed(phone1);
			}
			else {
				t1 = getTransitionDurationProp(phone1) * p1;
			}
			/*  GET TRANSITION DURATION VALUE FOR PHONE2  */
			if (getTransitionType(phone2) == T_DURATION_FIXED) {
				t2 = getTransitionDurationFixed(phone2);
			}
			else {
				t2 = getTransitionDurationProp(phone2) * p2;
			}
			/*	    printf("  p1 = %f  p2 = %f  t1 = %f  t2 = %f\n",p1,p2,t1,t2);  */
			/*  CALCULATE FIRST INTERVAL LENGTH  */
			t_int[0].length = 
			nint(((p1)/2.0)/(double)sample_size) * sample_size;
			/*  MAKE SURE THE LENGTH IS GREATER THAN ZERO  */
			if (t_int[0].length <= 0) {
				t_int[0].length = sample_size;
				length_error = YES;
			}
			/*  CALCULATE SECOND INTERVAL LENGTH  */
			t_int[1].length = 
			nint((t1)/(double)sample_size) * sample_size;
			/*  MAKE SURE THE LENGTH IS GREATER THAN ZERO  */
			if (t_int[1].length <= 0) {
				t_int[1].length = sample_size;
				length_error = YES;
			}
			/*  CALCULATE THIRD INTERVAL LENGTH (IS WHAT IS LEFT OVER)  */
			t_int[2].length = phone_length - (t_int[0].length + t_int[1].length);
			/*  MAKE SURE THE LENGTH IS GREATER THAN ZERO  */
			if (t_int[2].length <= 0) {
				t_int[2].length = sample_size;
				length_error = YES;
			}
			/*  IF LENGTH ERROR, RECALCULATE DIPHONE LENGTH  */
			if (length_error) {
				phone_length = t_int[0].length + t_int[1].length + t_int[2].length;
				/*		printf("   length error;  new phone_length = %-d\n",phone_length);  */
			}
			/*	    printf("  int1 = %d  int2 = %d  int3 = %d\n",
			 t_int[0].length,t_int[1].length,t_int[2].length);  */
		}
		else if (g_rule->duration.rule == DUR_RULE_T_MIDDLE) {
			float p1, p2, fixed;
			/*	    printf("  DUR_RULE_T_MIDDLE\n");  */
			/*  GET PHONE DURATION VALUES  */
			p1 = getPhoneLength(phone1);
			p2 = getPhoneLength(phone2);
			/*  GET FIXED VALUE  */
			fixed = g_rule->duration.fixed_length;
			/*	    printf("  p1 = %f  p2 = %f  fixed = %f\n",p1,p2,fixed);  */
			/*  CALCULATE FIRST INTERVAL LENGTH  */
			t_int[0].length = 
			nint(((p1-fixed)/2.0)/(double)sample_size) * sample_size;
			/*  MAKE SURE THE LENGTH IS GREATER THAN ZERO  */
			if (t_int[0].length <= 0) {
				t_int[0].length = sample_size;
				length_error = YES;
			}
			/*  CALCULATE SECOND INTERVAL LENGTH  */
			t_int[1].length = 
			nint((fixed)/(double)sample_size) * sample_size;
			/*  MAKE SURE THE LENGTH IS GREATER THAN ZERO  */
			if (t_int[1].length <= 0) {
				t_int[1].length = sample_size;
				length_error = YES;
			}
			/*  CALCULATE THIRD INTERVAL LENGTH (IS WHAT IS LEFT OVER)  */
			t_int[2].length = phone_length - (t_int[0].length + t_int[1].length);
			/*  MAKE SURE THE LENGTH IS GREATER THAN ZERO  */
			if (t_int[2].length <= 0) {
				t_int[2].length = sample_size;
				length_error = YES;
			}
			/*  IF LENGTH ERROR, RECALCULATE DIPHONE LENGTH  */
			if (length_error) {
				phone_length = t_int[0].length + t_int[1].length + t_int[2].length;
				/*		printf("   length error;  new phone_length = %-d\n",phone_length);  */
			}
			/*	    printf("  int1 = %d  int2 = %d  int3 = %d\n",
			 t_int[0].length,t_int[1].length,t_int[2].length);  */
		}
    }
	
	
    /*  CALCULATE TOTAL REGRESSION LENGTH  */
    current_t_interval_ptr = g_rule->t_intervalHead;
    for (i = 0; i < g_rule->number_of_t_intervals; i++) {
		if (current_t_interval_ptr->regression)
			regression_length += t_int[i].length;
		
		current_t_interval_ptr = current_t_interval_ptr->next;
    }
	
    /*  CALCULATE REGRESSION FACTOR FOR EACH INTERVAL  */
    current_t_interval_ptr = g_rule->t_intervalHead;
    for (i = 0; i < g_rule->number_of_t_intervals; i++) {
		if (current_t_interval_ptr->regression)
			t_int[i].regression_factor = (double)t_int[i].length/(double)regression_length;
		else
			t_int[i].regression_factor = 0.0;
		
		current_t_interval_ptr = current_t_interval_ptr->next;
    }
    
	
	
    /*  ALLOCATE STRUCTURES FOR EACH FILTERED PARAMETER  */
    current_filter_ptr = filter_paramHead;
    while (current_filter_ptr != NULL) {
		/*  ALLOCATE A NEW STRUCTURE  */
		if (number_of_f_parameters == 0) {
			f_parameterHead = current_f_parameter_ptr = new_f_parameter();
		}
		else {
			current_f_parameter_ptr->next = new_f_parameter();
			current_f_parameter_ptr = current_f_parameter_ptr->next;
		}
		/*  SET VALUES IN STRUCT  */
		strcpy(current_f_parameter_ptr->symbol,current_filter_ptr->symbol);
		current_f_parameter_ptr->number_of_f_intervals = g_rule->number_of_t_intervals;
		/*  ALLOCATE INTERVAL STRUCTURES, IF NEEDED  */
		current_f_parameter_ptr->f_intervalHead = NULL;
		for (i = 0; i < current_f_parameter_ptr->number_of_f_intervals; i++) {
			/*  ALLOCATE A NEW STRUCTURE  */
			if (i == 0) {
				current_f_parameter_ptr->f_intervalHead = current_f_interval_ptr = 
				new_f_interval();
				current_f_interval_ptr->previous = NULL;
			}
			else {
				current_f_interval_ptr->next = new_f_interval();
				current_f_interval_ptr->next->previous = current_f_interval_ptr;
				current_f_interval_ptr = current_f_interval_ptr->next;
			}
			/*  INITIALIZE INTERVAL STRUCTURE  */
			current_f_interval_ptr->run = t_int[i].length;
			current_f_interval_ptr->regression_factor = t_int[i].regression_factor;
			current_f_interval_ptr->abs_value = 0.0;
			current_f_interval_ptr->rise = 0.0;
			current_f_interval_ptr->special_event = 0;
			current_f_interval_ptr->next = NULL;
		}
		current_f_parameter_ptr->next = NULL;
		
		current_filter_ptr = current_filter_ptr->next;
		number_of_f_parameters++;
    }
	
    /*  CALCULATE RISE AND ABSOLUTE VALUE FOR EACH PARAMETER, 
	 DEPENDING ON RULE AND TARGET VALUES  */
    current_f_parameter_ptr = f_parameterHead;
    for (i = 0; i < number_of_f_parameters; i++) {
		double minimum, maximum, overflow;
		/*	printf("  f_parameter = %s\n",current_f_parameter_ptr->symbol);  */
		/*  GET BEGIN AND END TARGET VALUES  */
		current_value = begin_target = 
	    getTarget(phone1,current_f_parameter_ptr->symbol);
		end_target = getTarget(phone2,current_f_parameter_ptr->symbol);
		target_diff = end_target - begin_target;
		
		/*  CALCULATE RISE VALUES, DEPENDING ON MODE  */
		if (g_rule->t_interval_mode == FIXED_RISE_MODE) {
			current_t_interval_ptr = g_rule->t_intervalHead;
			current_f_interval_ptr = current_f_parameter_ptr->f_intervalHead;
			for (j = 0; j < current_f_parameter_ptr->number_of_f_intervals; j++) {
				current_f_interval_ptr->abs_value = current_value;
				current_f_interval_ptr->rise = target_diff * (current_t_interval_ptr->rise);
				current_value += (current_f_interval_ptr->rise);
				
				current_f_interval_ptr = current_f_interval_ptr->next;
				current_t_interval_ptr = current_t_interval_ptr->next;
			}
		}
		else if (g_rule->t_interval_mode == SLOPE_RATIO_MODE) {
			/*  CALCULATE REFERENCE SLOPE  */
			double m_ref, sum = 0.0;
			current_t_interval_ptr = g_rule->t_intervalHead;
			current_f_interval_ptr = current_f_parameter_ptr->f_intervalHead;
			for (j = 0; j < current_f_parameter_ptr->number_of_f_intervals; j++) {
				sum += (current_t_interval_ptr->slope_ratio * (double)current_f_interval_ptr->run);
				
				current_f_interval_ptr = current_f_interval_ptr->next;
				current_t_interval_ptr = current_t_interval_ptr->next;
			}
			m_ref = target_diff / sum;
			/*  CALCULATE RISE VALUES  */
			current_t_interval_ptr = g_rule->t_intervalHead;
			current_f_interval_ptr = current_f_parameter_ptr->f_intervalHead;
			for (j = 0; j < current_f_parameter_ptr->number_of_f_intervals; j++) {
				current_f_interval_ptr->abs_value = current_value;
				current_f_interval_ptr->rise = 
				current_t_interval_ptr->slope_ratio * m_ref * 
				(double)current_f_interval_ptr->run;
				current_value += (current_f_interval_ptr->rise);
				
				current_f_interval_ptr = current_f_interval_ptr->next;
				current_t_interval_ptr = current_t_interval_ptr->next;
			}
		}
		
		/*  MAKE SURE ABS VALUES ARE IN RANGE; ADJUST IF NECESSARY  */
		/*  ANCHOR POINTS ARE IGNORED  */
		/*  GET THE MINIMUM AND MAXIMUM FOR THE PARAMETER  */
		minimum = parameterSymMinimum(current_f_parameter_ptr->symbol);
		maximum = parameterSymMaximum(current_f_parameter_ptr->symbol);
		
		current_f_interval_ptr = current_f_parameter_ptr->f_intervalHead;
		for (j = 0; j < current_f_parameter_ptr->number_of_f_intervals; j++) {
			if (current_f_interval_ptr->abs_value > maximum) {
				overflow = current_f_interval_ptr->abs_value - maximum;
				current_f_interval_ptr->previous->rise -= overflow;
				current_f_interval_ptr->abs_value -= overflow;
				if (current_f_interval_ptr->next != NULL)
					current_f_interval_ptr->rise = 
					current_f_interval_ptr->next->abs_value - current_f_interval_ptr->abs_value;
				else
					current_f_interval_ptr->rise = end_target - current_f_interval_ptr->abs_value;
			}
			else if (current_f_interval_ptr->abs_value < minimum) {
				overflow = current_f_interval_ptr->abs_value - minimum;
				current_f_interval_ptr->previous->rise -= overflow;
				current_f_interval_ptr->abs_value -= overflow;
				if (current_f_interval_ptr->next != NULL)
					current_f_interval_ptr->rise = 
					current_f_interval_ptr->next->abs_value - current_f_interval_ptr->abs_value;
				else
					current_f_interval_ptr->rise = end_target - current_f_interval_ptr->abs_value;
			}
			
			current_f_interval_ptr = current_f_interval_ptr->next;
		}
		
		/*  PRINT OUT UPDATED PARAMETER VALUES  */
		/*
		 printf("    adjusted parameter values\n");
		 
		 current_f_interval_ptr = current_f_parameter_ptr->f_intervalHead;
		 for (j = 0; j < current_f_parameter_ptr->number_of_f_intervals; j++) {
		 printf("      %-d: abs_value = %f  rise = %f  run = %-d  regression_factor = %f delta = %f\n",
		 j,current_f_interval_ptr->abs_value,current_f_interval_ptr->rise,
		 current_f_interval_ptr->run,current_f_interval_ptr->regression_factor,
		 (current_f_interval_ptr->rise/(double)current_f_interval_ptr->run) );
		 if (j == (current_f_parameter_ptr->number_of_f_intervals - 1))
		 printf("      end value = %f\n",
		 (current_f_interval_ptr->abs_value + current_f_interval_ptr->rise));
		 
		 current_f_interval_ptr = current_f_interval_ptr->next;
		 }
		 */
		
		/*  ADD SPECIAL EVENTS HERE, IF ANY ON THIS PARAMETER  */
		current_se_ptr = g_rule->specialEventHead;
		for (j = 0; j < g_rule->number_of_special_events; j++) {
			if (!strcmp(current_f_parameter_ptr->symbol,current_se_ptr->symbol)) {
				int t_interval_length;
				/*  WE HAVE A MATCH TO A SPECIAL EVENT  */
				/*		printf("    Special event match:  %s\n",current_f_parameter_ptr->symbol);  */
				
				/*  THE FOLLOWING ASSUME ABSOLUTE DEVIATION MODE  */
				/*  ADJUST (AND IF NECESSARY, SUBDIVIDE) EACH INTERVAL IN ORDER  */
				current_se_interval_ptr = current_se_ptr->se_intervalHead;
				current_f_interval_ptr = current_f_parameter_ptr->f_intervalHead;
				while (current_se_interval_ptr != NULL) {
					/*  GET LENGTH OF F_INTERVAL  */
					t_interval_length = current_f_interval_ptr->run;
					
					/*  FIND TOTAL FIXED LENGTH OF SUB-INTERVALS  */
					fixed_length = 0;
					current_sub_interval_ptr = current_se_interval_ptr->sub_intervalHead;
					for (k = 0; k < current_se_interval_ptr->number_of_sub_intervals; k++) {
						if (!(current_sub_interval_ptr->proportional))
							fixed_length += (current_sub_interval_ptr->duration.ival);
						current_sub_interval_ptr = current_sub_interval_ptr->next;
					}
					
					/*  CALCULATE TOTAL PROPORTIONAL LENGTH  */
					proportional_length = t_interval_length - fixed_length;
					
					/*  CALCULATE LENGTH OF EACH SUB_INTERVAL  */
					excess = proportional_length;
					current_sub_interval_ptr = current_se_interval_ptr->sub_intervalHead;
					for (k = 0; k < current_se_interval_ptr->number_of_sub_intervals; k++) {
						if (current_sub_interval_ptr->proportional) {
							/*  CALCULATE PROPORTIONAL INTERVAL, ROUND TO NEAREST SAMPLE  */
							t_sub_int[k].length = 
							nint(
								 ((double)proportional_length * current_sub_interval_ptr->duration.fval)/
								 (double)sample_size) * sample_size;
							/*  MAKE SURE THE LENGTH IS GREATER THAN ZERO  */
							if (t_sub_int[k].length <= 0)
								t_sub_int[k].length = sample_size;
							/*  KEEP TRACK OF EXCESS  */
							excess -= t_sub_int[k].length;
						}
						else {
							/*  IF FIXED, SIMPLY USE SPECIFIED FIXED DURATION  */
							t_sub_int[k].length = current_sub_interval_ptr->duration.ival;
						}
						
						current_sub_interval_ptr = current_sub_interval_ptr->next;
					}
					
					/*  IF EXCESS, ADJUST PROPORTIONAL INTERVALS SO THAT TOTAL LENGTH IS RIGHT  */
					/*  APPLY EXCESS TO FIRST PROPORTIONAL INTERVAL, IF POSSIBLE  */
					if (excess != 0) {
						int original_length;
						
						current_sub_interval_ptr = current_se_interval_ptr->sub_intervalHead;
						for (k = 0; k < current_se_interval_ptr->number_of_sub_intervals; k++) {
							original_length = t_sub_int[k].length;
							if (current_sub_interval_ptr->proportional) {
								/*  APPLY EXCESS, MAKING SURE IT IS SPREAD EVENLY  */
								if (excess < (-sample_size))
									t_sub_int[k].length += (excess + sample_size);
								else if (excess > sample_size)
									t_sub_int[k].length += (excess - sample_size);
								else
									t_sub_int[k].length += excess;
								/*  MAKE SURE THE LENGTH IS GREATER THAN ZERO  */
								if (t_sub_int[k].length <= 0)
									t_sub_int[k].length = sample_size;
								/*  CALCULATE LEFTOVER EXCESS  */
								excess += (original_length - t_sub_int[k].length);
							}
							
							current_sub_interval_ptr = current_sub_interval_ptr->next;
						}
					}
					
					/*  CALCULATE REGRESSION FOR EACH SUB-INTERVAL  */
					for (k = 0; k < current_se_interval_ptr->number_of_sub_intervals; k++) {
						t_sub_int[k].regression_factor = current_f_interval_ptr->regression_factor * 
						((double)t_sub_int[k].length/(double)t_interval_length);
					}
					
					/*  CALCULATE UN-DEVIATED ABSOLUTE VALUES FOR EVERY SUB-INTERVAL  */
					delta = current_f_interval_ptr->rise/(double)current_f_interval_ptr->run;
					current_abs_value = current_f_interval_ptr->abs_value;
					for (k = 0; k < current_se_interval_ptr->number_of_sub_intervals; k++) {
						t_sub_int[k].abs_value = current_abs_value;
						t_sub_int[k].rise = (double)t_sub_int[k].length * delta;
						current_abs_value += t_sub_int[k].rise;
					}
					
					/*  ADD IN DEVIATION TO EVERY SUB-INTERVAL BY ADDING DELTAS  */
					if (current_f_interval_ptr->previous == NULL) {
						held_abs_value = current_f_interval_ptr->abs_value;
						previous_deviation = 0.0;
					}
					current_sub_interval_ptr = current_se_interval_ptr->sub_intervalHead;
					for (k = 0; k < current_se_interval_ptr->number_of_sub_intervals; k++) {
						double dev_rise;
						/*  ABSOLUTE VALUE IS HELD OVER FROM PREVIOUS INTERVAL  */
						t_sub_int[k].abs_value = held_abs_value;
						/*  CALCULATE DEVIATION RISE  */
						dev_rise = current_sub_interval_ptr->rise - previous_deviation;
						previous_deviation += dev_rise;
						/*  CALCULATE HELD ABSOLUTE VALUE  */
						held_abs_value += (t_sub_int[k].rise + dev_rise);
						t_sub_int[k].rise = held_abs_value - t_sub_int[k].abs_value;
						
						current_sub_interval_ptr = current_sub_interval_ptr->next;
					}
					
					/*  ADD SPECIAL EVENTS INTO F_INTERVAL LINKED LIST  */
					/*  THE FIRST SPECIAL EVENT IS THE SAME AS THE CURRENT F_INTERVAL  */
					current_f_interval_ptr->run = t_sub_int[0].length;
					current_f_interval_ptr->regression_factor = t_sub_int[0].regression_factor;
					current_f_interval_ptr->abs_value = t_sub_int[0].abs_value;
					current_f_interval_ptr->rise = t_sub_int[0].rise;
					
					/*  ALLOCATE NEW F_INTERVAL STRUCTURES  */
					temp_next_f_interval_ptr = current_f_interval_ptr->next;
					for (k = 1; k < current_se_interval_ptr->number_of_sub_intervals; k++) {
						/*  ALLOCATE THE STRUCTURE AND UPDATE POINTER  */
						current_f_interval_ptr->next = new_f_interval();
						current_f_interval_ptr->next->previous = current_f_interval_ptr;
						current_f_interval_ptr = current_f_interval_ptr->next;
						/*  TRANSFER VALUES FROM ARRAY TO STRUCTURE  */
						current_f_interval_ptr->run = t_sub_int[k].length;
						current_f_interval_ptr->regression_factor = t_sub_int[k].regression_factor;
						current_f_interval_ptr->abs_value = t_sub_int[k].abs_value;
						current_f_interval_ptr->rise = t_sub_int[k].rise;
						/*  MARK AS SPECIAL EVENT  */
						current_f_interval_ptr->special_event = 1;
						/*  UPDATE NUMBER OF F_INTERVALS  */
						current_f_parameter_ptr->number_of_f_intervals += 1;
					}
					/*  TIE INTO REST OF F_INTERVAL LIST  */
					current_f_interval_ptr->next = temp_next_f_interval_ptr;
					if (current_f_interval_ptr->next != NULL)
						current_f_interval_ptr->next->previous = current_f_interval_ptr;
					
					/*  GO TO NEXT F_INTERVAL AND NEXT SE_INTERVAL */
					current_f_interval_ptr = current_f_interval_ptr->next;
					current_se_interval_ptr = current_se_interval_ptr->next;
				}
				
				/*  MAKE SURE ABS VALUES ARE IN RANGE; ADJUST IF NECESSARY  */
				/*  ANCHOR POINTS ARE IGNORED  */
				current_f_interval_ptr = current_f_parameter_ptr->f_intervalHead;
				for (k = 0; k < current_f_parameter_ptr->number_of_f_intervals; k++) {
					if (current_f_interval_ptr->abs_value > maximum) {
						overflow = current_f_interval_ptr->abs_value - maximum;
						current_f_interval_ptr->previous->rise -= overflow;
						current_f_interval_ptr->abs_value -= overflow;
						if (current_f_interval_ptr->next != NULL)
							current_f_interval_ptr->rise = 
							current_f_interval_ptr->next->abs_value - current_f_interval_ptr->abs_value;
						else
							current_f_interval_ptr->rise = end_target - current_f_interval_ptr->abs_value;
					}
					else if (current_f_interval_ptr->abs_value < minimum) {
						overflow = current_f_interval_ptr->abs_value - minimum;
						current_f_interval_ptr->previous->rise -= overflow;
						current_f_interval_ptr->abs_value -= overflow;
						if (current_f_interval_ptr->next != NULL)
							current_f_interval_ptr->rise = 
							current_f_interval_ptr->next->abs_value - current_f_interval_ptr->abs_value;
						else
							current_f_interval_ptr->rise = end_target - current_f_interval_ptr->abs_value;
					}
					
					current_f_interval_ptr = current_f_interval_ptr->next;
				}
				
				/*  PRINT OUT UPDATED PARAMETER VALUES  */
				/*
				 printf("    adjusted parameter values\n");
				 current_f_interval_ptr = current_f_parameter_ptr->f_intervalHead;
				 for (k = 0; k < current_f_parameter_ptr->number_of_f_intervals; k++) {
				 printf("      %-d: abs_value = %f  rise = %f  run = %-d  regression = %f se = %-d\n",
				 k,current_f_interval_ptr->abs_value,current_f_interval_ptr->rise,
				 current_f_interval_ptr->run,current_f_interval_ptr->regression_factor,
				 current_f_interval_ptr->special_event );
				 if (k == (current_f_parameter_ptr->number_of_f_intervals - 1))
				 printf("      end value = %f\n",
				 (current_f_interval_ptr->abs_value + current_f_interval_ptr->rise));
				 
				 current_f_interval_ptr = current_f_interval_ptr->next;
				 }
				 */
				
				/*  BREAK OUT OF LOOP  */
				break;
			}
			current_se_ptr = current_se_ptr->next;
		}
		
		/*  UPDATE TO NEXT PARAMETER  */
		current_f_parameter_ptr = current_f_parameter_ptr->next;
    }
	
    /*  CONSOLODATE ALL PARAMETERS  */
    /*  FIND ALL UNIQUE START TIMES;  ALLOCATE A NODE FOR EACH  */
    number_of_start_times = 0;
    start_timeHead = NULL;
    current_f_parameter_ptr = f_parameterHead;
    for (i = 0; i < number_of_f_parameters; i++) {
		int start_time = 0;
		current_f_interval_ptr = current_f_parameter_ptr->f_intervalHead;
		for (j = 0; j < current_f_parameter_ptr->number_of_f_intervals; j++) {
			/*  SEE IF START TIME IS UNIQUE  */
			int unique = YES;
			current_start_time_ptr = start_timeHead;
			for (k = 0; k < number_of_start_times; k++) {
				if (current_start_time_ptr->value == start_time) {
					unique = NO;
					break;
				}
				current_start_time_ptr = current_start_time_ptr->next;
			}
			/*  IF START TIME IS UNIQUE, ALLOCATE A NODE FOR IT AND STORE  */
			if (unique) {
				if (number_of_start_times == 0) {
					start_timeHead = current_start_time_ptr = new_start_time();
					current_start_time_ptr->previous = NULL;
				}
				else {
					/*  FIND END OF LIST  */
					current_start_time_ptr = start_timeHead;
					for (k = 1; k < number_of_start_times; k++)
						current_start_time_ptr = current_start_time_ptr->next;
					/*  ALLOCATE NODE ON END OF LIST  */
					current_start_time_ptr->next = new_start_time();
					current_start_time_ptr->next->previous = current_start_time_ptr;
					current_start_time_ptr = current_start_time_ptr->next;
				}
				/*  INITIALIZE NODE  */
				current_start_time_ptr->next = NULL;
				current_start_time_ptr->value = start_time;
				current_start_time_ptr->special_event = current_f_interval_ptr->special_event;
				/*  UPDATE NUMBER OF START TIME NODES  */
				number_of_start_times++;
			}
			
			start_time += current_f_interval_ptr->run;
			current_f_interval_ptr = current_f_interval_ptr->next;
		}
		
		current_f_parameter_ptr = current_f_parameter_ptr->next;
    }
    /*  TEMPORARY:  WRITE OUT START TIMES  */
	/*
	 printf("    number_of_start_times = %-d\n",number_of_start_times);
	 current_start_time_ptr = start_timeHead;
	 for (i = 0; i < number_of_start_times; i++) {
	 printf("      %-d:  value = %-d  se = %-d\n",
	 i,current_start_time_ptr->value,current_start_time_ptr->special_event);
	 current_start_time_ptr = current_start_time_ptr->next;
	 }
	 */
	
    /*  SORT THE START TIMES USING INSERTION SORT  */
    current_start_time_ptr = start_timeHead->next;
    for (j = 1; j < number_of_start_times; j++) {
		start_timePtr second_start_time_ptr = current_start_time_ptr->previous;
		int a = current_start_time_ptr->value;
		int b = current_start_time_ptr->special_event;
		
		while ((second_start_time_ptr != NULL) && (second_start_time_ptr->value > a)) {
			second_start_time_ptr->next->value = second_start_time_ptr->value;
			second_start_time_ptr->next->special_event = second_start_time_ptr->special_event;
			
			second_start_time_ptr = second_start_time_ptr->previous;
		}
		second_start_time_ptr->next->value = a;
		second_start_time_ptr->next->special_event = b;
		
		current_start_time_ptr = current_start_time_ptr->next;
    }
	
    /*  TEMPORARY:  WRITE OUT START TIMES  */
	/*
	 printf("    sorted:  number_of_start_times = %-d\n",number_of_start_times);
	 current_start_time_ptr = start_timeHead;
	 for (i = 0; i < number_of_start_times; i++) {
	 printf("      %-d:  value = %-d  se = %-d\n",
	 i,current_start_time_ptr->value,current_start_time_ptr->special_event);
	 current_start_time_ptr = current_start_time_ptr->next;
	 }
	 */
	
    /*  WRITE TO FILE AND/OR PAGE OF VM  */
    page_offset_i = (int *)page;
    page_offset_f = (float *)page;
	
    /*  DIPHONE HEADER  */
    if (fp != NULL)
		fwrite((char *)&number_of_start_times,sizeof(number_of_start_times),1,fp);
    if (page != 0) {
		*(page_offset_i++) = number_of_start_times;
		page_offset_f = (float *)page_offset_i;
    }
	/*  printf("  number_of_intervals = %-d\n",number_of_start_times);  */
	
    coded_duration = phone_length/sample_size;
    if (fp != NULL)
		fwrite((char *)&coded_duration,sizeof(coded_duration),1,fp);
    if (page != 0) {
		*(page_offset_i++) = coded_duration;
		page_offset_f = (float *)page_offset_i;
    }
	/*  printf("  total_duration = %-d; in samples = %-d\n",phone_length,coded_duration);  */
	
    /*  INDIVIDUAL INTERVALS  */
    current_start_time_ptr = start_timeHead;
    for (i = 0; i < number_of_start_times; i++) {
		/*  CALCULATE HEADER  */
		int duration, interval_start_time;
		float regression;
		/*  DURATION  */
		if (current_start_time_ptr->next != NULL)
			duration = current_start_time_ptr->next->value - current_start_time_ptr->value;
		else
			duration = phone_length - current_start_time_ptr->value;
		coded_duration = current_start_time_ptr->special_event ? 
	    ((duration/sample_size)|0x80000000) : (duration/sample_size);
		
		if (fp != NULL)
			fwrite((char *)&coded_duration,sizeof(coded_duration),1,fp);
		if (page != 0) {
			*(page_offset_i++) = coded_duration;
			page_offset_f = (float *)page_offset_i;
		}
		/*	printf("    duration = %-d; in samples = %-d  se = %-d coded duration = %-d\n",
		 duration,(duration/sample_size),current_start_time_ptr->special_event,coded_duration);  */
		
		/*  REGRESSION FACTOR, USING FIRST PARAMETER  */
		interval_start_time = 0;
		current_f_interval_ptr = f_parameterHead->f_intervalHead;
		for (j = 0; j < f_parameterHead->number_of_f_intervals; j++) {
			if ((interval_start_time + current_f_interval_ptr->run) > current_start_time_ptr->value) {
				regression = (float)(current_f_interval_ptr->regression_factor * 
									 ((double)duration/(double)current_f_interval_ptr->run));
				if (fp != NULL)
					fwrite((char *)&regression,sizeof(regression),1,fp);
				if (page != 0) {
					*(page_offset_f++) = regression;
					page_offset_i = (int *)page_offset_f;
				}
				/*		printf("    regression_factor = %f\n",regression);  */
				break;
			}
			
			interval_start_time += current_f_interval_ptr->run;
			current_f_interval_ptr = current_f_interval_ptr->next;
		}
		/*  CALCULATE INDIVIDUAL PARAMETERS  */
		current_f_parameter_ptr = f_parameterHead;
		for (j = 0; j < number_of_f_parameters; j++) {
			float calculated_rise;
			/*  FIND THE F_INTERVAL IN WHICH THE CURRENT START TIME OCCURS  */
			interval_start_time = 0;
			current_f_interval_ptr = current_f_parameter_ptr->f_intervalHead;
			for (k = 0; k < current_f_parameter_ptr->number_of_f_intervals; k++) {
				if ((interval_start_time + current_f_interval_ptr->run) > current_start_time_ptr->value)
					break;
				
				interval_start_time += current_f_interval_ptr->run;
				current_f_interval_ptr = current_f_interval_ptr->next;
			}
			/*  CALCULATE RISE FOR THIS SORTED INTERVAL  */
			calculated_rise = 
			(float)((current_f_interval_ptr->rise * (double)duration)/(double)current_f_interval_ptr->run);
			if (fp != NULL)
				fwrite((char *)&calculated_rise,sizeof(calculated_rise),1,fp);
			if (page != 0) {
				*(page_offset_f++) = calculated_rise;
				page_offset_i = (int *)page_offset_f;
			}
			/*	    printf("      parameter[%s] rise = %f\n",current_f_parameter_ptr->symbol,calculated_rise);  */
			
			current_f_parameter_ptr = current_f_parameter_ptr->next;
		}
		
		
		current_start_time_ptr = current_start_time_ptr->next;
    }
    
	
    /*  FREE ALL START TIME NODES  */
    current_start_time_ptr = start_timeHead;
    for (i = 0; i < number_of_start_times; i++) {
		temp_start_time_ptr = current_start_time_ptr;
		current_start_time_ptr = current_start_time_ptr->next;
		free_start_time(temp_start_time_ptr);
    }
	
    /*  FREE ALL F_PARAMETERS  */
    current_f_parameter_ptr = f_parameterHead;
    for (i = 0; i < number_of_f_parameters; i++) {
		temp_f_parameter_ptr = current_f_parameter_ptr;
		current_f_parameter_ptr = current_f_parameter_ptr->next;
		free_f_parameter(temp_f_parameter_ptr);
    }
	
}



void readFromFileRule(FILE *fp1)
{
    int i, j, k, l;
    int category_length;
    specifierStructPtr current_specifier_ptr, temp_specifier_ptr;
    t_intervalPtr current_t_interval = NULL, temp_t_interval;
    specialEventStructPtr current_se_ptr = NULL, temp_se_ptr;
    se_intervalPtr current_se_interval_ptr = NULL;
    sub_intervalPtr current_sub_interval_ptr = NULL;
    void free_specialEventStruct();
    specifierStructPtr new_specifierStruct();
    t_intervalPtr new_t_interval();
    specialEventStructPtr new_specialEventStruct();
    se_intervalPtr new_se_interval();
    sub_intervalPtr new_sub_interval();
	
    /*  FIRST FREE ALL CURRENT SPECIFIER MEMORY, IF NEEDED  */
    current_specifier_ptr = specifierHead;
    for (i = 0; i < number_of_specifiers; i++) {
        /*  FREE ALL DEPENDENT MEMORY  */
        free(current_specifier_ptr->category1);  // changed from cfree to free -- dalmazio, May 5, 2009
		free(current_specifier_ptr->category2);  // changed from cfree to free -- dalmazio, May 5, 2009
		/*  FREE ALL TRANSITION INTERVALS  */
		current_t_interval = current_specifier_ptr->t_intervalHead;
		for (j = 0; j < current_specifier_ptr->number_of_t_intervals; j++) {
			temp_t_interval = current_t_interval;
			current_t_interval = current_t_interval->next;
			free(temp_t_interval);
		}
		/*  FREE ALL SPECIAL EVENTS  */
		current_se_ptr = current_specifier_ptr->specialEventHead;
		for (j = 0; j < current_specifier_ptr->number_of_special_events; j++) {
			temp_se_ptr = current_se_ptr;
			current_se_ptr = current_se_ptr->next;
			free_specialEventStruct(temp_se_ptr,current_specifier_ptr);
		}
		/*  FREE SPECIFIER ITSELF  */
		temp_specifier_ptr = current_specifier_ptr->next;
        free(current_specifier_ptr);
		
		/*  UPDATE SPECIFIER POINTER  */
		current_specifier_ptr = temp_specifier_ptr;
    }
    number_of_specifiers = 0;
	
	
    /*  READ FROM FILE  */
    fread((char *)&number_of_specifiers,sizeof(number_of_specifiers),1,fp1);
    specifierHead = NULL;
    for (i = 0; i < number_of_specifiers; i++) {
		if (i == 0) {
			specifierHead = current_specifier_ptr = new_specifierStruct();
		}
		else {
			current_specifier_ptr->next = new_specifierStruct();
			current_specifier_ptr = current_specifier_ptr->next;	    
		}
		current_specifier_ptr->next = NULL;
		
		/*  READ SPECIFIER CATEGORY #1 FROM FILE  */
		fread((char *)&category_length,sizeof(category_length),1,fp1);
		current_specifier_ptr->category1 = (char *)calloc(category_length+1,sizeof(char));
		fread((char *)(current_specifier_ptr->category1),category_length+1,1,fp1);
		
		/*  READ SPECIFIER CATEGORY #2 FROM FILE  */
		fread((char *)&category_length,sizeof(category_length),1,fp1);
		current_specifier_ptr->category2 = (char *)calloc(category_length+1,sizeof(char));
		fread((char *)(current_specifier_ptr->category2),category_length+1,1,fp1);
		
		/*  READ TRANSITION INTERVALS FROM FILE  */
		fread((char *)&(current_specifier_ptr->number_of_t_intervals),sizeof(int),1,fp1);
		current_specifier_ptr->t_intervalHead = NULL;
		for (j = 0; j < current_specifier_ptr->number_of_t_intervals; j++) {
			if (j == 0) {
				current_specifier_ptr->t_intervalHead = current_t_interval = new_t_interval();
				current_t_interval->previous = NULL;
			}
			else {
				current_t_interval->next = new_t_interval();
				current_t_interval->next->previous = current_t_interval;
				current_t_interval = current_t_interval->next;	    
			}
			current_t_interval->next = NULL;
			
			fread((char *)&(current_t_interval->proportional),sizeof(short int),1,fp1);
			fread((char *)&(current_t_interval->regression),sizeof(short int),1,fp1);
			fread((char *)&(current_t_interval->duration.ival),sizeof(int),1,fp1);
			fread((char *)&(current_t_interval->rise),sizeof(float),1,fp1);
			fread((char *)&(current_t_interval->slope_ratio),sizeof(float),1,fp1);
		}
		
		/*  READ TRANSITION INTERVAL MODE FROM FILE  */
		fread((char *)&(current_specifier_ptr->t_interval_mode),sizeof(short int),1,fp1);
		
		/*  READ SPLIT MODE FROM FILE  */
		fread((char *)&(current_specifier_ptr->split_mode),sizeof(short int),1,fp1);
		
		/*  READ SPECIAL EVENTS FROM FILE  */
		fread((char *)&(current_specifier_ptr->number_of_special_events),sizeof(int),1,fp1);
		current_specifier_ptr->specialEventHead = NULL;
		for (j = 0; j < current_specifier_ptr->number_of_special_events; j++) {
			if (j == 0) {
				current_specifier_ptr->specialEventHead = current_se_ptr = 
				new_specialEventStruct();
			}
			else {
				current_se_ptr->next = new_specialEventStruct();
				current_se_ptr = current_se_ptr->next;	    
			}
			current_se_ptr->next = NULL;
			
			/*  READ SPECIAL EVENT SYMBOL FROM FILE  */
			fread((char *)&(current_se_ptr->symbol),SYMBOL_LENGTH_MAX+1,1,fp1);
			/*  READ SPECIAL EVENT INTERVALS FROM FILE  */
			current_se_ptr->se_intervalHead = NULL;
			for (k = 0; k < current_specifier_ptr->number_of_t_intervals; k++) {
				if (k == 0) {
					current_se_ptr->se_intervalHead = current_se_interval_ptr = new_se_interval();
					current_se_interval_ptr->previous = NULL;
				}
				else {
					current_se_interval_ptr->next = new_se_interval();
					current_se_interval_ptr->next->previous = current_se_interval_ptr;
					current_se_interval_ptr = current_se_interval_ptr->next;	    
				}
				current_se_interval_ptr->next = NULL;
				
				/*  READ SUB-INTERVALS FROM FILE  */
				fread((char *)&(current_se_interval_ptr->number_of_sub_intervals),
					  sizeof(int),1,fp1);
				current_se_interval_ptr->sub_intervalHead = NULL;
				for (l = 0; l < current_se_interval_ptr->number_of_sub_intervals; l++) {
					if (l == 0) {
						current_se_interval_ptr->sub_intervalHead = current_sub_interval_ptr = 
						new_sub_interval();
						current_sub_interval_ptr->previous = NULL;
					}
					else {
						current_sub_interval_ptr->next = new_sub_interval();
						current_sub_interval_ptr->next->previous = current_sub_interval_ptr;
						current_sub_interval_ptr = current_sub_interval_ptr->next;	    
					}
					current_sub_interval_ptr->next = NULL;
					
					/*  READ SUB-INTERVAL PARAMETERS FROM FILE  */
					fread((char *)&(current_sub_interval_ptr->proportional),
						  sizeof(short int),1,fp1);
					fread((char *)&(current_sub_interval_ptr->duration.ival),
						  sizeof(int),1,fp1);
					fread((char *)&(current_sub_interval_ptr->rise),
						  sizeof(float),1,fp1);
				}
			}
		}
		/*  READ DURATION RULE INFORMATION FROM FILE  */
		fread((char *)&(current_specifier_ptr->duration.rule),
			  sizeof(int),1,fp1);
		fread((char *)&(current_specifier_ptr->duration.fixed_length),
			  sizeof(int),1,fp1);
    }
}



#if DEBUG
void printRule(void)
{
	int i, j;
	specifierStructPtr current_specifier_ptr = NULL;
	t_intervalPtr current_t_interval = NULL;
	specialEventStructPtr current_se_ptr = NULL;
	
	printf("\nRule Information\n");
	printf("    number of specifiers = %-d\n",number_of_specifiers);
	
	/*  PRINT OUT EACH SPECIFIER  */
	current_specifier_ptr = specifierHead;
	for (i = 0; i < number_of_specifiers; i++) {
		/*  PRINT OUT CATEGORY #1 AND #2  */
		printf("\n[%s] >> [%s]\n",current_specifier_ptr->category1,current_specifier_ptr->category2);
		
		/*  PRINT TRANSITION INTERVALS  */
		printf("  number of transition intervals = %-d\n",
			   current_specifier_ptr->number_of_t_intervals);
		current_t_interval = current_specifier_ptr->t_intervalHead;
		for (j = 0; j < current_specifier_ptr->number_of_t_intervals; j++) {
			if (current_t_interval->proportional)
				printf("    P");
			else
				printf("    F");
			
			if (current_t_interval->regression)
				printf(" R");
			else
				printf("  ");
			
			if (current_t_interval->proportional)
				printf(" %8.2f",current_t_interval->duration.fval);
			else
				printf(" %8d",current_t_interval->duration.ival);
			
			printf("%8.2f %8.2f\n",current_t_interval->rise,current_t_interval->slope_ratio);
			
			current_t_interval = current_t_interval->next;
		}
		
		/*  PRINT TRANSITION INTERVAL MODE, SPLIT MODE  */
		printf("  t_interval_mode = %-d\n",current_specifier_ptr->t_interval_mode);
		printf("  split_mode = %-d\n",current_specifier_ptr->split_mode);
		
		/*  PRINT SPECIAL EVENTS  */
		printf("  number of special events = %-d\n",
			   current_specifier_ptr->number_of_special_events);
		current_se_ptr = current_specifier_ptr->specialEventHead;
		for (j = 0; j < current_specifier_ptr->number_of_special_events; j++) {
			printf("    %s\n",current_se_ptr->symbol);
			current_se_ptr = current_se_ptr->next;
		}
		
		/*  PRINT DURATION RULE INFO  */
		printf("  duration rule = %-d\n",current_specifier_ptr->duration.rule);
		printf("  duration length = %-d\n",current_specifier_ptr->duration.fixed_length);
		
		/*  UPDATE POINTER TO CURRENT SPECIFIER  */
		current_specifier_ptr = current_specifier_ptr->next;
	}
}
#endif



t_intervalPtr new_t_interval()
{
    return ( (t_intervalPtr) malloc(sizeof(t_interval)) );
}



specifierStructPtr new_specifierStruct()
{
    return ( (specifierStructPtr) malloc(sizeof(specifierStruct)) );
}



specialEventStructPtr new_specialEventStruct()
{
    return ( (specialEventStructPtr) malloc(sizeof(specialEventStruct)) );
}

void free_specialEventStruct(specialEventStructPtr specialEventStruct_ptr, 
							 specifierStructPtr specifier_ptr)
{
    int i;
    se_intervalPtr current_se_interval_ptr, temp_se_interval_ptr;
    void free_se_interval();
	
    /*  FREE ALL SE INTERVALS FIRST  */
    current_se_interval_ptr = specialEventStruct_ptr->se_intervalHead;
    for (i = 0; i < specifier_ptr->number_of_t_intervals; i++) {
		temp_se_interval_ptr = current_se_interval_ptr;
		current_se_interval_ptr = current_se_interval_ptr->next;
		free_se_interval(temp_se_interval_ptr);
    }
	
    /*  FREE THE SPECIAL EVENT STRUCT ITSELF  */
    free(specialEventStruct_ptr);
}



se_intervalPtr new_se_interval()
{
    return ( (se_intervalPtr) malloc(sizeof(se_interval)) );
}

void free_se_interval(se_intervalPtr se_interval_ptr)
{
    int i;
    sub_intervalPtr current_sub_interval_ptr, temp_sub_interval_ptr;
    void free_sub_interval();
	
    /*  FREE ALL SUB-INTERVALS FIRST  */
    current_sub_interval_ptr = se_interval_ptr->sub_intervalHead;
    for (i = 0; i < se_interval_ptr->number_of_sub_intervals; i++) {
		temp_sub_interval_ptr = current_sub_interval_ptr;
		current_sub_interval_ptr = current_sub_interval_ptr->next;
		free_sub_interval(temp_sub_interval_ptr);
    }
	
    /*  FREE THE SE_INTERVAL ITSELF  */
    free(se_interval_ptr);
}



sub_intervalPtr new_sub_interval()
{
    return ( (sub_intervalPtr) malloc(sizeof(sub_interval)) );
}

void free_sub_interval(sub_intervalPtr sub_interval_ptr)
{
    free(sub_interval_ptr);
}



f_parameterPtr new_f_parameter()
{
    return ( (f_parameterPtr) malloc(sizeof(f_parameter)) );
}


void free_f_parameter(f_parameterPtr f_parameter_ptr)
{
    int i;
    f_intervalPtr current_f_interval_ptr, temp_f_interval_ptr;
    void free_f_interval();
	
    /*  FREE ALL f_intervals FIRST  */
    current_f_interval_ptr = f_parameter_ptr->f_intervalHead;
    for (i = 0; i < f_parameter_ptr->number_of_f_intervals; i++) {
		temp_f_interval_ptr = current_f_interval_ptr;
		current_f_interval_ptr = current_f_interval_ptr->next;
		free_f_interval(temp_f_interval_ptr);
    }
	
    /*  FREE F_PARAMETER STRUCT ITSELF  */
    free(f_parameter_ptr);
}


f_intervalPtr new_f_interval()
{
    return ( (f_intervalPtr) malloc(sizeof(f_interval)) );
}

void free_f_interval(f_intervalPtr f_interval_ptr)
{
    free(f_interval_ptr);
}

start_timePtr new_start_time()
{
    return ( (start_timePtr) malloc(sizeof(start_timeStruct)) );
}

void free_start_time(start_timePtr start_time_ptr)
{
    free(start_time_ptr);
}



int nint(float value)
{
	float remainder;
	int tr_value;
	
	tr_value = (int)value;
	
	remainder = value - (float)tr_value;
	if (remainder >= 0.5)
		return(tr_value + 1);
	else if (remainder <= -0.5)
		return(tr_value - 1);
	else
		return(tr_value);
}
