//
//  SendBuffer.h
//  mtalk
//
//  Created by maye on 13-10-23.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SendBuffer : NSMutableData{
    @private
    NSMutableData *embeddedData;
	NSInteger sendPos;
}

@property (readonly) NSInteger sendPos;

+ (id)dataWithNSData:(NSData *)newdata;

- (id)initWithData:(NSData *)newdata;
- (void)consumeData:(NSInteger)length;

- (const void *)bytes;
- (NSUInteger)length;

- (void *)mutableBytes;
- (void)setLength:(NSUInteger)length;

@end
