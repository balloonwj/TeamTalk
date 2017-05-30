/************************************************************
 * @file         DDHttpModule.h
 * @author       快刀<kuaidao@mogujie.com>
 * summery       http模块，基于AFNetworking的实现  注：参考了Mogujie4iPhone对http的包装
 ************************************************************/

#import <Foundation/Foundation.h>
#import "DDLogic.h"
#import "DDHttpEntity.h"

typedef void(^SuccessBlock)(NSDictionary *result);
typedef void(^FailureBlock)(StatusEntity* error);


@interface DDHttpModule : DDModule
{
}

-(id)initModule;
-(void)httpPostWithUri:(NSString *)uri params:(NSDictionary *)params success:(SuccessBlock)success failure:(FailureBlock)failure;
-(void)httpGetWithUri:(NSString *)uri params:(NSDictionary *)params success:(SuccessBlock)success failure:(FailureBlock)failure;

@end

extern DDHttpModule* getDDHttpModule();
