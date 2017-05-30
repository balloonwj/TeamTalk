//
//  EmotionListXmlParser.h
//  Duoduo
//
//  Created by jianqing.du on 14-1-22.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmotionListXmlParser : NSObject <NSXMLParserDelegate>

- (id)initWithPath:(NSString *)path;

- (NSString *)getFileFrom:(NSString *)text;
- (NSString *)getTextFrom:(NSString *)file;

@end
