/************************************************************
 * @file         MGJEntity.h
 * @author       快刀<kuaidao@mogujie.com>
 * summery       实体对象抽象  注：代码移植之Mogujie4Iphone
 ************************************************************/

#import <Foundation/Foundation.h>

@interface MGJEntity : NSObject

/*!
 创建一个 MGJEntity 实例
 */
+ (id)instance;

/*!
 使用一个 JSON 来创建 MGJEntity 实例
 @param dict 以 NSDictionary 表示的 JSON 对象
 */
+ (id)entityWithDictionary:(NSDictionary *)dict;

+ (NSArray*)parserArray:(NSArray*)array WithType:(Class)type;

/*!
 从一个 JSON Dictionary 设置 MGJEntity 的属性
 @param dict 以 NSDictionary 表示的 JSON 对象
 */
- (id)initWithDictionary:(NSDictionary *)dict;

/*!
 从一个 JSON Dictionary 设置 MGJEntity 的属性
 @param dict 以 NSDictionary 表示的 JSON 对象 isParserArray 表示如果遇到数组则继续解析
 */
- (id)initWithDictionary:(NSDictionary *)dict isParserArray:(BOOL)isParserArray;

- (void)parseValueFromDic:(NSDictionary *)dict isParserArray:(BOOL)isParserArray;

/*!
 将 MGJEntity 转为 NSDictionary
 */
- (NSDictionary *)entityToDictionary;

/*!
 需要过滤掉的关键字典，比如（id、new）
 */
- (NSDictionary *)keyMapDictionary;

/*!
 需要转换的字典对应的Entity名称
 默认对应Entity名称为大写key第一个字母并加上Entity（如：block -> BlockEntity）
 */
- (NSDictionary *)entityMapDictionary;

/*
 * 实体转字典时用，key为实体变量名
 */
- (NSDictionary *)keyMapDictionaryForDictionary;


@end
