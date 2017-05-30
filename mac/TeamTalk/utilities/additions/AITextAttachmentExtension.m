#import "AITextAttachmentExtension.h"
#import "AIImageAdditions.h"
#import "AITextAttachmentAdditions.h"
#import "AIImageDrawingAdditions.h"


#define ICON_WIDTH	64
#define ICON_HEIGHT	64

@implementation AITextAttachmentExtension

+ (AITextAttachmentExtension *)textAttachmentExtensionFromTextAttachment:(NSTextAttachment *)textAttachment
{
	AITextAttachmentExtension *textAttachmentExtension = [[AITextAttachmentExtension alloc] init];
	[textAttachmentExtension setShouldSaveImageForLogging:YES];
	[textAttachmentExtension setAttachmentCell:[textAttachment attachmentCell]];
    
	NSFileWrapper *fileWrapper = [textAttachment fileWrapper];
	[textAttachmentExtension setString:[fileWrapper preferredFilename]];
	[textAttachmentExtension setImage:[[NSImage alloc] initWithData:[fileWrapper regularFileContents]]];
	DDLog(@"image is %@", [textAttachmentExtension image]);
	return textAttachmentExtension;
}

- (id)init
{
	if ((self = [super init])) {
		stringRepresentation = nil;
		shouldSaveImageForLogging = NO;
		hasAlternate = NO;
		shouldAlwaysSendAsText = NO;
		path = nil;
		image = nil;
		imageClass = nil;
	}
	
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	AITextAttachmentExtension *ret = [[[self class] alloc] init];
	
	if(ret == nil)
		return nil;
	
	[ret setAttachmentCell:[self attachmentCell]];
	
	[ret setString:stringRepresentation];
	[ret setShouldSaveImageForLogging:shouldSaveImageForLogging];
	[ret setHasAlternate:hasAlternate];
	[ret setPath:path];
	[ret setImage:image];
	[ret setImageClass:imageClass];
	[ret setShouldAlwaysSendAsText:shouldAlwaysSendAsText];
	
	return ret;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	if ([encoder allowsKeyedCoding]) {
        [encoder encodeObject:stringRepresentation forKey:@"AITextAttachmentExtension_stringRepresentation"];
        [encoder encodeObject:[NSNumber numberWithBool:shouldSaveImageForLogging] forKey:@"AITextAttachmentExtension_shouldSaveImageForLogging"];
        [encoder encodeObject:[NSNumber numberWithBool:hasAlternate] forKey:@"AITextAttachmentExtension_hasAlternate"];
        [encoder encodeObject:[NSNumber numberWithBool:shouldAlwaysSendAsText] forKey:@"AITextAttachmentExtension_shouldAlwaysSendAsText"];
		[encoder encodeObject:path forKey:@"AITextAttachmentExtension_path"];
		[encoder encodeObject:image forKey:@"AITextAttachmentExtension_image"];
		
    } else {
        [encoder encodeObject:stringRepresentation];
        [encoder encodeObject:[NSNumber numberWithBool:shouldSaveImageForLogging]];
        [encoder encodeObject:[NSNumber numberWithBool:hasAlternate]];
        [encoder encodeObject:[NSNumber numberWithBool:shouldAlwaysSendAsText]];
		[encoder encodeObject:path];
		[encoder encodeObject:image];
    }
}

/*!
 * @brief Initialize with coder
 */
- (id)initWithCoder:(NSCoder *)decoder
{
	if ((self = [super init]))
	{
		if ([decoder allowsKeyedCoding]) {
			// Can decode keys in any order
			[self setString:[decoder decodeObjectForKey:@"AITextAttachmentExtension_stringRepresentation"]];
			[self setShouldSaveImageForLogging:[[decoder decodeObjectForKey:@"AITextAttachmentExtension_shouldSaveImageForLogging"] boolValue]];
			[self setHasAlternate:[[decoder decodeObjectForKey:@"AITextAttachmentExtension_hasAlternate"] boolValue]];
			[self setShouldAlwaysSendAsText:[[decoder decodeObjectForKey:@"AITextAttachmentExtension_shouldAlwaysSendAsText"] boolValue]];
			[self setPath:[decoder decodeObjectForKey:@"AITextAttachmentExtension_path"]];
			[self setImage:[decoder decodeObjectForKey:@"AITextAttachmentExtension_image"]];
			
		} else {
			// Must decode keys in same order as encodeWithCoder:
			[self setString:[decoder decodeObject]];
			[self setShouldSaveImageForLogging:[[decoder decodeObject] boolValue]];
			[self setHasAlternate:[[decoder decodeObject] boolValue]];
			[self setShouldAlwaysSendAsText:[[decoder decodeObject] boolValue]];
			[self setPath:[decoder decodeObject]];
			[self setImage:[decoder decodeObject]];
		}
	}
	
	return self;
}

