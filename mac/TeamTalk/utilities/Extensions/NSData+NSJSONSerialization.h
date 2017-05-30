/************************************************************
 * @file         NSData+NSJSONSerialization.h
 * @author       快刀<kuaidao@mogujie.com>
 * summery       NSData对json的扩展   注：代码移植之Mogujie4Iphone
 ************************************************************/

#import <Foundation/Foundation.h>

@interface NSData (NSJSONSerialization)
- (id)objectFromJSONData;
- (id)objectFromJSONDataWithOptions:(NSJSONReadingOptions)opt;
- (id)objectFromJSONDataWithOptions:(NSJSONReadingOptions)opt error:(NSError*)error;
@end
