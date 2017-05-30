//
//  DDGroupInfoCell.m
//  Duoduo
//
//  Created by 独嘉 on 14-3-3.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDGroupInfoCell.h"
#import "MTUserEntity.h"

@interface DDGroupInfoCell(PrivateAPI)

- (void)imageView:(EGOImageView*)imageView textField:(NSTextField*)textField user:(MTUserEntity*)user;

@end

@implementation DDGroupInfoCell

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

- (void)setUserAtIndex:(int)index withUser:(MTUserEntity*)user
{
    switch (index) {
        case 0:
            [self setFirstUser:user];
            break;
        case 1:
            [self setSecondUser:user];
            break;
        case 2:
            [self setThirdUser:user];
            break;
        case 3:
            [self setForthUser:user];
            break;
        case 4:
            [self setFifthUser:user];
            break;
        case 5:
            [self setSixthUser:user];
            break;
        default:
            break;
    }
}


- (IBAction)clickTheUser:(id)sender
{
    NSButton* button = (NSButton*)sender;
    [self.delegate groupInfoCell:self selectUserIndex:button.tag];
}

- (void)setFirstUser:(MTUserEntity*)firstUser
{
    [self imageView:_firstImageView textField:_firstTextField user:firstUser];
}

- (void)setSecondUser:(MTUserEntity*)secondUser
{
    [self imageView:_secondImageView textField:_secondTextField user:secondUser];
}

- (void)setThirdUser:(MTUserEntity*)thirdUser
{
    [self imageView:_thirdImageView textField:_thirdTextField user:thirdUser];
}

- (void)setForthUser:(MTUserEntity*)forthUser
{
    [self imageView:_forthImageView textField:_forthTextField user:forthUser];
}

- (void)setFifthUser:(MTUserEntity*)fifthUser
{
    [self imageView:_fifthImageView textField:_fifthTextField user:fifthUser];
}

- (void)setSixthUser:(MTUserEntity*)sixthUser
{
    [self imageView:_sixthImageView textField:_sixthTextField user:sixthUser];
}

#pragma mark Private API
- (void)imageView:(EGOImageView*)imageView textField:(NSTextField*)textField user:(MTUserEntity*)user
{
    if (user)
    {
        [imageView setHidden:NO];
        [textField setHidden:NO];
        
        //avatar
        NSURL* imageURL = [NSURL URLWithString:user.avatar];
        [imageView loadImageWithURL:imageURL setplaceholderImage:@"avatar_default.jpg_48x48"];
        
        //name
        NSString* name = user.name;
        if (name)
        {
            [textField setStringValue:name];
        }
    }
    else
    {
        [imageView setHidden:YES];
        [textField setHidden:YES];
    }
}

@end
