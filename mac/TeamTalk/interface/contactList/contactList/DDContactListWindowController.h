//
//  DDContactListWindowController.h
//  Duoduo
//
//  Created by zuoye on 13-11-22.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDWindowController.h"

@interface DDContactListWindowController : DDWindowController<NSTableViewDataSource,NSTableViewDelegate>{
    @private
    NSArray *flickrPhotos;
}

@property (strong)NSArray *flickrPhotos;

@property (weak) IBOutlet NSTableView *contactListView;
+(DDContactListWindowController *)contactListWindowControllerWithOwner:(id)inOwner __attribute__((objc_method_family(new)));

-(void)updateContactListOrder;


@end
