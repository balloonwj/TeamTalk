//
//  DDInterfaceController.h
//  Duoduo
//
//  Created by maye on 13-11-19.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDPreferenceWinController.h"
@interface DDInterfaceController : NSObject<NSUserInterfaceValidations>
{

    IBOutlet NSMenuItem *_fileManagerWindowMenuItem;
    
    
}

@property (nonatomic,weak)IBOutlet NSMenu* mainMenu;
@property (weak) IBOutlet NSMenuItem *exitDuoDuo;

- (IBAction)paste:(id)sender;
-(id)sender;
- (IBAction)pasteAndMatchStyle:(id)sender;

- (IBAction)showPreferenceWindow:(id)sender;
- (IBAction)newDD:(id)sender;


- (IBAction)showFileManagerWindow:(id)sender;



@end
