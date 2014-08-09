//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMBooleanParser.h"

#import "NSScanner-Extensions.h"

#import "MMBooleanExpression.h"
#import "MMBooleanNode.h"
#import "MMBooleanTerminal.h"
#import "MMCategory.h"
#import "MMPosture.h"
#import "MModel.h"

enum {
    MMBooleanParserToken_Operator_Or          = 0,
    MMBooleanParserToken_Operator_Not         = 1,
    MMBooleanParserToken_Operator_ExclusiveOr = 2,
    MMBooleanParserToken_Operator_And         = 3,
    MMBooleanParserToken_LeftParenthesis      = 4,
    MMBooleanParserToken_RightParenthesis     = 5,
    MMBooleanParserToken_Category             = 6,
    MMBooleanParserToken_End                  = 7,
};
typedef NSUInteger MMBooleanParserToken;

@interface MMBooleanParser ()
- (MMCategory *)categoryWithName:(NSString *)name;
- (MMBooleanParserToken)scanNextToken;

- (MMBooleanNode *)continueParse:(MMBooleanNode *)currentExpression;

// Internal recursive descent parsing methods
- (MMBooleanNode *)parseNotOperation;
- (MMBooleanNode *)parseAndOperation:(MMBooleanNode *)operand;
- (MMBooleanNode *)parseOrOperation:(MMBooleanNode *)operand;
- (MMBooleanNode *)parseExclusiveOrOperation:(MMBooleanNode *)operand;

- (MMBooleanNode *)leftParen;
- (MMBooleanNode *)terminalForParsedCategory;
@end

#pragma mark -

@implementation MMBooleanParser
{
    MModel *m_model;
}

- (id)initWithModel:(MModel *)model;
{
    if ((self = [super init])) {
        m_model = model;
    }

    return self;
}

#pragma mark -

@synthesize model = m_model;

// This strips off the optional "*" suffix before searching.  A "*" will match either a stressed or unstressed posture.  i.e. ee or ee'.
- (MMCategory *)categoryWithName:(NSString *)name;
{
    NSString *baseName = [name hasSuffix:@"*"] ? [name substringToIndex:[name length] - 1] : name;

    // Search first for a native category -- i.e. a posture name
    MMPosture *posture = [self.model postureWithName:baseName];

    if (posture != nil) {
        return [posture nativeCategory];
    }

    return [self.model categoryWithName:name];
}

- (NSUInteger)scanNextToken;
{
    [self.scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];

    if ([self.scanner scanString:@"(" intoString:NULL]) {
        self.symbolString = @"(";
        return MMBooleanParserToken_LeftParenthesis;
    }

    if ([self.scanner scanString:@")" intoString:NULL]) {
        self.symbolString = @")";
        return MMBooleanParserToken_RightParenthesis;
    }

    NSString *scannedString = nil;
    [self.scanner scanCharactersFromSet:[NSScanner gsBooleanIdentifierCharacterSet] intoString:&scannedString];
    if ([self.scanner scanString:@"*" intoString:NULL]) {
        if (scannedString == nil)
            scannedString = @"*";
        else
            scannedString = [scannedString stringByAppendingString:@"*"];
    }

    self.symbolString = scannedString;

    if ([self.symbolString isEqual:@"and"]) return MMBooleanParserToken_Operator_And;
    if ([self.symbolString isEqual:@"or"])  return MMBooleanParserToken_Operator_Or;
    if ([self.symbolString isEqual:@"not"]) return MMBooleanParserToken_Operator_Not;
    if ([self.symbolString isEqual:@"xor"]) return MMBooleanParserToken_Operator_ExclusiveOr;

    if (self.symbolString == nil || [self.symbolString length] == 0)
        return MMBooleanParserToken_End;

    if ([self categoryWithName:self.symbolString] == nil) {
        /* do nothing? */;
        NSLog(@"Category Not Found! (%@)", self.symbolString);
    }

    return MMBooleanParserToken_Category;
}

