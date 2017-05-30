//
//  DDOptionsBase.h
//  Duoduo
//
//  Created by zuoye on 14-2-17.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//


@interface DDOptionsBase : NSObject{
    NSString *filename;
    NSMutableDictionary *storage;
}


-(DDOptionsBase *)initWithFileName:(NSString *)fileName;
-(void)save;
-(BOOL)readBoolValueForKey:(NSString *)key;
-(BOOL)readBoolValueForKey:(NSString *)key defaultValue:(BOOL)value;
-(void)writeBoolValue:(BOOL)value forKey:(NSString *)key;
-(int16_t)readUInt16ValueForKey:(NSString *)key ;
-(int16_t)readUInt16ValueForKey:(NSString *)key defaultValue: (unsigned short) value;
-(void)writeUInt16Value:(NSUInteger)uintValue forKey:(NSString *)key;
-(int32_t)readUInt32ValueForKey:(NSString *)key;
-(int32_t)readUInt32ValueForKey:(NSString *)key defaultValue:(int32_t)value;
-(void)writeUInt32Value:(unsigned int)value forKey:(NSString *)key;
-(NSString*)readStringForKey:(NSString *)key;
-(void)writeString:(NSString *)obj forKey:(NSString *)key;
-(void)writeObject:(id)obj forKey:(NSString *)key;
-(void)writeNSData:(NSData *)da forKey:(NSString *)key;
-(NSData *)readNSDataForKey:(NSString *)key;
@end