/*!
 * @brief Set the path represented by this text attachment
 *
 * If an image has not been set, and this path points to an image, [self image] will return the image, loading it from this path
 */
- (void)setPath:(NSString *)inPath
{
	if (inPath != path) {
		path = [inPath copy];
	}
}

- (NSString *)path
{
	if (!path && image) {
		/* If no path is available, an image *is* available, and we need a path to that image, write it out and return
		 * the location of the written data.
		 */
		NSString *tmpDir = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
		NSString *filename = [[self string] stringByAppendingPathExtension:@"png"];
		[[NSFileManager defaultManager] createDirectoryAtPath:tmpDir withIntermediateDirectories:YES attributes:nil error:NULL];
        
		[self setPath:[tmpDir stringByAppendingPathComponent:filename]];
		[[image PNGRepresentation] writeToFile:path atomically:NO];
	}
    
	return path;
}

/*!
 * @brief Set the image represented by this text attachment
 */
- (void)setImage:(NSImage *)inImage
{
	if (inImage != image) {
		image = inImage;
	}
}

/*!
 * @brief Returns YES if this attachment is for an image
 */
- (BOOL)attachesAnImage
{
	BOOL attachesAnImage = (image != nil);
	
	if (!attachesAnImage && path) {
		OSType			HFSTypeCode = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL] fileHFSTypeCode];
		
		attachesAnImage = [self consideredImageForHFSType:HFSTypeCode
											pathExtension:[path pathExtension]];
	}
    
	return attachesAnImage;
}

- (NSImage *)image
{
	if (!image && [self attachesAnImage]) {
		image = [[NSImage alloc] initWithContentsOfFile:[self path]];
	}
	
	return image;
}



/*!
 * @brief Return a 32x32 image representing this attachment
 */
- (NSImage *)iconImage
{
	NSImage *originalImage;
	NSImage *iconImage;
    
	if ((originalImage = [self image])) {
		/*
        NSSize currentSize = [originalImage size];
		if ((currentSize.width > ICON_WIDTH) || (currentSize.height > ICON_HEIGHT)) {
			iconImage = [originalImage imageByScalingToSize:NSMakeSize(ICON_WIDTH, ICON_WIDTH)];
            
		} else {
			iconImage = [originalImage copy];
		}*/
        iconImage = [originalImage copy];
        
	} else {
		if ([self path]) {
			iconImage = [[NSWorkspace sharedWorkspace] iconForFile:[self path]];
		} else {
			DDLog(@"-[%@ iconImage]: Warning, no path available", self);
			iconImage = nil;
		}
	}
	
	return iconImage;
}

- (void)setString:(NSString *)inString
{
	if (stringRepresentation != inString) {
		stringRepresentation = [inString copy];
	}
}

/*!
 * @brief Return a fileWrapper for the file/image we represent, creating and caching it if necessary
 *
 * @result An NSFileWrapper
 */
- (NSFileWrapper *)fileWrapper
{
	NSFileWrapper *myFilewrapper = [super fileWrapper];
	
	if (!myFilewrapper) {
		if ([self path]) {
			myFilewrapper = [[NSFileWrapper alloc] initWithPath:[self path]];
            
		} else if ([self image]) {
			myFilewrapper = [[NSFileWrapper alloc] initWithSerializedRepresentation:[[self image] PNGRepresentation]];
			[myFilewrapper setPreferredFilename:[[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingPathExtension:@"png"]];
		}
        
		[self setFileWrapper:myFilewrapper];
	}
	
	return myFilewrapper;
}

/*!
 * @brief Return a string which represents our object
 *
 * If asked for a string and we don't have one available, create, cache, and return a globally unique string
 */
- (NSString *)string
{
	if (stringRepresentation == nil) {
		[self setString:[[NSProcessInfo processInfo] globallyUniqueString]];
	}
	
	return stringRepresentation;
}


@synthesize imageClass;
@synthesize shouldSaveImageForLogging;
@synthesize hasAlternate;
@synthesize shouldAlwaysSendAsText;

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@<%p>: %@",NSStringFromClass([self class]),self,[super description]];
}

@end