- (id)beginParseString;
{
    MMBooleanNode *resultExpression = nil;

    switch ([self scanNextToken]) {
        default:
        case MMBooleanParserToken_End:
            [self appendErrorFormat:@"Error, unexpected End."];
            return nil;
            
        case MMBooleanParserToken_Operator_Or:
        case MMBooleanParserToken_Operator_And:
        case MMBooleanParserToken_Operator_ExclusiveOr:
            [self appendErrorFormat:@"Error, unexpected %@ operation.", self.symbolString];
            return nil;
            
        case MMBooleanParserToken_Operator_Not:
            resultExpression = [self parseNotOperation];
            break;
            
        case MMBooleanParserToken_LeftParenthesis:
            resultExpression = [self leftParen];
            break;
            
        case MMBooleanParserToken_RightParenthesis:
            [self appendErrorFormat:@"Error, unexpected ')'."];
            break;
            
        case MMBooleanParserToken_Category:
            resultExpression = [self terminalForParsedCategory];
            break;
    }

    if (resultExpression == nil)
        return nil;
    
    resultExpression = [self continueParse:resultExpression];
    
    return resultExpression;
}

- (MMBooleanNode *)continueParse:(MMBooleanNode *)currentExpression;
{
    MMBooleanParserToken token;

    while ( (token = [self scanNextToken]) != MMBooleanParserToken_End) {
        switch (token) {
            default:
            case MMBooleanParserToken_End:
                [self appendErrorFormat:@"Error, unexpected End."];
                return nil;
                
            case MMBooleanParserToken_Operator_Or:
                currentExpression = [self parseOrOperation:currentExpression];
                break;
                
            case MMBooleanParserToken_Operator_And:
                currentExpression = [self parseAndOperation:currentExpression];
                break;
                
            case MMBooleanParserToken_Operator_ExclusiveOr:
                currentExpression = [self parseExclusiveOrOperation:currentExpression];
                break;
                
            case MMBooleanParserToken_Operator_Not:
                [self appendErrorFormat:@"Error, unexpected NOT operation."];
                return nil;
                
            case MMBooleanParserToken_LeftParenthesis:
                [self appendErrorFormat:@"Error, unexpected '('."];
                return nil;
                
            case MMBooleanParserToken_RightParenthesis:
                [self appendErrorFormat:@"Error, unexpected ')'."];
                return nil;
                
            case MMBooleanParserToken_Category:
                [self appendErrorFormat:@"Error, unexpected category %@.", self.symbolString];
                return nil;
        }
        
        if (currentExpression == nil)
            return nil;
    }

    return currentExpression;
}

- (MMBooleanNode *)parseNotOperation;
{
    MMBooleanExpression *resultExpression = nil;
    MMBooleanNode *subExpression = nil;

    resultExpression = [[MMBooleanExpression alloc] init];
    resultExpression.operation = MMBooleanOperation_Not;

    switch ([self scanNextToken]) {
        case MMBooleanParserToken_Operator_And:
        case MMBooleanParserToken_Operator_ExclusiveOr:
        case MMBooleanParserToken_Operator_Or:
        case MMBooleanParserToken_Operator_Not:
            [self appendErrorFormat:@"Error, unexpected %@ operation.", self.symbolString];
            return nil;
            
        case MMBooleanParserToken_Category:
        {
            MMBooleanNode *terminal = [self terminalForParsedCategory];
            if (terminal == nil) {
                [self appendErrorFormat:@"Error, terminal returned nil, %s", __PRETTY_FUNCTION__];
                return nil;
            } else {
                [resultExpression addSubExpression:terminal];
            }
            break;
        }
            
        case MMBooleanParserToken_LeftParenthesis:
            subExpression = [self leftParen];
            if (subExpression != nil)
                [resultExpression addSubExpression:subExpression];
    }
    
    return resultExpression;
}

