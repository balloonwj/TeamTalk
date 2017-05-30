//
//  DDContactListUserPictureMenuController.h
//  Duoduo
//
//  Created by maye on 13-11-14.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDImageCollectionView.h"

@class DDImageCollectionView,DDImageCollectionViewDelegate,DDContactListImagePicker;

@interface DDContactListUserPictureMenuController : NSObject<DDImageCollectionViewDelegate>{
    
	IBOutlet NSMenu *__weak menu;
	IBOutlet DDImageCollectionView *__weak imageCollectionView;
	
	DDContactListImagePicker *__weak imagePicker;

	NSArray *images;
    
@private
	NSMutableArray *AI_topLevelObjects;
}

@property (weak) IBOutlet NSMenu *menu;
@property (weak) IBOutlet DDImageCollectionView *imageCollectionView;
@property (weak) DDContactListImagePicker *imagePicker;
@property (copy) NSArray *images;

/*!
 * @brief Open the menu
 *
 * @param aPoint	The bottom-left corner of our parent view
 * @param picker	Our parent AIContactListImagePicker
 */
+ (void)popUpMenuForImagePicker:(DDContactListImagePicker *)picker;
@end