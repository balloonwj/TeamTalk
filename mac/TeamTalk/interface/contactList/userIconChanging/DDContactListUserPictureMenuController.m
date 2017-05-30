//
//  DDContactListUserPictureMenuController.m
//  Duoduo
//
//  Created by maye on 13-11-14.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDContactListUserPictureMenuController.h"
#import "NSString+DDStringAdditions.h"
#import "DDContactListImagePicker.h"
#import "DDControllerProtocol.h"
#import "IKRecentPicture.h"

#import "AIStringUtilities.h"


#pragma mark DDContactListUserPictureMenuController
@interface DDContactListUserPictureMenuController()
- (id)initWithNibName:(NSString *)nibName imagePicker:(DDContactListImagePicker *)picker;

// IKRecentPicture related
- (NSArray *)recentPictures;
- (NSMutableArray *)recentSmallPictures;

// Menu actions
- (void)selectedAccount:(id)sender;
- (void)choosePicture:(id)sender;
- (void)clearRecentPictures:(id)sender;
@end

@implementation DDContactListUserPictureMenuController
@synthesize menu,imageCollectionView;
@synthesize imagePicker,images;

+(void)popUpMenuForImagePicker:(DDContactListImagePicker *)picker{
    (void)[[self alloc] initWithNibName:@"ContactListChangeUserPictureMenu" imagePicker:picker];
}
/*!
 * @brief Set-up and open the menu
 */
- (id)initWithNibName:(NSString *)nibName imagePicker:(DDContactListImagePicker *)picker
{
	self = [super init];
	if ([[NSBundle mainBundle] loadNibFile:nibName
						 externalNameTable:[NSDictionary dictionaryWithObjectsAndKeys:self, NSNibOwner, AI_topLevelObjects, NSNibTopLevelObjects, nil]
								  withZone:nil]) {
		
		[self setImagePicker:picker];
		[imagePicker setMaxSize:NSMakeSize(128.0f, 128.0f)];
        
		// Set-up collection view
		[imageCollectionView setMaxNumberOfColumns:5];
		[imageCollectionView setMaxNumberOfRows:2];
		[imageCollectionView setMaxItemSize:NSMakeSize(36.0f, 36.0f)];
		[[imageCollectionView enclosingScrollView] setVerticalScrollElasticity:NSScrollElasticityNone];
		
		NSMutableArray *pictures = [self recentSmallPictures];
		NSSize pictureSize = NSMakeSize(32.0f, 32.0f);
		
		// Resize pictures
		for (NSImage *picture in pictures) {
			[picture setSize:pictureSize];
		}
		
		if ([pictures count] < 10) {
			// Create an "empty" image, placeholder icon
			NSImage	*emptyPicture = [[NSImage alloc] initWithSize:pictureSize];
			
			[emptyPicture lockFocus];
			[[NSColor secondarySelectedControlColor] set];
			NSRectFill(NSMakeRect(0.0f, 0.0f, 32.0f, 32.0f));
			[emptyPicture unlockFocus];
			
			// Add placeholders to images
			for (NSUInteger i = [pictures count]; i < 10; ++i) {
				[pictures addObject:emptyPicture];
			}
		}
		
		[self setImages:pictures];
        
		[menu popUpMenuPositioningItem:[menu itemAtIndex:0] atLocation:NSMakePoint(2.0f, -4.0f) inView:imagePicker];
	}
	
	return self;
}

#pragma mark -

- (NSArray *)recentPictures
{
	NSArray *recentPictures = [(IKPictureTakerRecentPictureRepository *)[IKPictureTakerRecentPictureRepository recentRepository] recentPictures];
    
    if (recentPictures.count > 10)
        return [recentPictures subarrayWithRange:NSMakeRange(0, 10)];
    else
        return recentPictures;
}

/*!
 * @brief Small icons for recent pictures
 */
- (NSMutableArray *)recentSmallPictures
{
    NSArray *recentPictures = [self recentPictures];
    
    NSMutableArray *array = [[recentPictures valueForKey:@"smallIcon"] mutableCopy];
    for (NSInteger i = (array.count-1); i >= 0; i--) {
        id imageOrNull = [array objectAtIndex:i];
        
        /* Not all icons have a small icon */
        if (imageOrNull == [NSNull null]) {
            IKPictureTakerRecentPicture *picture = [recentPictures objectAtIndex:i];
            
            [array replaceObjectAtIndex:i
                             withObject:[picture editedImage]];
        }
    }
    
    return array;
}

@end
