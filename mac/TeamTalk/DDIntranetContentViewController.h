//
//  DDIntranetContentViewController.h
//  Duoduo
//
//  Created by 独嘉 on 14-6-25.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
@class DDIntranetEntity;
@interface DDIntranetContentViewController : NSViewController
@property (nonatomic,retain)DDIntranetEntity* intranetEntity;
@property (nonatomic,weak)IBOutlet WebView* webView;
@property (nonatomic,weak)IBOutlet NSImageView* iconImageView;
@property (nonatomic,weak)IBOutlet NSTextField* titleLabel;
@property (nonatomic,weak)IBOutlet NSButton* backButton;
@property (nonatomic,weak)IBOutlet NSButton* forwardButton;
@property (nonatomic,retain)NSProgressIndicator* progressIndicator;
@end

