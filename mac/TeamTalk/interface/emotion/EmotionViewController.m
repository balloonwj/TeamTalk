//
//  EmotionViewController.m
//  Duoduo
//
//  Created by jianqing.du on 14-1-21.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

/*
 * 0  - 59: 默认(60)
 * 60 - 123: 心情(64)
 * 124 - 172: 休闲(49)
 * 173 - 220: 搞怪(48)
 */

#import "EmotionViewController.h"
#import "EmotionListXmlParser.h"
#import "DDChattingViewController.h"
#import "NSImage+Scale.h"
#define MAX_TABLE_COL   10
#define MAX_GIF_COUNT   240
#define emoWidth 98
#define emoHeight 95

@interface EmotionViewController ()

@end

@implementation EmotionViewController {
    NSInteger min_offset[6];
    NSInteger max_offset[6];
    NSImage *staticImage[MAX_GIF_COUNT];
    EmotionListXmlParser *xmlParser;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithInt: 50]
                                                  forKey: @"NSInitialToolTipDelay"];
        NSString *xmlPath = [[NSBundle mainBundle] pathForResource:@"emotionList.xml"
                                                            ofType:nil];
        xmlParser = [[EmotionListXmlParser alloc] initWithPath:xmlPath];
        
        [[DDSundriesCenter instance] pushTaskToParallelQueue:^{
            for (int i = 0; i < MAX_GIF_COUNT; i++) {
                staticImage[i] = [self getStaticGif:i];
            }
        }];
      
    }
    return self;
}

- (void)awakeFromNib
{

    [_yayaTableView setDataSource:self];
    [_yayaTableView setDelegate:self];
    self.emotionTabView.delegate=self;
    
    
    min_offset[1] = 0;
    max_offset[1] = 59;
    min_offset[2] = 60;
    max_offset[2] = 123;
    min_offset[3] = 124;
    max_offset[3] = 172;
    min_offset[4] = 173;
    max_offset[4] = 220;
    min_offset[5] = 221;
    max_offset[5] = 239;
}

- (void)clickEmotionView:(EmotionCellView *)cellView
{
    [self.delegate emotionViewController:self selectEmotionFile:[cellView emotionFile]];
}

- (NSString *)getFileFrom:(NSString *)text
{
    return [xmlParser getFileFrom:text];
}

- (NSString *)getTextFrom:(NSString *)file
{
    return [xmlParser getTextFrom:file];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return 7;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 30;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTabViewItem *item = [_emotionTabView selectedTabViewItem];
    NSString *tabId = [item identifier];
    NSInteger tabIndex = [self convertToInt:tabId];
    
    NSString *identifier = [tableColumn identifier];
    EmotionCellView *cellView = [tableView makeViewWithIdentifier:identifier
                                                            owner:self];
    
    NSInteger col = [self convertToInt:identifier];
    
    cellView.imageView.objectValue = nil;
    [cellView setEmotionFile:nil];
    cellView.delegate = self;
    NSInteger index = row * MAX_TABLE_COL + col + min_offset[tabIndex];
    if (index <= max_offset[tabIndex]) {
        NSString *name = [NSString stringWithFormat:@"%lu.gif", index];
        NSImage *image = (staticImage[index] != nil) ? staticImage[index] : [NSImage imageNamed:name];
        
        [cellView.imageView setAnimates:NO];
        cellView.imageView.objectValue = image;
        cellView.colTag=col;
        [cellView setEmotionFile:name];
    }
    
    return cellView;
}
- (BOOL)shouldFocusCell:(NSCell *)cell atColumn:(NSInteger)column row:(NSInteger)row
{
    return YES;
}
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    
    [self.yayaTableView reloadData];
    
}
- (NSInteger)convertToInt:(NSString *)stringValue
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *number = [numberFormatter numberFromString:stringValue];
    return [number integerValue];
}


- (NSImage *)getStaticGif: (int)index
{
    NSString *gifName = [NSString stringWithFormat:@"%i.gif", index];
    NSString *path = [[NSBundle mainBundle] pathForResource:gifName ofType:nil];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithData:data];
    
    NSNumber *frames = [bitmap valueForProperty:NSImageFrameCount];
    
    int frame = [frames intValue] / 2;
    if (index == 167) {
        frame = [frames intValue] - 1; // 特殊处理，这个gif图片只有最后一张是全图
    }
    
    [bitmap setProperty:NSImageCurrentFrame
                 withValue:[NSNumber numberWithUnsignedInt:frame] ];
    NSData *repData = [bitmap representationUsingType:NSPNGFileType
                                              properties:nil];
    
    NSImage *image = [[NSImage alloc] initWithData:repData];
    return image;
}

#pragma mark -
#pragma mark EmotionCellView Delegate
- (void)selectEmotion:(EmotionCellView *)emotionCellView
{
    [self.delegate emotionViewController:self selectEmotionFile:[emotionCellView emotionFile]];
}

- (void)mouseEnterEmotion:(EmotionCellView *)emotionCellView
{
    if (emotionCellView.emotionFile == nil) {
        [self.emotionPreview setHidden:YES];
        [self.emotionPreviewBG setHidden:YES];
        return;
    }
    [self.emotionPreview setHidden:NO];
    [self.emotionPreviewBG setHidden:NO];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:[emotionCellView emotionFile] ofType:nil];
    
    NSImage * pic = [[NSImage alloc] initWithContentsOfFile:path];
    [self.emotionPreview setImage:pic];
    [self.emotionPreview setAnimates:YES];
    if (emotionCellView.colTag>=5) {
        //to left
        self.emotionPreview.frame=CGRectMake(37, 160, emoWidth, emoHeight);
        self.emotionPreviewBG.frame=self.emotionPreview.frame;
        
    }else
    {
        self.emotionPreview.frame=CGRectMake(self.view.frame.size.width-emoWidth-37, 160, emoWidth, emoHeight);
        self.emotionPreviewBG.frame=self.emotionPreview.frame;
    }
}

- (void)mouseExitEmotion:(EmotionCellView *)emotionCellView
{
    [self.emotionPreview  setImage:nil];
    [self.emotionPreview setHidden:YES];
    [self.emotionPreviewBG setHidden:YES];
}
@end
