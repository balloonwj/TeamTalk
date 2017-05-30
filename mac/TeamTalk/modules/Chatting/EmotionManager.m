//
//  EmotionManager.m
//  Duoduo
//
//  Created by 独嘉 on 14-3-18.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "EmotionManager.h"
#import "EmotionListXmlParser.h"
@implementation EmotionManager
{
    EmotionListXmlParser *xmlParser;
}
+ (EmotionManager*)instance
{
    static EmotionManager* g_emotionManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_emotionManager = [[EmotionManager alloc] init];
    });
    return g_emotionManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        NSString *xmlPath = [[NSBundle mainBundle] pathForResource:@"emotionList.xml"
                                                            ofType:nil];
        xmlParser = [[EmotionListXmlParser alloc] initWithPath:xmlPath];
    }
    return self;
}

- (NSString *)getFileFrom:(NSString *)text
{
    return [xmlParser getFileFrom:text];
}

- (NSString *)getTextFrom:(NSString *)file
{
    return [xmlParser getTextFrom:file];
}

@end
