//
//  AIPasteboardAdditions.h
//  Duoduo
//
//  Created by zuoye on 13-12-4.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//
#define AIiTunesTrackPboardType @"CorePasteboardFlavorType 0x6974756E" /* CorePasteboardFlavorType 'itun' */

@interface NSPasteboard (AIPasteboardAdditions)
- (NSArray *)filesFromITunesDragPasteboard;
@end
