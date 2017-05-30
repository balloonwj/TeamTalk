//
//  AIPasteboardAdditions.m
//  Duoduo
//
//  Created by zuoye on 13-12-4.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "AIPasteboardAdditions.h"

@implementation NSPasteboard (AIPasteboardAdditions)

- (NSArray *)filesFromITunesDragPasteboard
{
	NSString		*fileURLPath;
	NSMutableArray  *filePaths = [NSMutableArray array];
	NSDictionary	*iTunesDict = [self propertyListForType:AIiTunesTrackPboardType];
	NSEnumerator	*enumerator = [[[[iTunesDict objectForKey:@"Tracks"] allValues] valueForKeyPath:@"@distinctUnionOfObjects.Location"] objectEnumerator];
    
	while ((fileURLPath = [enumerator nextObject])) {
		[filePaths addObject:[[NSURL URLWithString:fileURLPath] path]];
	}
	
	return filePaths;
}

@end
