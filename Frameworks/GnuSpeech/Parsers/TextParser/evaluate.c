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
 *  evaluate.c
 *  GnuSpeech
 *
 *  Version: 0.8
 *
 ******************************************************************************/

#import <stdio.h>
#import <string.h>
#import <stdlib.h>
#import "evaluate.h"
#import "phoneDescription.h"

#define  NO_OP          0
#define  EMPTY_TOKEN    0
#define  NOT_SYM        1
#define  AND_SYM        2
#define  OR_SYM         3
#define  XOR_SYM        4
#define  CATEGORY_SYM   5
#define  OPENPAREN_SYM  6
#define  CLOSEPAREN_SYM 7
#define  PAREN_MISMATCH 8
#define  NULL_INPUT     9
#define  UNKNOWN_CAT    10


/*  GLOBALS -- LOCAL TO THIS FILE  */
static char c_char, *input_string, *current_phone, op_cat_string[256];
static int c_pos, last_char_pos, token, token_available, end_of_input;

static void e_scan_init(char *input);
static int evaluate_input(void);
static int evaluate_line(void);
static int evaluate_expression(void);
static int operator(int code);
static int value(int code);
static int evaluate_expression_tail(void);
static int evaluate_negation(void);
static int evaluate_category_name(void);
static int e_next_token(void);
static void e_skip_white(void);
static void e_advance(void);
static int e_get_a_token(void);
static int e_get_operator_or_category(void);
static void e_match_tokens(int expected_token);


int evaluate(char *rule, char *phone)
{
	/*  SET GLOBALS  */
	current_phone = phone;
	
	/*  INITIALIZE THE SCAN OF THE RULE  */
	e_scan_init(rule);
	
	/*  EVALUATE THE INPUT  */
	return(evaluate_input());
}



void e_scan_init(char *input)
{
	c_pos = 0;
	token_available = end_of_input = EVAL_NO;
	token = EMPTY_TOKEN;
	input_string = input;
	
	last_char_pos = strlen(input_string);
	e_advance();
}



int evaluate_input(void)
{
	int value_line;
	
	/*  GET THE NEXT TOKEN  */
	token = e_next_token();
	
	/*  <INPUT> ::= <LINE> <EMPTY_TOKEN>  */
	value_line = evaluate_line();
	e_match_tokens(EMPTY_TOKEN);
	
	/*  RETURN VALUE OF THE LINE  */
	return(value_line);
}



int evaluate_line(void)
{
	int negative, value_expression;
	
	/*  GET THE NEXT TOKEN  */
	token = e_next_token();
	
	/*  <LINE> ::= <NEGATIVE> <EXPRESSION>  */
	negative = evaluate_negation();
	value_expression = evaluate_expression();
	
	/*  NEGATE THE EXPRESSION IF NECESSARY  */
	if (negative)
		return(!value_expression);
	else
		return(value_expression);
}



int evaluate_expression(void)
{
	int value_line, value_category_name, expression_tail;
	
	/*  GET THE NEXT TOKEN  */
	token = e_next_token();
	
	/*  <EXPRESSION> ::=  ( <LINE> ) <EXPRESSION_TAIL> | 
	 <CATEGORY_NAME> <EXPRESSION_TAIL>  */
	if (token == OPENPAREN_SYM) {
		e_match_tokens(OPENPAREN_SYM);
		value_line = evaluate_line();
		e_match_tokens(CLOSEPAREN_SYM);
		expression_tail = evaluate_expression_tail();
		
		/*  EVALUATE ACCORDING TO OPERATOR  */
		if (operator(expression_tail) == NO_OP)
			return(value_line);
		else if (operator(expression_tail) == AND_SYM)
			return(value_line && value(expression_tail));
		else if (operator(expression_tail) == OR_SYM)
			return(value_line || value(expression_tail));
		else if (operator(expression_tail) == XOR_SYM) {
			if ( (value_line && !value(expression_tail)) ||
				(!value_line && value(expression_tail)) )
				return(1);
			else
				return(0);
		}
	}
	else {
		value_category_name = evaluate_category_name();
		expression_tail = evaluate_expression_tail();
		
		/*  EVALUATE ACCORDING TO OPERATOR  */
		if (operator(expression_tail) == NO_OP)
			return(value_category_name);
		else if (operator(expression_tail) == AND_SYM)
			return(value_category_name && value(expression_tail));
		else if (operator(expression_tail) == OR_SYM)
			return(value_category_name || value(expression_tail));
		else if (operator(expression_tail) == XOR_SYM) {
			if ( (value_category_name && !value(expression_tail)) ||
				(!value_category_name && value(expression_tail)) )
				return(1);
			else
				return(0);
		}
	}
	return(0);
}



