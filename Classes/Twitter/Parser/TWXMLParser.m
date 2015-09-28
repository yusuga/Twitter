//
//  TWXMLParser.m
//  Develop
//
//  Created by Yu Sugawara on 9/28/15.
//  Copyright © 2015 Yu Sugawara. All rights reserved.
//

#import "TWXMLParser.h"

typedef void (^TWXMLParserCompletion)(NSError *parsedError);

@interface TWXMLParser () <NSXMLParserDelegate>

@property (nonatomic) NSMutableDictionary *resultDictionary;
@property (nonatomic) NSString *currentElementName;

@end

@implementation TWXMLParser

+ (void)parseErrorXML:(NSString *)xml
                 code:(NSNumber **)codePtr
              message:(NSString **)messagePtr
{
    TWXMLParser *parser = [[self alloc] init];
    [parser parseXML:xml];
    
    NSDictionary *dictionary = parser.resultDictionary;
    NSNumber *code = @([dictionary[@"code"] integerValue]);
    NSString *message = dictionary[@"error"];
    
    if (code && [code integerValue] && codePtr) {
        *codePtr = code;
    }
    if (message && messagePtr) {
        *messagePtr = message;
    }
}

- (instancetype)init
{
    if (self = [super init]) {
        self.resultDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)parseXML:(NSString *)xml
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[xml dataUsingEncoding:NSUTF8StringEncoding]];
    parser.delegate = self;
    [parser parse];
    if ([parser parserError]) {
        NSLog(@"%s, parse error {\n\txml = %@\n\terror = %@\n}", __func__, xml, [parser parserError]);
    }
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary<NSString *,NSString *> *)attributeDict
{
    self.currentElementName = elementName;
    [self.resultDictionary addEntriesFromDictionary:attributeDict];
}

- (void)parser:(NSXMLParser *)parser
foundCharacters:(NSString *)string
{
    if (!self.currentElementName.length) return;
    self.resultDictionary[self.currentElementName] = string;
}

@end
