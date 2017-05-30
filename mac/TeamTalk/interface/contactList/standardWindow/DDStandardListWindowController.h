//
//  DDStandardListWindowController.h
//  Duoduo
//
//  Created by maye on 13-11-20.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDListWindowController.h"

@class DDHoveringPopUpButton,DDContactListNameButton,DDContactListImagePicker;

#warning 没必要整这么多花样 **
typedef enum {
	ContactListImagePickerOnLeft = 0,
	ContactListImagePickerOnRight,
	ContactListImagePickerHiddenOnLeft,
	ContactListImagePickerHiddenOnRight,
} ContactListImagePickerPosition;

@interface DDStandardListWindowController : DDListWindowController<NSToolbarDelegate>{
 	IBOutlet	NSView						*view_statusAndImage;
	
	IBOutlet	NSView						*view_nameAndStatusMenu;
	IBOutlet	DDHoveringPopUpButton		*statusMenuView;
	IBOutlet	DDContactListNameButton		*nameView;
	IBOutlet	NSImageView					*imageView_status;
	
	IBOutlet	DDContactListImagePicker	*imagePicker;
    
	ContactListImagePickerPosition			imagePickerPosition;
	
	//AIStatusMenu				*statusMenu;
    


}


- (void)updateImagePicker;

@end
