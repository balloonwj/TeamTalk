
#import "AITextAttachmentAdditions.h"

@implementation NSTextAttachment (AITextAttachmentAdditions)

- (BOOL)consideredImageForHFSType:(OSType)HFSTypeCode
					pathExtension:(NSString *)pathExtension
{
	NSMutableArray *imageFileTypes = [[NSImage imageFileTypes] mutableCopy];
	NSArray *removeFileTypes = [NSArray arrayWithObjects:@"pdf", @"PDF", @"psd", @"PSD", @"'PDF '", nil];
	
	[imageFileTypes removeObjectsInArray:removeFileTypes];
	
	return ([imageFileTypes containsObject:NSFileTypeForHFSTypeCode(HFSTypeCode)] ||
			([imageFileTypes containsObject:pathExtension]));
}

- (BOOL)wrapsImage
{
	NSFileWrapper	*fileWrapper = [self fileWrapper];
	return ([self consideredImageForHFSType:[[fileWrapper fileAttributes] fileHFSTypeCode]
							  pathExtension:[[fileWrapper filename] pathExtension]]);
}

@end