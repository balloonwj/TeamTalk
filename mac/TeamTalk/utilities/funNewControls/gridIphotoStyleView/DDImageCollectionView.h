//
//  DDImageCollectionView.h
//  Duoduo
//
//  Created by maye on 13-11-14.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

@protocol DDImageCollectionViewDelegate;
#pragma mark - DDImageCollectionView

@interface DDImageCollectionView : NSCollectionView{
    
    
	id <DDImageCollectionViewDelegate> __weak delegate;
    
@protected
	IBOutlet NSArrayController *__weak itemsController;
	
	NSInteger highlightStyle;
	CGFloat highlightSize;
	CGFloat highlightCornerRadius;
    
	NSUInteger highlightedIndex;
}

@property (readwrite, weak, nonatomic) id <DDImageCollectionViewDelegate> delegate;

@property (weak) IBOutlet NSArrayController *itemsController;

@property (assign) NSInteger highlightStyle;
@property (assign) CGFloat highlightSize;
@property (assign) CGFloat highlightCornerRadius;
@property (assign) NSUInteger highlightedIndex;

#pragma mark -

/*!
 * @brief Set the image for item at index
 *
 * @param <tt>NSImage</tt>
 * @param <tt>NSUInteger</tt>
 */
- (void)setImage:(NSImage *)anImage forItemAtIndex:(NSUInteger)anIndex;

@end

#pragma mark -

/*!
 * @brief DDImageCollectionViewCornerStyle
 *
 * Item & Highlight corners style, squared|rounded
 */
enum {
	DDImageCollectionViewCornerSquaredStyle = 0,
	DDImageCollectionViewCornerRoundedStyle = 1
};

typedef NSInteger AIImageCollectionViewCornerStyle;

/*!
 * @brief DDImageCollectionViewHighlightStyle
 *
 * Highlight style, border|background
 */
enum {
	DDImageCollectionViewHighlightBorderStyle = 0,
	DDImageCollectionViewHighlightBackgroundStyle = 1
};

typedef NSInteger AIImageCollectionViewHighlightStyle;

#pragma mark - DDImageCollectionViewDelegate

/*!
 * @protocol DDImageCollectionViewDelegate
 * @brief Sends highlighting/selection related messages to a delegate
 */
@protocol DDImageCollectionViewDelegate <NSObject>

@optional

- (BOOL)imageCollectionView:(DDImageCollectionView *)imageCollectionView shouldSelectItemAtIndex:(NSUInteger)index;
- (BOOL)imageCollectionView:(DDImageCollectionView *)imageCollectionView shouldHighlightItemAtIndex:(NSUInteger)index;
- (BOOL)imageCollectionView:(DDImageCollectionView *)imageCollectionView shouldDeleteItemsAtIndexes:(NSIndexSet *)indexes;
- (void)imageCollectionView:(DDImageCollectionView *)imageCollectionView didSelectItemAtIndex:(NSUInteger)index;
- (void)imageCollectionView:(DDImageCollectionView *)imageCollectionView didHighlightItemAtIndex:(NSUInteger)index;
- (void)imageCollectionView:(DDImageCollectionView *)imageCollectionView didDeleteItemsAtIndexes:(NSIndexSet *)indexes;

@end