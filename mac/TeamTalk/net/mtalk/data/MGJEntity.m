/************************************************************
 * @file         MGJEntity.m
 * @author       快刀<kuaidao@mogujie.com>
 * summery       实体对象抽象  注：代码移植之Mogujie4Iphone
 ************************************************************/

#import "MGJEntity.h"
#import <objc/runtime.h>
#import "NSDictionary+MGJ.h"

@interface MGJEntity(ClassWithKey)

+ (Class)__classWithKey:(NSString*)key;

@end

@implementation MGJEntity

+ (id)instance {
    return [self entityWithDictionary:nil];
}

+ (id)entityWithDictionary:(NSDictionary *)dict {
    return [[[self class] alloc] initWithDictionary:dict];
}

+ (NSArray *)parserArray:(NSArray *)array WithType:(Class)type{
    if (!array || !type || [array count] == 0 || ![type isSubclassOfClass:[MGJEntity class]]) {
        return nil;
    }
    
    NSMutableArray* ret = [[NSMutableArray alloc]initWithCapacity:[array count]];
    
    for (NSUInteger index = 0; index < [array count]; ++index) {
        
        if (![[array objectAtIndex:index]isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        
        MGJEntity* entity = [[type alloc]initWithDictionary:[array objectAtIndex:index] isParserArray:YES];
        
        if (entity) {
            
            [ret addObject:entity];
        }
    }
    
    return ret;
}

+ (Class)__classWithKey:(NSString *)key {
    NSString *transedKey = [NSString stringWithFormat:@"%@%@", [[key substringToIndex:1] uppercaseString], [key substringFromIndex:1]];
                            
    return NSClassFromString([NSString stringWithFormat:@"%@Entity", transedKey]);
}

#pragma mark Initialize

- (id)init {
    return [self initWithDictionary:nil];
}

-(id)initWithDictionary:(NSDictionary *)dict isParserArray:(BOOL)isParserArray{
    if (self = [super init]) {
        [self parseValueFromDic:dict isParserArray:isParserArray];
    }
    return self;

}

- (id)initWithDictionary:(NSDictionary *)dict {
    return [self initWithDictionary:dict isParserArray:NO];
}

- (void)parseValueFromDic:(NSDictionary *)dict isParserArray:(BOOL)isParserArray
{
    NSDictionary *keyMap = [self keyMapDictionary];
    
    NSDictionary *entityMap = [self entityMapDictionary];
    
    for (__strong NSString *key in [dict keyEnumerator]) {
        
        id val = [dict objectForKey:key];
        
        //检查key名是否需要替换
        if ([keyMap objectForKey:key]) {
            key = [keyMap objectForKey:key];
        }
        
        NSString *entityKey = [key mutableCopy];
        
        if ([entityMap valueForKey:entityKey]) {
            entityKey = [entityMap valueForKey:entityKey];
        }
        
        //如果是字典，判断是否需要转化为另外的数据Model
        if ([val isKindOfClass:[NSDictionary class]]) {
            
            Class type = [MGJEntity __classWithKey:entityKey];
            
            if (type) {
                //如果也是一个类，那么就用这个类初始化它
                [self setValue:[[type alloc] initWithDictionary:val isParserArray:isParserArray] forKey:key];
            } else {
                [self setValue:val forKey:key];
            }
            
        } else if (val && ![val isKindOfClass:[NSNull class]] && ![@"<null>" isEqual:val]) {
            /// 如果继续解析第一层数组，则解析进入
            if (isParserArray) {
                BOOL parsered = NO;
                if ([val isKindOfClass:[NSArray class]]) {
                    
                    NSDictionary *entityMap = [self entityMapDictionary];
                    
                    NSString *entityKey = [key mutableCopy];
                    if ([entityMap valueForKey:entityKey]) {
                        entityKey = [entityMap valueForKey:entityKey];
                    }
                    
                    Class type = [MGJEntity __classWithKey:entityKey];
                    
                    if (type && [type isSubclassOfClass:[MGJEntity class]]) {
                        NSArray *array = [type parserArray:val WithType:[type class]];
                        
                        if (array) {
                            parsered = YES;
                            [self setValue:array forKey:key];
                        }
                    }
                }
                
                if (!parsered) {
                    [self setValue:val forKey:key];
                }
            }
            else{
                
                //无特殊情况继续赋值
                [self setValue:val forKey:key];
            }
        }
    }
}

-(void)setValue:(id)value forKey:(NSString *)key{

    NSError *error =[[NSError alloc]init];
    
    if ([self validateValue:&value forKey:key error:&error]) {
        [super setValue:value forKey:key];
    }
}

- (void)getPropertyDict:(NSMutableDictionary*)dict forClass:(Class)class
{
    unsigned int outCount, i;
    
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    
    for (i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        NSString *key = [NSString stringWithUTF8String:property_getName(property)];
        id val = [self valueForKey:(NSString *)key];
        
        if (val) {
            NSString *realKey = key;
            NSString *classKey = key;
            if ([self isKindOfClass:[MGJEntity class]]) {
                if ([[self keyMapDictionaryForDictionary]containKey:key]) {
                    realKey = [[self keyMapDictionaryForDictionary] objectForKey:key];
                }
                if ([[self entityMapDictionary] containKey:key]) {
                    classKey = [[self entityMapDictionary] objectForKey:key];
                }
            }
            
            Class type = [MGJEntity __classWithKey:classKey];
            
            if ([type isSubclassOfClass:[MGJEntity class]]) {
                //如果是数组
                if ([val isKindOfClass:[NSArray class]]) {
                    NSMutableArray *array = [NSMutableArray array];
                    for (MGJEntity *obj in val) {
                        if ([obj isKindOfClass:[NSDictionary class]]) {
                            [array addObject:obj];
                        } else {
                            [array addObject:[obj entityToDictionary]];
                        }
                      
                    }
                    [dict setValue:array forKey:realKey];
                }
                else
                {
                    //如果也是一个类，继续解析
                    [dict setValue:[val entityToDictionary] forKey:realKey];
                }
                
            } else {
                [dict setObject:val forKey:realKey];
            }
        }
    }
    
    free(properties);
    
    Class superClass = class_getSuperclass(class);
    //如果有父类 则继续反射
    if (superClass != class && superClass != [NSObject class]) {
        [self getPropertyDict:dict forClass:superClass];
    }

}

- (NSDictionary *)entityToDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [self getPropertyDict:dict forClass:[self class]];
    
    return dict;
}

#pragma mark -
#pragma mark Key-Value Coding

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
//    DBG(@"WARNING: [%s] Set value for undefiend key %s", [self.description UTF8String], [key UTF8String]);
}

- (id)valueForUndefinedKey:(NSString *)key {
//    DBG(@"WARNING: [%s] Get value for undefiend key %s", [self.description UTF8String], [key UTF8String]);
    return nil;
}

#pragma mark -

-(NSDictionary *)keyMapDictionary {
    return nil;
}
- (NSDictionary *)keyMapDictionaryForDictionary{
    return nil;
}
- (NSDictionary *)entityMapDictionary {
    return nil;
}

@end
