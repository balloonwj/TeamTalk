//
//  DDSharedWriterQueue.h
//  Duoduo
//
//  Created by maye on 13-10-30.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDSharedWriterQueue : NSObject
+ (void) addOperation:(dispatch_block_t)op;
+ (void) waitUntilAllOperationsAreFinished;
@end
