/************************************************************
 * @file         NSData+NSJSONSerialization.m
 * @author       快刀<kuaidao@mogujie.com>
 * summery       NSData对json的扩展     注：代码移植之Mogujie4Iphone
 ************************************************************/

#import "NSData+NSJSONSerialization.h"

@implementation NSData (NSJSONSerialization)
- (id)objectFromJSONData
{
    return [self objectFromJSONDataWithOptions:NSJSONReadingMutableContainers error:nil];
}

- (id)objectFromJSONDataWithOptions:(NSJSONReadingOptions)opt
{
        return [self objectFromJSONDataWithOptions:opt error:nil];
}

- (id)objectFromJSONDataWithOptions:(NSJSONReadingOptions)opt error:(NSError*)error
{
    id object = [NSJSONSerialization JSONObjectWithData:self options:opt error:&error];
    return object;
}
@end
