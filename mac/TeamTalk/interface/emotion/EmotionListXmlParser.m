//
//  EmotionListXmlParser.m
//  Duoduo
//
//  Created by jianqing.du on 14-1-22.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "EmotionListXmlParser.h"

@implementation EmotionListXmlParser {
    NSXMLParser *parser;
    NSMutableDictionary *dictFile2Text;    // "0.gif":"[呵呵]"
    NSMutableDictionary *dictText2File;    // "[呵呵]":"0.gif"
}

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        dictFile2Text = [[NSMutableDictionary alloc] init];
        dictText2File = [[NSMutableDictionary alloc] init];

        NSData *xmlData = [[NSData alloc] initWithContentsOfFile:path];
        parser = [[NSXMLParser alloc] initWithData:xmlData];
        [parser setDelegate:self];
        [parser setShouldResolveExternalEntities:YES];
        BOOL success = [parser parse];
        if (!success) {
            NSError *error = [parser parserError];
            DDLog(@"error:%@", error);
        }
    }
    
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"Emoticon"]) {
        [dictFile2Text setObject:[attributeDict objectForKey:@"Text"]
                          forKey:[attributeDict objectForKey:@"File"]];
        [dictText2File setObject:[attributeDict objectForKey:@"File"]
                          forKey:[attributeDict objectForKey:@"Text"]];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"Emoticons"]) {
        DDLog(@"end xml parse");
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    
}

- (NSString *)getFileFrom:(NSString *)text
{
    return [dictText2File objectForKey:text];
}

- (NSString *)getTextFrom:(NSString *)file
{
    return [dictFile2Text objectForKey:file];
}

@end
