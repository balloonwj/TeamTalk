
#import "AIColorAdditions.h"
#import "NSString+DDStringAdditions.h"

static NSArray *defaultValidColors = nil;
#define VALID_COLORS_ARRAY [[NSArray alloc] initWithObjects:@"aqua", @"aquamarine", @"blue", @"blueviolet", @"brown", @"burlywood", @"cadetblue", @"chartreuse", @"chocolate", @"coral", @"cornflowerblue", @"crimson", @"cyan", @"darkblue", @"darkcyan", @"darkgoldenrod", @"darkgreen", @"darkgrey", @"darkkhaki", @"darkmagenta", @"darkolivegreen", @"darkorange", @"darkorchid", @"darkred", @"darksalmon", @"darkseagreen", @"darkslateblue", @"darkslategrey", @"darkturquoise", @"darkviolet", @"deeppink", @"deepskyblue", @"dimgrey", @"dodgerblue", @"firebrick", @"forestgreen", @"fuchsia", @"gold", @"goldenrod", @"green", @"greenyellow", @"grey", @"hotpink", @"indianred", @"indigo", @"lawngreen", @"lightblue", @"lightcoral", @"lightgreen", @"lightgrey", @"lightpink", @"lightsalmon", @"lightseagreen", @"lightskyblue", @"lightslategrey", @"lightsteelblue", @"lime", @"limegreen", @"magenta", @"maroon", @"mediumaquamarine", @"mediumblue", @"mediumorchid", @"mediumpurple", @"mediumseagreen", @"mediumslateblue", @"mediumspringgreen", @"mediumturquoise", @"mediumvioletred", @"midnightblue", @"navy", @"olive", @"olivedrab", @"orange", @"orangered", @"orchid", @"palegreen", @"paleturquoise", @"palevioletred", @"peru", @"pink", @"plum", @"powderblue", @"purple", @"red", @"rosybrown", @"royalblue", @"saddlebrown", @"salmon", @"sandybrown", @"seagreen", @"sienna", @"silver", @"skyblue", @"slateblue", @"slategrey", @"springgreen", @"steelblue", @"tan", @"teal", @"thistle", @"tomato", @"turquoise", @"violet", @"yellowgreen", nil]

static NSMutableDictionary *RGBColorValues = nil;

//two parts of a single path:
//	defaultRGBTxtLocation1/VERSION/defaultRGBTxtLocation2
static NSString *defaultRGBTxtLocation1 = @"/usr/share/emacs";
static NSString *defaultRGBTxtLocation2 = @"etc/rgb.txt";

#ifdef DEBUG_BUILD
#define COLOR_DEBUG TRUE
#else
#define COLOR_DEBUG FALSE
#endif

@implementation NSDictionary (AIColorAdditions_RGBTxtFiles)