int operator(int code)
{
	if (code < 0)
		return(code * (-1));
	else
		return(code);
}



int value(int code)
{
	if (code < 0)
		return(1);
	else
		return(0);
}



int evaluate_expression_tail(void)
{
	int value_line, operator;
	
	/*  GET NEXT TOKEN  */
	token = e_next_token();
	
	/*  <EXPRESSION_TAIL> ::= <"and" | "or" | "xor"> <LINE>  |  " "  */
	if ( (token == AND_SYM) || (token == OR_SYM) || (token == XOR_SYM) ) {
		operator = token;
		e_match_tokens(token);
		value_line = evaluate_line();
		
		/*  RETURN OPERATOR AND VALUE AS ONE CODED INT  */
		if (value_line)
			return(operator * (-1));
		return(operator);
	}
	else
		return(NO_OP);
}



int evaluate_negation(void)
{
	/*  GET NEXT TOKEN  */
	token = e_next_token();
	
	/*  <NEGATION> ::= <"not">  |  " "   */
	if (token == NOT_SYM) {
		e_match_tokens(token);
		return(1);
	}
	else
		return(0);
}



int evaluate_category_name(void)
{
	/*  GET A TOKEN  */
	token = e_next_token();
	token_available = 0;
	
	/*  <CATEGORY_NAME> ::= any valid category for current_phone  */
	return(matchPhone(current_phone,op_cat_string));
}



int e_next_token(void)
{
	if (!token_available) {
		token = EMPTY_TOKEN;
		e_skip_white();
		if (!end_of_input) {
			token = e_get_a_token();
			token_available = EVAL_YES;
		}
	}
	return(token);
}



void e_skip_white(void)
{
	while ((!end_of_input) && 
		   ((c_char == ' ') || (c_char == '\t') || (c_char == '\n'))) {
		e_advance();
	}
}



void e_advance(void)
{
	c_char = input_string[c_pos++];
	
	if (c_pos > last_char_pos)
		end_of_input = EVAL_YES;
}



int e_get_a_token(void)
{
	e_skip_white();
	
	if (c_char == '(') {
		token = OPENPAREN_SYM;
		e_advance();
	}
	else if (c_char == ')') {
		token = CLOSEPAREN_SYM;
		e_advance();
	}
	else
		token = e_get_operator_or_category();
	
	return(token);
}



int e_get_operator_or_category(void)
{
	int string_index = 0;
	
	while((!end_of_input) && (c_char != '(') && (c_char != ')') && (c_char != ' ')) {
		op_cat_string[string_index++] = c_char;
		e_advance();
	}
	op_cat_string[string_index] = '\0';
	
	if (string_index == 0)
		return(EMPTY_TOKEN);
	else if (!strcmp(op_cat_string,"not"))
		return(NOT_SYM);
	else if (!strcmp(op_cat_string,"and"))
		return(AND_SYM);
	else if (!strcmp(op_cat_string,"or"))
		return(OR_SYM);
	else if (!strcmp(op_cat_string,"xor"))
		return(XOR_SYM);
	else
		return(CATEGORY_SYM);
}



void e_match_tokens(int expected_token)
{
	token = e_next_token();
	token_available = 0;
}
