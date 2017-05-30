//
//  NSDictionary+DDDictionaryAdditions.h
//  Duoduo
//
//  Created by maye on 13-10-30.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (DDDictionaryAdditions)

+ (NSDictionary *)dictionaryAtPath:(NSString *)path withName:(NSString *)name create:(BOOL)create;
- (BOOL)writeToPath:(NSString *)path withName:(NSString *)name;
- (void)asyncWriteToPath:(NSString *)path withName:(NSString *)name;


- (BOOL)validateAsPropertyList;
@end



@interface NSMutableDictionary (DDDictionaryAdditions)

+ (NSMutableDictionary *)dictionaryAtPath:(NSString *)path withName:(NSString *)name create:(BOOL)create;
@end