//see /usr/share/emacs/(some version)/etc/rgb.txt for an example of such a file.
//the pathname does not need to end in 'rgb.txt', but it must be a file in UTF-8 encoding.
//the keys are colour names (all converted to lowercase); the values are RGB NSColors.
+ (id)dictionaryWithContentsOfRGBTxtFile:(NSString *)path
{
	NSMutableData *data = [NSMutableData dataWithContentsOfFile:path];
	if (!data) return nil;
	
	char *ch = [data mutableBytes]; //we use mutable bytes because we want to tokenise the string by replacing separators with '\0'.
	NSUInteger length = [data length];
	struct {
		const char *redStart, *greenStart, *blueStart, *nameStart;
		const char *redEnd,   *greenEnd,   *blueEnd;
		float red, green, blue;
		unsigned reserved: 23;
		unsigned inComment: 1;
		char prevChar;
	} state = {
		.prevChar = '\n',
		.redStart = NULL, .greenStart = NULL, .blueStart = NULL, .nameStart = NULL,
		.inComment = NO,
	};
	
	NSDictionary *result = nil;
	NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
	
	//the rgb.txt file that comes with Mac OS X 10.3.8 contains 752 entries.
	//we create 3 autoreleased objects for each one.
	//best to not pollute our caller's autorelease pool.
	@autoreleasepool {
		for (unsigned i = 0; i < length; ++i) {
			if (state.inComment) {
				if (ch[i] == '\n') state.inComment = NO;
			} else if (ch[i] == '\n') {
				if (state.prevChar != '\n') { //ignore blank lines
					if (	! ((state.redStart   != NULL)
							   && (state.greenStart != NULL)
							   && (state.blueStart  != NULL)
							   && (state.nameStart  != NULL)))
					{
#if COLOR_DEBUG
						DDLog(@"Parse error reading rgb.txt file: a non-comment line was encountered that did not have all four of red (%p), green (%p), blue (%p), and name (%p) - index is %u",
							  state.redStart,
							  state.greenStart,
							  state.blueStart,
							  state.nameStart, i);
#endif
						goto end;
					}
					
					NSRange range = {
						.location = state.nameStart - ch,
						.length   = (&ch[i]) - state.nameStart,
					};
					NSString *name = [NSString stringWithData:[data subdataWithRange:range] encoding:NSUTF8StringEncoding];
					NSColor *color = [NSColor colorWithCalibratedRed:state.red
															   green:state.green
																blue:state.blue
															   alpha:1.0f];
					[mutableDict setObject:color forKey:name];
					NSString *lowercaseName = [name lowercaseString];
					if (![mutableDict objectForKey:lowercaseName]) {
						//only add the lowercase version if it isn't already defined
						[mutableDict setObject:color forKey:lowercaseName];
					}
					
					state.redStart = state.greenStart = state.blueStart = state.nameStart =
					state.redEnd   = state.greenEnd   = state.blueEnd   = NULL;
				} //if (prevChar != '\n')
			} else if ((ch[i] != ' ') && (ch[i] != '\t')) {
				if (state.prevChar == '\n' && ch[i] == '#') {
					state.inComment = YES;
				} else {
					if (!state.redStart) {
						state.redStart = &ch[i];
						state.red = (float)(strtod(state.redStart, (char **)&state.redEnd) / 255.0f);
					} else if ((!state.greenStart) && state.redEnd && (&ch[i] >= state.redEnd)) {
						state.greenStart = &ch[i];
						state.green = (float)(strtod(state.greenStart, (char **)&state.greenEnd) / 255.0f);
					} else if ((!state.blueStart) && state.greenEnd && (&ch[i] >= state.greenEnd)) {
						state.blueStart = &ch[i];
						state.blue = (float)(strtod(state.blueStart, (char **)&state.blueEnd) / 255.0f);
					} else if ((!state.nameStart) && state.blueEnd && (&ch[i] >= state.blueEnd)) {
						state.nameStart  = &ch[i];
					}
				}
			}
			state.prevChar = ch[i];
		} //for (unsigned i = 0; i < length; ++i)
	}
	
	//why not use -copy? because this is subclass-friendly.
	//you can call this method on NSMutableDictionary and get a mutable dictionary back.
	result = [[self alloc] initWithDictionary:mutableDict];
end:
	
	return result;
}

@end

@implementation NSColor (AIColorAdditions_RGBTxtFiles)

+ (NSDictionary *)colorNamesDictionary
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		RGBColorValues = [[NSMutableDictionary alloc] init];
		NSArray *paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:defaultRGBTxtLocation1 error:NULL];
		for (NSString *middlePath in paths) {
			NSString *path = [defaultRGBTxtLocation1 stringByAppendingPathComponent:[middlePath stringByAppendingPathComponent:defaultRGBTxtLocation2]];
			NSDictionary *extraColors = [NSDictionary dictionaryWithContentsOfRGBTxtFile:path];
			[RGBColorValues addEntriesFromDictionary:extraColors];
			if (extraColors) {
#if COLOR_DEBUG
				DDLog(@"Got colour values from %@", path);
#endif
				break;
			}
		}
		[RGBColorValues addEntriesFromDictionary:@{
                                                   @"black": [NSColor colorWithHTMLString:@"#000"],
                                                   @"silver": [NSColor colorWithHTMLString:@"#c0c0c0"],
                                                   @"gray": [NSColor colorWithHTMLString:@"#808080"],
                                                   @"grey": [NSColor colorWithHTMLString:@"#808080"],
                                                   @"white": [NSColor colorWithHTMLString:@"#fff"],
                                                   @"maroon": [NSColor colorWithHTMLString:@"#800000"],
                                                   @"red": [NSColor colorWithHTMLString:@"#f00"],
                                                   @"purple": [NSColor colorWithHTMLString:@"#800080"],
                                                   @"fuchsia": [NSColor colorWithHTMLString:@"#f0f"],
                                                   @"green": [NSColor colorWithHTMLString:@"#008000"],
                                                   @"lime": [NSColor colorWithHTMLString:@"#0f0"],
                                                   @"olive": [NSColor colorWithHTMLString:@"#808000"],
                                                   @"yellow": [NSColor colorWithHTMLString:@"#ff0"],
                                                   @"navy": [NSColor colorWithHTMLString:@"#000080"],
                                                   @"blue": [NSColor colorWithHTMLString:@"#00f"],
                                                   @"teal": [NSColor colorWithHTMLString:@"#008080"],
                                                   @"aqua": [NSColor colorWithHTMLString:@"#0ff"],
                                                   @"indigo": [NSColor colorWithHTMLString:@"#4b0082"],
                                                   @"crimson": [NSColor colorWithHTMLString:@"#dc143c"]
                                                   }];
	});
	
	return RGBColorValues;
}

