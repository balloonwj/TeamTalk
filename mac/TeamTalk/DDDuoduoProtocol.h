//
//  DDDuoduoProtocol.h
//  Duoduo
//
//  Created by maye on 13-10-30.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDMainWindowController.h"
#import "DDInterfaceController.h"

@protocol DDLoginControllerProtocol,DDAccountControllerProtocol,DDContactControllerProtocol;

@protocol DDDuoduoProtocol <NSObject>

@property(readonly, nonatomic) NSString *applicationSupportDirectory;
@property(readonly,nonatomic)DDInterfaceController *interfaceController;
@property(nonatomic,strong)DDMainWindowController* mainWindowController;


-(void)sendMsgToServer:(NSMutableData *)data;

@end
