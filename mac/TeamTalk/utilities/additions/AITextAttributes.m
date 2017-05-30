
#import "AITextAttributes.h"
#import "AIFontManagerAdditions.h"

#define FONT_DEFAULT_NAME	@"Helvetica"

@interface AITextAttributes ()
- (id)initWithFontFamily:(NSString *)inFamilyName traits:(NSFontTraitMask)inTraits size:(NSInteger)inSize;
- (id)initWithDictionary:(NSDictionary *)inAttributes;
- (void)updateFont;
@end

@implementation AITextAttributes

//Creates a new instance of AITextAttributes
+ (id)textAttributesWithFontFamily:(NSString *)inFamilyName traits:(NSFontTraitMask)inTraits size:(NSInteger)inSize
{
    return [[self alloc] initWithFontFamily:inFamilyName traits:inTraits size:inSize];
}

+ (id)textAttributesWithDictionary:(NSDictionary *)inAttributes
{
	return [[self alloc] initWithDictionary:inAttributes];
}

//init
- (id)initWithFontFamily:(NSString *)inFamilyName traits:(NSFontTraitMask)inTraits size:(NSInteger)inSize
{
	if ((self = [self init])) {
		fontFamilyName = inFamilyName;
		fontTraitsMask = inTraits;
		fontSize = inSize;
	}
    
	return self;
}

- (id)initWithDictionary:(NSDictionary *)inAttributes
{
	if ((self = [self init])) {
		dictionary = [inAttributes mutableCopy];
        
		NSFont	*font = [dictionary objectForKey:NSFontAttributeName];
        
		if (font) {
			fontFamilyName = [font familyName];
			fontTraitsMask = [[NSFontManager sharedFontManager] traitsOfFont:font];
			fontSize = [font pointSize];
		} else {
			fontFamilyName = @"Helvetica";
			fontTraitsMask = 0;
			fontSize = 12;
		}
	}
    
	return self;
}

- (id)init
{
	if ((self = [super init])) {
		dictionary = [[NSMutableDictionary alloc] init];
		
		fontFamilyName = nil;
		fontTraitsMask = 0;
		fontSize = 0;
	}
    
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	AITextAttributes	*newTextAttributes = [[AITextAttributes alloc] init];
    
	newTextAttributes->dictionary = [dictionary mutableCopy];
	newTextAttributes->fontFamilyName = fontFamilyName;
	newTextAttributes->fontTraitsMask = fontTraitsMask;
	newTextAttributes->fontSize = fontSize;
    
	return newTextAttributes;
}

- (NSString *)fontFamily
{
	return fontFamilyName;
}

//Set the font family (name)
- (void)setFontFamily:(NSString *)inName
{
    if (fontFamilyName != inName) {
        fontFamilyName = inName;
        
		[dictionary removeObjectForKey:NSFontAttributeName];
	}
}

- (NSInteger)fontSize
{
	return fontSize;
}

//Set the font size
- (void)setFontSize:(NSInteger)inSize
{
	if (fontSize != inSize) {
		fontSize = inSize;
		
		[dictionary removeObjectForKey:NSFontAttributeName];
	}
}

- (void)setFontSizeFromNumber:(NSNumber *)inSize
{
	[self setFontSize:[inSize intValue]];
}

- (NSColor *)textColor
{
	return [dictionary objectForKey:NSForegroundColorAttributeName];
}

//Set the text foreground color
- (void)setTextColor:(NSColor *)inColor
{
	if (inColor) {
		[dictionary setObject:inColor forKey:NSForegroundColorAttributeName];
	} else {
		[dictionary removeObjectForKey:NSForegroundColorAttributeName];
	}
}

- (NSColor *)textBackgroundColor
{
	return [dictionary objectForKey:NSBackgroundColorAttributeName];
}

//Sub-backround color (drawn just behind the text)
- (void)setTextBackgroundColor:(NSColor *)inColor
{
	if (inColor) {
		[dictionary setObject:inColor forKey:NSBackgroundColorAttributeName];
	} else {
		[dictionary removeObjectForKey:NSBackgroundColorAttributeName];
	}
}

- (NSColor *)backgroundColor
{
	return [dictionary objectForKey:AIBodyColorAttributeName];
}

//Set the background color
- (void)setBackgroundColor:(NSColor *)inColor
{
	if (inColor) {
		[dictionary setObject:inColor forKey:AIBodyColorAttributeName];
	} else {
		[dictionary removeObjectForKey:AIBodyColorAttributeName];
	}
}

- (NSFontTraitMask)traits
{
	return fontTraitsMask;
}

//Enable a masked trait (bold, italic)
- (void)enableTrait:(NSFontTraitMask)inTrait
{
    fontTraitsMask |= inTrait;
	[dictionary removeObjectForKey:NSFontAttributeName];
}

- (void)setTraits:(NSNumber *)inTraits
{
	fontTraitsMask = [inTraits unsignedIntValue];
	[dictionary removeObjectForKey:NSFontAttributeName];
}

//Disable a masked trait (bold, italic)
- (void)disableTrait:(NSFontTraitMask)inTrait
{
    if (fontTraitsMask && inTrait) {
        fontTraitsMask ^= inTrait;
    }
    
	[dictionary removeObjectForKey:NSFontAttributeName];
}

