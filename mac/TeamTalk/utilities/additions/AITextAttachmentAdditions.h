@interface NSTextAttachment (AITextAttachmentAdditions)
- (BOOL)consideredImageForHFSType:(OSType)HFSTypeCode
					pathExtension:(NSString *)pathExtension;
- (BOOL)wrapsImage;
@end
