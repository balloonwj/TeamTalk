//
//  DDContactListNameButton.h
//  Duoduo
//
//  Created by maye on 13-11-20.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDHoveringPopUpButton.h"

@interface DDContactListNameButton : DDHoveringPopUpButton<NSTextFieldDelegate>{
    NSTextField	*textField_editor;
	void (^continuation)(NSString *);
}

- (void)editNameStartingWithString:(NSString *)startingString continuation:(void (^)(NSString *newString))continuation;

@end
