//
//  DDImageMessage.m
//  Duoduo
//
//  Created by zuoye on 14-1-13.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDImageMessage.h"

@implementation DDImageMessage
@synthesize textMsg;
@synthesize imagesUrl;
@synthesize imageCount;
-(id)init{
    self = [super init];
    if (self) {
        imagesUrl = [[NSMutableDictionary alloc] init];
        textMsg = [[NSMutableString alloc] init];
        imageCount = 0;
    }
    return self;
}

-(NSString *)getSendMessage{
    NSUInteger realIndex =0;
    NSUInteger totalInsertCount=0;
    for (NSString *indexs in [[imagesUrl allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return NSOrderedDescending;
        }
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }]) {
        DDLog(@" \n*****before getSendMessage: %@ ******\n\n",textMsg);
        NSString *url =[imagesUrl objectForKey:indexs];
        realIndex=[indexs integerValue]+totalInsertCount;
        @try {
            [textMsg replaceCharactersInRange:NSMakeRange(realIndex, 1) withString:url];
        }
        @catch (NSException *exception) {
            return @"";
        }
        
        
       //[textMsg insertString:url atIndex:realIndex];
        totalInsertCount+=[url length]-1;

        DDLog(@" \n getSendMessage index:%@\n%@\n",indexs,textMsg);
    }
    DDLog(@" \n*****after getSendMessage: %@ ******\n\n",textMsg);
    return [NSString stringWithString:textMsg];
}

@end