- (MMBooleanNode *)parseAndOperation:(MMBooleanNode *)operand;
{
    MMBooleanExpression *resultExpression = nil;
    MMBooleanNode *subExpression = nil;

    resultExpression = [[MMBooleanExpression alloc] init];
    [resultExpression addSubExpression:operand];
    resultExpression.operation = MMBooleanOperation_And;

    switch ([self scanNextToken])
    {
        case MMBooleanParserToken_End:
            [self appendErrorFormat:@"Error, unexpected End."];
            return nil;
            
        case MMBooleanParserToken_Operator_And:
        case MMBooleanParserToken_Operator_Or:
        case MMBooleanParserToken_Operator_ExclusiveOr:
            [self appendErrorFormat:@"Error, unexpected %@ operation.", self.symbolString];
            return nil;
            
        case MMBooleanParserToken_RightParenthesis:
            [self appendErrorFormat:@"Error, unexpected ')'."];
            return nil;
            
        case MMBooleanParserToken_Operator_Not:
            subExpression = [self parseNotOperation];
            if (subExpression != nil)
                [resultExpression addSubExpression:subExpression];
            break;
            
        case MMBooleanParserToken_LeftParenthesis:
            subExpression = [self leftParen];
            if (subExpression != nil)
                [resultExpression addSubExpression:subExpression];
            break;
            
        case MMBooleanParserToken_Category:
        {
            MMBooleanNode *terminal = [self terminalForParsedCategory];
            if (terminal == nil) {
                [self appendErrorFormat:@"Error, terminal returned nil, %s", __PRETTY_FUNCTION__];
                return nil;
            } else {
                [resultExpression addSubExpression:terminal];
            }
            break;
        }
    }
    
    return resultExpression;
}

- (MMBooleanNode *)parseOrOperation:(MMBooleanNode *)operand;
{
    MMBooleanExpression *resultExpression = nil;
    MMBooleanNode *subExpression = nil;
    
    resultExpression = [[MMBooleanExpression alloc] init];
    [resultExpression addSubExpression:operand];
    resultExpression.operation = MMBooleanOperation_Or;
    
    switch ([self scanNextToken]) {
        case MMBooleanParserToken_End:
            [self appendErrorFormat:@"Error, unexpected End."];
            return nil;
            
        case MMBooleanParserToken_Operator_And:
        case MMBooleanParserToken_Operator_Or:
        case MMBooleanParserToken_Operator_ExclusiveOr:
            [self appendErrorFormat:@"Error, unexpected %@ operation.", self.symbolString];
            return nil;
            
        case MMBooleanParserToken_RightParenthesis:
            [self appendErrorFormat:@"Error, unexpected ')'."];
            return nil;
            
        case MMBooleanParserToken_Operator_Not:
            subExpression = [self parseNotOperation];
            if (subExpression != nil)
                [resultExpression addSubExpression:subExpression];
            break;
            
        case MMBooleanParserToken_LeftParenthesis:
            subExpression = [self leftParen];
            if (subExpression != nil)
                [resultExpression addSubExpression:subExpression];
            break;
            
        case MMBooleanParserToken_Category:
        {
            MMBooleanNode *terminal = [self terminalForParsedCategory];
            if (terminal == nil) {
                [self appendErrorFormat:@"Error, terminal returned nil, %s", __PRETTY_FUNCTION__];
                return nil;
            } else {
                [resultExpression addSubExpression:terminal];
            }
            break;
        }
    }
    
    return resultExpression;
}

- (MMBooleanNode *)parseExclusiveOrOperation:(MMBooleanNode *)operand;
{
    MMBooleanExpression *resultExpression = nil;
    MMBooleanNode *subExpression = nil;

    resultExpression = [[MMBooleanExpression alloc] init];
    [resultExpression addSubExpression:operand];
    resultExpression.operation = MMBooleanOperation_ExclusiveOr;

    switch ([self scanNextToken]) {
        case MMBooleanParserToken_End:
            [self appendErrorFormat:@"Error, unexpected End."];
            return nil;
            
        case MMBooleanParserToken_Operator_And:
        case MMBooleanParserToken_Operator_Or:
        case MMBooleanParserToken_Operator_ExclusiveOr:
            [self appendErrorFormat:@"Error, unexpected %@ operation.", self.symbolString];
            return nil;
            
        case MMBooleanParserToken_RightParenthesis:
            [self appendErrorFormat:@"Error, unexpected ')'."];
            return nil;
            
        case MMBooleanParserToken_Operator_Not:
            subExpression = [self parseNotOperation];
            if (subExpression != nil)
                [resultExpression addSubExpression:subExpression];
            break;
            
        case MMBooleanParserToken_LeftParenthesis:
            subExpression = [self leftParen];
            if (subExpression != nil)
                [resultExpression addSubExpression:subExpression];
            break;
            
        case MMBooleanParserToken_Category:
        {
            MMBooleanNode *terminal = [self terminalForParsedCategory];
            if (terminal == nil) {
                [self appendErrorFormat:@"Error, terminal returned nil, %s", __PRETTY_FUNCTION__];
                return nil;
            } else {
                [resultExpression addSubExpression:terminal];
            }
            break;
        }
    }

    return resultExpression;
}

