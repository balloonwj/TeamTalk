//
//  DDSharedWriterQueue.m
//  Duoduo
//
//  Created by maye on 13-10-30.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDSharedWriterQueue.h"

@implementation DDSharedWriterQueue
static inline dispatch_queue_t queue() {
    static dispatch_queue_t sharedWriterQueue = nil;
	static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedWriterQueue = dispatch_queue_create("com.mogujie.sharedAsyncIOQueue", 0);
    });
	
	return sharedWriterQueue;
}

+ (void) addOperation:(dispatch_block_t)op {
    dispatch_async(queue(), op);
}

+ (void) waitUntilAllOperationsAreFinished {
    dispatch_sync(queue(), ^{});
}
@end
