#import <Foundation/NSObject.h>
#import <Foundation/NSXMLParser.h>

@interface MMCategory : NSObject
{
    NSString *name; // TODO (2004-03-18): Create named/commented object.
    NSString *comment;
    BOOL isNative;
}

- (id)init;
- (id)initWithName:(NSString *)aName;
- (void)dealloc;

- (NSString *)name;
- (void)setName:(NSString *)newName;

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
- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