- (MMBooleanNode *)leftParen;
{
    MMBooleanNode *resultExpression = nil;
    
    switch ([self scanNextToken]) {
        case MMBooleanParserToken_End:
            [self appendErrorFormat:@"Error, unexpected End."];
            return nil;
            
        case MMBooleanParserToken_RightParenthesis:
            [self appendErrorFormat:@"Error, unexpected right paren."];
            return nil;
            
        case MMBooleanParserToken_LeftParenthesis:
            resultExpression = [self leftParen];
            break;
            
        case MMBooleanParserToken_Operator_And:
        case MMBooleanParserToken_Operator_Or:
        case MMBooleanParserToken_Operator_ExclusiveOr:
            [self appendErrorFormat:@"Error, unexpected %@ operation.", self.symbolString];
            return nil;
            
        case MMBooleanParserToken_Operator_Not:
            resultExpression = [self parseNotOperation];
            break;
            
        case MMBooleanParserToken_Category:
        {
            MMBooleanNode *terminal = [self terminalForParsedCategory];
            if (terminal == nil) {
                [self appendErrorFormat:@"Error, terminal returned nil, %s", __PRETTY_FUNCTION__];
                return nil;
            } else {
                resultExpression = terminal;
            }
            break;
        }
    }
    
    MMBooleanParserToken token;
    while ( (token = [self scanNextToken]) != MMBooleanParserToken_RightParenthesis) {
        switch (token) {
            case MMBooleanParserToken_End:
                [self appendErrorFormat:@"Error, unexpected End."];
                return nil;
                
            case MMBooleanParserToken_RightParenthesis:
                [self appendErrorFormat:@"Won't happen?"];
                return nil; // Won't happen
                
            case MMBooleanParserToken_LeftParenthesis:
                [self appendErrorFormat:@"Error, unexpected '('."];
                return nil;
                
            case MMBooleanParserToken_Operator_And:
                resultExpression = [self parseAndOperation:resultExpression];
                break;
                
            case MMBooleanParserToken_Operator_Or:
                resultExpression = [self parseOrOperation:resultExpression];
                break;

            case MMBooleanParserToken_Operator_ExclusiveOr:
                resultExpression = [self parseExclusiveOrOperation:resultExpression];
                break;
                
            case MMBooleanParserToken_Operator_Not:
                [self appendErrorFormat:@"Error, unexpected NOT operation."];
                return nil;
                
            case MMBooleanParserToken_Category:
                [self appendErrorFormat:@"Error, unexpected category %@.", self.symbolString];
                return nil;
        }
    }
    
    return resultExpression;
}

// An MMBooleanParserToken_Category has already been parsed, and the name is sitting in self.symbolString
- (MMBooleanNode *)terminalForParsedCategory;
{
    MMCategory *category = [self categoryWithName:self.symbolString];
    if (category == nil) {
        [self appendErrorFormat:@"Error, unknown category %@.", self.symbolString];
        return nil;
    } else {
        MMBooleanTerminal *terminal = [[MMBooleanTerminal alloc] init];
        terminal.category = category;
        if ([self.symbolString hasSuffix:@"*"])
            terminal.shouldMatchAll = YES;
        return terminal;
    }
}

@end
