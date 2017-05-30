//
//  DDOptionsBase.m
//  Duoduo
//
//  Created by zuoye on 14-2-17.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDOptionsBase.h"

@implementation DDOptionsBase

- (id)init
{
    return [self initWithFileName:nil];
}

-(DDOptionsBase *)initWithFileName:(NSString *)fileName{
    
    self = [super init];
    if (self) {
        filename = [fileName copy];
        storage = [[NSMutableDictionary alloc] initWithContentsOfFile:filename];
        if (storage==nil) {
            storage = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

-(void)save{
    if (filename) {
        @synchronized(storage){
            [storage writeToFile:filename atomically:NO];
        }
    }
}


-(BOOL)readBoolValueForKey:(NSString *)key{
    return [self readBoolValueForKey:key defaultValue:NO];
}

-(BOOL)readBoolValueForKey:(NSString *)key defaultValue:(BOOL)value{
    id obj = [self readObjectForKey:key];
    if (obj) {
        return [obj boolValue];
    }
    return value;
}

-(void)writeBoolValue:(BOOL)value forKey:(NSString *)key{
    NSNumber *num =[NSNumber numberWithBool:value];
    [self writeObject:num forKey:key];
}

-(int16_t)readUInt16ValueForKey:(NSString *)key {
    return [self readUInt16ValueForKey:key defaultValue:0] & 0xffff;
}

-(int16_t)readUInt16ValueForKey:(NSString *)key defaultValue: (unsigned short) value{
    unsigned short defaultValue=value;
   id obj = [self readObjectForKey:key];
    if (obj != 0x0) {
        defaultValue = [obj unsignedShortValue];
    }
    return defaultValue & 0xffff;
}

-(void)writeUInt16Value:(NSUInteger)uintValue forKey:(NSString *)key {
    [self writeObject:[NSNumber numberWithUnsignedShort:uintValue] forKey:key];
}

-(int32_t)readUInt32ValueForKey:(NSString *)key {
    return [self readUInt32ValueForKey:key defaultValue:0];
}
-(int32_t)readUInt32ValueForKey:(NSString *)key defaultValue:(int32_t)value{
    int32_t readValue = value;
    id readObject = [self readObjectForKey:key];
    if (readObject) {
        readValue = [readObject unsignedIntValue];
    }
    return readValue;
}

-(void)writeUInt32Value:(unsigned int)value forKey:(NSString *)key {
    NSNumber *number = [NSNumber numberWithUnsignedInt:value];
    [self writeObject:number forKey:key];
}


-(NSString*)readStringForKey:(NSString *)key {
    id obj = [self readObjectForKey:key];
    return obj?obj:@"";
}
    
-(void)writeNSData:(NSData *)da forKey:(NSString *)key{
    [self  writeObject:da forKey:key];
}
    
-(NSData *)readNSDataForKey:(NSString *)key{
    id obj = [self readObjectForKey:key];
    return obj;
}

-(void)writeString:(NSString *)obj forKey:(NSString *)key{
    [self writeObject:obj forKey:key];
}
-(id)readObjectForKey:(NSString *)key{
    @synchronized(storage){
        return [storage objectForKey:key];
    }
}

-(void)writeObject:(id)obj forKey:(NSString *)key{
    @synchronized(storage){
        if(obj){
            [storage setObject:obj forKey:key];
        }else{
            [storage removeObjectForKey:key];
        }
        
        [self save];
    }
}

-(void)dealloc{
    [self save];
    
}

@end
