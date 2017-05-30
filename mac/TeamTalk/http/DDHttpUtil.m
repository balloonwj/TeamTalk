//
//  DDHttpUtil.m
//  Duoduo
//
//  Created by maye on 13-11-10.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDHttpUtil.h"
#import "MD5.h"
#import "SBJson.h"

@implementation DDHttpUtil

+(NSMutableDictionary *)sendRequestWithParam:(NSString *)postText action:(NSString *)actionName{
    NSString *urlstr = [@"http://www.mogujie.com/user/zlogin/" stringByAppendingString:actionName];
    NSString *postStr = [[postText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]stringWithPercentEscape];
    NSData *postData = [postStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:urlstr]];
	[request setHTTPMethod:@"POST"];
	[request setTimeoutInterval:15];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	
	NSError *error = nil;
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
	
	
	if(error)
	{
		if([error code] == -1009) DDLog(@"ERROR_NO_INTERNET 1009");
		else if([error code] == -1001) DDLog(@"ERROR_INTERNET_TIMEOUT 1001");
		else DDLog(@"ERROR_INTERNET_WRONG");
		return nil;
	}
	
	if(!returnData || [returnData length] == 0)
	{
        DDLog(@"ERROR_INTERNET_CONNECT_FAIL");
		return nil;
	}
    NSString *rs = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSMutableDictionary *dict = [jsonParser objectWithString:rs];
    return dict;
}
@end
