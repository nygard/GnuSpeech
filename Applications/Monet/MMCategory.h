#import <Foundation/NSObject.h>

@interface MMCategory : NSObject
{
    NSString *symbol; // TODO (2004-03-18): Rename to "name".  Or create named/commented object.
    NSString *comment;
    BOOL isNative;
}

- (id)init;
- (id)initWithSymbol:(NSString *)newSymbol;
- (void)dealloc;

- (NSString *)symbol;
- (void)setSymbol:(NSString *)newSymbol;

- (NSString *)comment;
- (void)setComment:(NSString *)newComment;
- (BOOL)hasComment;

- (BOOL)isNative;
- (void)setIsNative:(BOOL)newFlag;

- (NSComparisonResult)compareByAscendingName:(MMCategory *)otherCategory;

// Archiving
- (id)initWithCoder:(NSCoder *)aDecoder;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
- (id)initWithXMLAttributes:(NSDictionary *)attributes;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