- (BOOL)underline
{
	return [[dictionary objectForKey:NSUnderlineStyleAttributeName] boolValue];
}

//Enable/Disable underlining
- (void)setUnderline:(BOOL)inUnderline
{
    if (inUnderline) {
        [dictionary setObject:[NSNumber numberWithBool:inUnderline] forKey:NSUnderlineStyleAttributeName];
    } else {
        [dictionary removeObjectForKey:NSUnderlineStyleAttributeName];
    }
}

- (BOOL)strikethrough
{
	return [[dictionary objectForKey:NSStrikethroughStyleAttributeName] boolValue];
}

// Enable or disable strikethrough
- (void)setStrikethrough:(BOOL)inStrikethrough{
	if (inStrikethrough) {
		[dictionary setObject:[NSNumber numberWithBool:inStrikethrough] forKey:NSStrikethroughStyleAttributeName];
	} else {
		[dictionary removeObjectForKey:NSStrikethroughStyleAttributeName];
	}
}

- (BOOL)subscript
{
	return [[dictionary objectForKey:NSBaselineOffsetAttributeName] floatValue]  < 0.0f;
}

// Enable or disable subscript
- (void)setSubscript:(BOOL)inSubscript{
	if (inSubscript) {
		[dictionary setObject:[NSNumber numberWithFloat:((float)fontSize / -2.0f)] forKey:NSBaselineOffsetAttributeName];
		[self setFontSize:(fontSize - 2)];
		
	} else {
		[dictionary removeObjectForKey:NSBaselineOffsetAttributeName];
		[self setFontSize:(fontSize + 2)];
	}
}

- (BOOL)superscript
{
	return [[dictionary objectForKey:NSBaselineOffsetAttributeName] floatValue]  > 0.0f;
}

// Enable or disable superscript
- (void)setSuperscript:(BOOL)inSuperscript{
	if (inSuperscript) {
		[dictionary setObject:[NSNumber numberWithFloat:((float)fontSize / 2.0f)] forKey:NSBaselineOffsetAttributeName];
		[self setFontSize:(fontSize - 2)];
        
	} else {
		[dictionary removeObjectForKey:NSBaselineOffsetAttributeName];
		[self setFontSize:(fontSize + 2)];
	}
}

- (void)setLinkURL:(NSURL *)inURL
{
    if (inURL) {
        [dictionary setObject:inURL forKey:NSLinkAttributeName];
    } else {
        [dictionary removeObjectForKey:NSLinkAttributeName];
    }
}

- (void)setLanguageValue:(id)languageValue
{
	if (languageValue) {
		[dictionary setObject:languageValue forKey:@"LanguageValue"];
	} else {
		[dictionary removeObjectForKey:@"LanguageValue"];
	}
}

- (id)languageValue
{
	return [dictionary objectForKey:@"LanguageValue"];
}

//Returns a dictinary of attributes
- (NSDictionary *)dictionary
{
	//If the dictionary doesn't specify a font, it means our font has changed since the last call here. Update now.
	if (![dictionary objectForKey:NSFontAttributeName]) [self updateFont];
    
    return dictionary;
}

- (void)resetFontAttributes
{
	fontFamilyName = nil;
	fontSize = 0;
	[dictionary removeObjectForKey:NSForegroundColorAttributeName];
	[dictionary removeObjectForKey:NSBackgroundColorAttributeName];
	[dictionary removeObjectForKey:@"LanguageValue"];
}

//Updates the cached font
- (void)updateFont
{
    NSFont	*font = nil;
    
    //Ensure font size isn't 0
    if (!fontSize) fontSize = 12;
    
    //Create the font
    if (fontFamilyName) {
		font = [[NSFontManager sharedFontManager] fontWithFamilyInsensitively:fontFamilyName
																	   traits:fontTraitsMask
																	   weight:5
																		 size:fontSize];
    }
    
    //If no name was specified or the font is not available, use the default font
    if (!font) {
        font = [[NSFontManager sharedFontManager] fontWithFamily:FONT_DEFAULT_NAME
														  traits:fontTraitsMask
														  weight:5
															size:fontSize];
		//Ensure that fontTraitsMask was actually respected; fontWithFamily:traits:weight:size: may not do it for us depending on the font
		font = [[NSFontManager sharedFontManager] convertFont:font toHaveTrait:fontTraitsMask];
    }
    
    if (font) { //Just to be safe, incase the default font was unavailable for some reason
        [dictionary setObject:font forKey:NSFontAttributeName];
    }
}

- (void)setWritingDirection:(NSWritingDirection)inDirection
{
	NSParagraphStyle			*paragraphStyle;
	NSMutableParagraphStyle		*newParagraphStyle;
	
	if (!(paragraphStyle = [dictionary objectForKey:NSParagraphStyleAttributeName])) {
		paragraphStyle = [NSParagraphStyle defaultParagraphStyle];
	}
	
	newParagraphStyle = [paragraphStyle mutableCopy];
	[newParagraphStyle setBaseWritingDirection:inDirection];
	[dictionary setObject:newParagraphStyle forKey:NSParagraphStyleAttributeName];
}

@end
