//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

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
static long c_pos, last_char_pos, token, token_available, end_of_input;

static void e_scan_init(char *input);
static long evaluate_input(void);
static long evaluate_line(void);
static long evaluate_expression(void);
static long operator(long code);
static long value(long code);
static long evaluate_expression_tail(void);
static long evaluate_negation(void);
static long evaluate_category_name(void);
static long e_next_token(void);
static void e_skip_white(void);
static void e_advance(void);
static long e_get_a_token(void);
static long e_get_operator_or_category(void);
static void e_match_tokens(long expected_token);


long evaluate(char *rule, char *phone)
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



long evaluate_input(void)
{
	long value_line;
	
	/*  GET THE NEXT TOKEN  */
	token = e_next_token();
	
	/*  <INPUT> ::= <LINE> <EMPTY_TOKEN>  */
	value_line = evaluate_line();
	e_match_tokens(EMPTY_TOKEN);
	
	/*  RETURN VALUE OF THE LINE  */
	return(value_line);
}



long evaluate_line(void)
{
	long negative, value_expression;
	
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



long evaluate_expression(void)
{
	long value_line, value_category_name, expression_tail;
	
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



long operator(long code)
{
	if (code < 0)
		return(code * (-1));
	else
		return(code);
}



long value(long code)
{
	if (code < 0)
		return(1);
	else
		return(0);
}



long evaluate_expression_tail(void)
{
	long value_line, operator;
	
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



long evaluate_negation(void)
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



long evaluate_category_name(void)
{
	/*  GET A TOKEN  */
	token = e_next_token();
	token_available = 0;
	
	/*  <CATEGORY_NAME> ::= any valid category for current_phone  */
	return(matchPhone(current_phone,op_cat_string));
}



long e_next_token(void)
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



long e_get_a_token(void)
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



long e_get_operator_or_category(void)
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



void e_match_tokens(long expected_token)
{
	token = e_next_token();
	token_available = 0;
}