@end

@implementation NSColor (AIColorAdditions_Comparison)

//Returns YES if the colors are equal
- (BOOL)equalToRGBColor:(NSColor *)inColor
{
    NSColor	*convertedA = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    NSColor	*convertedB = [inColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    
    return (([convertedA redComponent]   == [convertedB redComponent])   &&
            ([convertedA blueComponent]  == [convertedB blueComponent])  &&
            ([convertedA greenComponent] == [convertedB greenComponent]) &&
            ([convertedA alphaComponent] == [convertedB alphaComponent]));
}

@end

@implementation NSColor (AIColorAdditions_DarknessAndContrast)

//Returns YES if this color is dark
- (BOOL)colorIsDark
{
    return ([[self colorUsingColorSpaceName:NSCalibratedRGBColorSpace] brightnessComponent] < 0.5f);
}

- (BOOL)colorIsMedium
{
	CGFloat brightness = [[self colorUsingColorSpaceName:NSCalibratedRGBColorSpace] brightnessComponent];
	return (0.35f < brightness && brightness < 0.65f);
}

//Percent should be -1.0 to 1.0 (negatives will make the color brighter)
- (NSColor *)darkenBy:(CGFloat)amount
{
    NSColor	*convertedColor = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    
    return [NSColor colorWithCalibratedHue:[convertedColor hueComponent]
                                saturation:[convertedColor saturationComponent]
                                brightness:([convertedColor brightnessComponent] - amount)
                                     alpha:[convertedColor alphaComponent]];
}

- (NSColor *)darkenAndAdjustSaturationBy:(CGFloat)amount
{
    NSColor	*convertedColor = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    
    return [NSColor colorWithCalibratedHue:[convertedColor hueComponent]
                                saturation:(([convertedColor saturationComponent] == 0.0f) ? [convertedColor saturationComponent] : ([convertedColor saturationComponent] + amount))
                                brightness:([convertedColor brightnessComponent] - amount)
                                     alpha:[convertedColor alphaComponent]];
}

//Inverts the luminance of this color so it looks good on selected/dark backgrounds
- (NSColor *)colorWithInvertedLuminance
{
    CGFloat h,l,s;
    
	NSColor *convertedColor = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    
    //Get our HLS
    [convertedColor getHue:&h saturation:&s brightness:&l alpha:NULL];
    
    //Invert L
    l = 1.0f - l;
    
    //Return the new color
    return [NSColor colorWithCalibratedHue:h saturation:s brightness:l alpha:1.0f];
}

//Returns a color that contrasts well with this one
- (NSColor *)contrastingColor
{
	if ([self colorIsMedium]) {
		if ([self colorIsDark])
			return [NSColor whiteColor];
		else
			return [NSColor blackColor];
        
	} else {
		NSColor *rgbColor = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
		return [NSColor colorWithCalibratedRed:(1.0f - [rgbColor redComponent])
										 green:(1.0f - [rgbColor greenComponent])
										  blue:(1.0f - [rgbColor blueComponent])
										 alpha:1.0f];
	}
}

@end

@implementation NSColor (AIColorAdditions_HLS)

//Linearly adjust a color
#define cap(x) { if (x < 0) {x = 0;} else if (x > 1) {x = 1;} }
- (NSColor *)adjustHue:(CGFloat)dHue saturation:(CGFloat)dSat brightness:(CGFloat)dBrit
{
    CGFloat hue, sat, brit, alpha;
    
    [self getHue:&hue saturation:&sat brightness:&brit alpha:&alpha];
    
	//For some reason, redColor's hue is 1.0f, not 0.0f, as of Mac OS X 10.4.10 and 10.5.2. Therefore, we must normalize any multiple of 1.0 to 0.0. We do this by taking the remainder of hue ÷ 1.
	//hue = AIfmod(hue, 1.0f);
    
    hue += dHue;
    cap(hue);
    sat += dSat;
    cap(sat);
    brit += dBrit;
    cap(brit);
    
    return [NSColor colorWithCalibratedHue:hue saturation:sat brightness:brit alpha:alpha];
}

@end

@implementation NSColor (AIColorAdditions_RepresentingColors)

- (NSString *)hexString
{
    CGFloat 	red,green,blue;
    char	hexString[7];
    NSInteger		tempNum;
    NSColor	*convertedColor;
    
    convertedColor = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    [convertedColor getRed:&red green:&green blue:&blue alpha:NULL];
    
    tempNum = (red * 255.0f);
    hexString[0] = intToHex(tempNum / 16);
    hexString[1] = intToHex(tempNum % 16);
    
    tempNum = (green * 255.0f);
    hexString[2] = intToHex(tempNum / 16);
    hexString[3] = intToHex(tempNum % 16);
    
    tempNum = (blue * 255.0f);
    hexString[4] = intToHex(tempNum / 16);
    hexString[5] = intToHex(tempNum % 16);
    hexString[6] = '\0';
    
    return [NSString stringWithUTF8String:hexString];
}

//String representation: R,G,B[,A].
- (NSString *)stringRepresentation
{
    NSColor	*tempColor = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	CGFloat alphaComponent = [tempColor alphaComponent];
    
	if (alphaComponent == 1.0) {
		return [NSString stringWithFormat:@"%d,%d,%d",
                (int)([tempColor redComponent] * 255.0),
                (int)([tempColor greenComponent] * 255.0),
                (int)([tempColor blueComponent] * 255.0)];
        
	} else {
		return [NSString stringWithFormat:@"%d,%d,%d,%d",
                (int)([tempColor redComponent] * 255.0),
                (int)([tempColor greenComponent] * 255.0),
                (int)([tempColor blueComponent] * 255.0),
                (int)(alphaComponent * 255.0)];
	}
}

- (NSString *)CSSRepresentation
{
	CGFloat alpha = [self alphaComponent];
	if ((1.0 - alpha) >= 0.000001) {
		NSColor *rgb = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
		//CSS3 defines rgba() to take 0..255 for the color components, but 0..1 for the alpha component. Thus, we must multiply by 255 for the color components, but not for the alpha component.
		return [NSString stringWithFormat:@"rgba(%@,%@,%@,%@)",
                [NSString stringWithCGFloat:[rgb redComponent]   * 255.0f maxDigits:6],
                [NSString stringWithCGFloat:[rgb greenComponent] * 255.0f maxDigits:6],
                [NSString stringWithCGFloat:[rgb blueComponent]  * 255.0f maxDigits:6],
                [NSString stringWithCGFloat:alpha                         maxDigits:6]];
	} else {
		return [@"#" stringByAppendingString:[self hexString]];
	}
}

@end

@implementation NSString (AIColorAdditions_RepresentingColors)

- (NSColor *)representedColor
{
    CGFloat	r = 255, g = 255, b = 255;
    CGFloat	a = 255;
    
	const char *selfUTF8 = [self UTF8String];
	
	//format: r,g,b[,a]
	//all components are decimal numbers 0..255.
	if (!isdigit(*selfUTF8)) goto scanFailed;
	r = (CGFloat)strtoul(selfUTF8, (char **)&selfUTF8, /*base*/ 10);
    
	if(*selfUTF8 == ',') ++selfUTF8;
	else                 goto scanFailed;
    
	if (!isdigit(*selfUTF8)) goto scanFailed;
	g = (CGFloat)strtoul(selfUTF8, (char **)&selfUTF8, /*base*/ 10);
	if(*selfUTF8 == ',') ++selfUTF8;
	else                 goto scanFailed;
    
	if (!isdigit(*selfUTF8)) goto scanFailed;
	b = (CGFloat)strtoul(selfUTF8, (char **)&selfUTF8, /*base*/ 10);
	if (*selfUTF8 == ',') {
		++selfUTF8;
		a = (CGFloat)strtoul(selfUTF8, (char **)&selfUTF8, /*base*/ 10);
        
		if (*selfUTF8) goto scanFailed;
	} else if (*selfUTF8 != '\0') {
		goto scanFailed;
	}
    
    return [NSColor colorWithCalibratedRed:(r/255) green:(g/255) blue:(b/255) alpha:(a/255)] ;
scanFailed:
	return nil;
}

- (NSColor *)representedColorWithAlpha:(CGFloat)alpha
{
	//this is the same as above, but the alpha component is overridden.
    
    NSUInteger	r, g, b;
    
	const char *selfUTF8 = [self UTF8String];
	
	//format: r,g,b
	//all components are decimal numbers 0..255.
	if (!isdigit(*selfUTF8)) goto scanFailed;
	r = strtoul(selfUTF8, (char **)&selfUTF8, /*base*/ 10);
    
	if (*selfUTF8 != ',') goto scanFailed;
	++selfUTF8;
    
	if (!isdigit(*selfUTF8)) goto scanFailed;
	g = strtoul(selfUTF8, (char **)&selfUTF8, /*base*/ 10);
    
	if (*selfUTF8 != ',') goto scanFailed;
	++selfUTF8;
    
	if (!isdigit(*selfUTF8)) goto scanFailed;
	b = strtoul(selfUTF8, (char **)&selfUTF8, /*base*/ 10);
    
    return [NSColor colorWithCalibratedRed:(r/255) green:(g/255) blue:(b/255) alpha:alpha];
scanFailed:
	return nil;
}

@end

@implementation NSColor (AIColorAdditions_RandomColor)

+ (NSColor *)randomColor
{
	return [NSColor colorWithCalibratedRed:(arc4random() % 65536) / 65536.0f
	                                 green:(arc4random() % 65536) / 65536.0f
	                                  blue:(arc4random() % 65536) / 65536.0f
	                                 alpha:1.0f];
}
+ (NSColor *)randomColorWithAlpha
{
	return [NSColor colorWithCalibratedRed:(arc4random() % 65536) / 65536.0f
	                                 green:(arc4random() % 65536) / 65536.0f
	                                  blue:(arc4random() % 65536) / 65536.0f
	                                 alpha:(arc4random() % 65536) / 65536.0f];
}

@end

@implementation NSColor (AIColorAdditions_HTMLSVGCSSColors)

+ (id)colorWithHTMLString:(NSString *)str
{
	return [self colorWithHTMLString:str defaultColor:nil];
}

/*!
 * @brief Convert one or two hex characters to a float
 *
 * @param firstChar The first hex character
 * @param secondChar The second hex character, or 0x0 if only one character is to be used
 * @result The float value. Returns 0 as a bailout value if firstChar or secondChar are not valid hexadecimal characters ([0-9]|[A-F]|[a-f]). Also returns 0 if firstChar and secondChar equal 0.
 */
static CGFloat hexCharsToFloat(char firstChar, char secondChar)
{
	CGFloat				hexValue;
	NSUInteger		firstDigit;
	firstDigit = hexToInt(firstChar);
	if (firstDigit != -1) {
		hexValue = firstDigit;
		if (secondChar != 0x0) {
			int secondDigit = hexToInt(secondChar);
			if (secondDigit != -1)
				hexValue = (hexValue * 16.0f + secondDigit) / 255.0f;
			else
				hexValue = 0;
		} else {
			hexValue /= 15.0f;
		}
        
	} else {
		hexValue = 0;
	}
    
	return hexValue;
}

+ (id)colorWithHTMLString:(NSString *)str defaultColor:(NSColor *)defaultColor
{
	if (!str) return defaultColor;
    
	NSUInteger strLength = [str length];
	
	NSString *colorValue = str;
	
	if ([str hasPrefix:@"rgb"]) {
		NSUInteger leftParIndex = [colorValue rangeOfString:@"("].location;
		NSUInteger rightParIndex = [colorValue rangeOfString:@")"].location;
		if (leftParIndex == NSNotFound || rightParIndex == NSNotFound)
		{
			DDLog(@"+[NSColor(AIColorAdditions) colorWithHTMLString:] called with unrecognised color function (str is %@); returning %@", str, defaultColor);
			return defaultColor;
		}
		leftParIndex++;
		NSRange substrRange = NSMakeRange(leftParIndex, rightParIndex - leftParIndex);
		colorValue = [colorValue substringWithRange:substrRange];
		NSArray *colorComponents = [colorValue componentsSeparatedByString:@","];
		if ([colorComponents count] < 3 || [colorComponents count] > 4) {
			DDLog(@"+[NSColor(AIColorAdditions) colorWithHTMLString:] called with a color function with the wrong number of arguments (str is %@); returning %@", str, defaultColor);
			return defaultColor;
		}
		float red, green, blue, alpha = 1.0f;
		red = [[colorComponents objectAtIndex:0] floatValue];
		green = [[colorComponents objectAtIndex:1] floatValue];
		blue = [[colorComponents objectAtIndex:2] floatValue];
		if ([colorComponents count] == 4)
			alpha = [[colorComponents objectAtIndex:3] floatValue];
		return [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha];
	}
	
	if ((!strLength) || ([str characterAtIndex:0] != '#')) {
		//look it up; it's a colour name
		NSDictionary *colorValues = [self colorNamesDictionary];
		colorValue = [colorValues objectForKey:str];
		if (!colorValue) colorValue = [colorValues objectForKey:[str lowercaseString]];
		if (colorValue) {
			return colorValue;
		} else {
#if COLOR_DEBUG
			DDLog(@"+[NSColor(AIColorAdditions) colorWithHTMLString:] called with unrecognised color name (str is %@); returning %@", str, defaultColor);
#endif
			return defaultColor;
		}
	}
    
	//we need room for at least 9 characters (#00ff00ff) plus the NUL terminator.
	//this array is 12 bytes long because I like multiples of four. ;)
	enum { hexStringArrayLength = 12 };
	size_t hexStringLength = 0;
	char hexStringArray[hexStringArrayLength] = { 0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0, };
	{
		NSData *stringData = [str dataUsingEncoding:NSUTF8StringEncoding];
		hexStringLength = [stringData length];
		//subtract 1 because we don't want to overwrite that last NUL.
		memcpy(hexStringArray, [stringData bytes], MIN(hexStringLength, hexStringArrayLength - 1));
	}
	const char *hexString = hexStringArray;
    
	CGFloat		red,green,blue;
	CGFloat		alpha = 1.0f;
    
	//skip # if present.
	if (*hexString == '#') {
		++hexString;
		--hexStringLength;
	}
    
	if (hexStringLength < 3) {
#if COLOR_DEBUG
		DDLog(@"+[%@ colorWithHTMLString:] called with a string that cannot possibly be a hexadecimal color specification (e.g. #ff0000, #00b, #cc08) (string: %@ input: %@); returning %@", NSStringFromClass(self), colorValue, str, defaultColor);
#endif
		return defaultColor;
	}
    
	//long specification:  #rrggbb[aa]
	//short specification: #rgb[a]
	//e.g. these all specify pure opaque blue: #0000ff #00f #0000ffff #00ff
	BOOL isLong = hexStringLength > 4;
    
	//for a long component c = 'xy':
	//	c = (x * 0x10 + y) / 0xff
	//for a short component c = 'x':
	//	c = x / 0xf
    
	char firstChar, secondChar;
	
	firstChar = *(hexString++);
	secondChar = (isLong ? *(hexString++) : 0x0);
	red = hexCharsToFloat(firstChar, secondChar);
    
	firstChar = *(hexString++);
	secondChar = (isLong ? *(hexString++) : 0x0);
	green = hexCharsToFloat(firstChar, secondChar);
    
	firstChar = *(hexString++);
	secondChar = (isLong ? *(hexString++) : 0x0);
	blue = hexCharsToFloat(firstChar, secondChar);
    
	if (*hexString) {
		//we still have one more component to go: this is alpha.
		//without this component, alpha defaults to 1.0 (see initialiser above).
		firstChar = *(hexString++);
		secondChar = (isLong ? *hexString : 0x0);
		alpha = hexCharsToFloat(firstChar, secondChar);
	}
    
	return [self colorWithCalibratedRed:red green:green blue:blue alpha:alpha];
}

@end

@implementation NSColor (AIColorAdditions_ObjectColor)

+ (NSString *)representedColorForObject: (id)anObject withValidColors: (NSArray *)validColors
{
	NSArray *validColorsArray = validColors;
    
	if (!validColorsArray || [validColorsArray count] == 0) {
		if (!defaultValidColors) {
			defaultValidColors = VALID_COLORS_ARRAY;
		}
		validColorsArray = defaultValidColors;
	}
    
	return [validColorsArray objectAtIndex:([anObject hash] % ([validColorsArray count]))];
}

@end

//Convert hex to an int
int hexToInt(char hex)
{
    if (hex >= '0' && hex <= '9') {
        return (hex - '0');
    } else if (hex >= 'a' && hex <= 'f') {
        return (hex - 'a' + 10);
    } else if (hex >= 'A' && hex <= 'F') {
        return (hex - 'A' + 10);
    } else {
        return -1;
    }
}

//Convert int to a hex
char intToHex(NSInteger digit)
{
    if (digit > 9) {
		if (digit <= 0xf) {
			return ('a' + digit - 10);
		}
    } else if (digit >= 0) {
        return ('0' + digit);
    }
    
	return '\0'; //NUL
}