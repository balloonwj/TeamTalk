
@interface NSDictionary (AIColorAdditions_RGBTxtFiles)

/*!	@brief	Loads an emacs-style rgb.txt file as an \c NSDictionary.
 *
 *	@par	See /usr/share/emacs/(some version)/etc/rgb.txt for an example of such a file.
 *
 *	@par	The pathname does not need to end in 'rgb.txt', but it must be a file in UTF-8 encoding.
 *
 *	@par	The keys in the dictionary are the color names from the file, <em>converted to lowercase</em>.
 *
 *	@param	path	The pathname of the file to read.
 *	@return	A dictionary mapping color names to RGB <code>NSColor</code>s.
 */
+ (id)dictionaryWithContentsOfRGBTxtFile:(NSString *)path;

@end

@interface NSColor (AIColorAdditions_RGBTxtFiles)

/*!	@brief	Loads the rgb.txt file from the system installation of emacs and returns a dictionary created from it.
 *
 *	@par	This method loads the file at /usr/share/emacs/ * /etc/rgb.txt. It is not guaranteed to load any specific file matching that glob, but it will load only one.
 *
 *	@return	A dictionary mapping color names (all of which are lowercase) to RGB <code>NSColor</code>s.
 */
+ (NSDictionary *)colorNamesDictionary;

@end

@interface NSColor (AIColorAdditions_Comparison)

/*!	@brief	Returns whether two RGB colors are equal.
 *
 *	@par	This method assumes that the receiver and the other color are both in an RGB color-space. If they're not, you will get an exception.
 *
 *	@par	The alpha component is considered in the comparison.
 *
 *	@return	\c YES if the two colors are equal; \c NO if they're not.
 */
- (BOOL)equalToRGBColor:(NSColor *)inColor;

@end

@interface NSColor (AIColorAdditions_DarknessAndContrast)

/*!	@brief	Returns whether a color is dark.
 *
 *	@par	This method measures the brightness of the receiver using <code>-[NSColor brightnessComponent]</code>, and considers it dark if that value < 0.5.
 *
 *	@par	A color whose brightness is exactly 0.5 is not considered dark.
 *
 *	@return	\c YES if the receiver is dark; NO if it isn't.
 */
- (BOOL)colorIsDark;
/*!	@brief	Returns whether a color is medium in brightness.
 *
 *	@par	This method measures the brightness of the receiver using <code>-[NSColor brightnessComponent]</code>, and considers it medium if 0.35 < that value < 0.65.
 *
 *	@par	A color whose brightness is exactly 0.35 or 0.65 is not considered medium.
 *
 *	@return	\c YES if the receiver is medium in brightness; NO if it isn't.
 */
- (BOOL)colorIsMedium;
/*!	@brief	Returns a new color, darker than the receiver by a fixed amount.
 *
 *	@par	This method subtracts \a amount from the brightness of the receiver (as measured using <code>-[NSColor brightnessComponent]</code>), and returns a new \c NSColor created with the unchanged other component values and the new brightness value.
 *
 *	@par	This method does not adjust the saturation of the receiver. For a method that does, see <code>darkenAndAdjustSaturationBy:</code>.
 *
 *	@param	amount The amount (greater than 0.0 and at most 1.0) to subtract from the receiver's brightness.
 *	@return	A new, darker color, in the calibrated-RGB color space.
 */
- (NSColor *)darkenBy:(CGFloat)amount;
/*!	@brief	Returns a new color, darker than the receiver and more saturated, both by a single fixed amount.
 *
 *	@par	This method subtracts \a amount from the brightness of the receiver (as measured using <code>-[NSColor brightnessComponent]</code>) and adds \a amount to its saturation (as measured using <code>-[NSColor saturationComponent]</code>), and returns a new \c NSColor created with the unchanged other component values and the new saturation and brightness values.
 *
 *	@par	This method increases the saturation of the receiver. For a method that doesn't, see <code>darkenBy:</code>.
 *
 *	@par	You would use this method when you want to darken a color while preserving the “color” apparent to the user. The usual reason to do this is to create two ends of a gradient from a single input color.
 *
 *	@param	amount The amount (greater than 0.0 and at most 1.0) to subtract from the receiver's brightness and add to the receiver's saturation.
 *	@return	A new, darker, more saturated color, in the calibrated-RGB color space.
 */
- (NSColor *)darkenAndAdjustSaturationBy:(CGFloat)amount;
/*!	@brief	Inverts a color's brightness without affecting the hue.
 *
 *	@par	The naïve method for inverting a color is to subtract all of its color components from 1.0, but this moves colors not in the center of the color wheel to the opposite side of the wheel—for example, it changes orange into light blue. In other words, it inverts not the brightness (except for shades of gray), but the hue.
 *
 *	@par	This method, on the other hand, inverts the brightness of a color without moving it across the color wheel. For example, dark orange becomes light orange, and vice versa.
 *
 *	@return	The inverted color, in the calibrated-RGB color space.
 */
- (NSColor *)colorWithInvertedLuminance;
/*!	@brief	Returns a color that contrasts well with the receiver.
 *
 *	@par	If the receiver is medium (see \c colorIsMedium), this method returns white if the receiver is dark (see \c colorIsDark), or black if it isn't. If the receiver is not medium, this method inverts the receiver and returns the result.
 *
 *	@return	A new color.
 */
- (NSColor *)contrastingColor;

@end

/*!	@brief	Computes the hue, saturation, and brightness of a given red, green, and blue triplet.
 *
 *	@par	This function exists to help you compute HSL values without first creating an \c NSColor instance. It also gets the job done in only one function call, rather than at least two Objective-C messages.
 *
 *	@par	Hue is expressed as a fraction of a circle. Red is any multiple of 1 (a whole circle), and will be returned as 0.
 *
 *	@param	hue	A pointer to a \c float. If you don't pass \c NULL, this function will assign the hue component here.
 *	@param	saturation	A pointer to a \c float. If you don't pass \c NULL, this function will assign the saturation component here.
 *	@param	luminance	A pointer to a \c float. If you don't pass \c NULL, this function will assign the luminance (brightness) component here.
 *	@param	r	The red component of the color to convert.
 *	@param	g	The green component of the color to convert.
 *	@param	b	The blue component of the color to convert.
 */
void getHueLuminanceSaturationFromRGB(CGFloat *hue, CGFloat *luminance, CGFloat *saturation, CGFloat r, CGFloat g, CGFloat b);
/*!	@brief	Computes the red, green, and blue of a given hue, saturation, and brightness triplet.
 *
 *	@par	This function exists to help you compute RGB values without first creating an \c NSColor instance. It also gets the job done in only one function call, rather than at least two Objective-C messages.
 *
 *	@par	Hue is expressed as a fraction of a circle. Red is any multiple of 1 (a whole circle), such as 0.
 *
 *	@param	r	A pointer to a \c float. If you don't pass \c NULL, this function will assign the red component here.
 *	@param	g	A pointer to a \c float. If you don't pass \c NULL, this function will assign the green component here.
 *	@param	b	A pointer to a \c float. If you don't pass \c NULL, this function will assign the blue component here.
 *	@param	hue	The hue component of the color to convert.
 *	@param	saturation	The saturation component of the color to convert.
 *	@param	luminance	The luminance (brightness) component of the color to convert.
 */
void getRGBFromHueLuminanceSaturation(CGFloat *r, CGFloat *g, CGFloat *b, CGFloat hue, CGFloat luminance, CGFloat saturation);

@interface NSColor (AIColorAdditions_HLS)

/*!	@brief	Returns a new color with hue, saturation, and brightness adjusted by given deltas.
 *
 *	@par	Each of the deltas will be added to that component of the receiver; thus, you may subtract by passing a negative delta.
 *
 *	@param	dHue	The hue delta.
 *	@param	dSat	The saturation delta.
 *	@param	dBrit	The brightness delta.
 *	@return	The adjusted color, in the calibrated-RGB color space.
 */
- (NSColor *)adjustHue:(CGFloat)dHue saturation:(CGFloat)dSat brightness:(CGFloat)dBrit;

@end

@interface NSColor (AIColorAdditions_RepresentingColors)

/*!	@brief	Returns the red, green, and blue components of the receiver as a hexadecimal string.
 *
 *	@par	Each component is represented by two hexadecimal digits; thus, the result will always be six characters long.
 *
 *	@par	Digits greater than 9 are lowercase.
 *
 *	@par	This method assumes that the receiver is in an RGB color space. If it isn't, you will get an exception.
 *
 *	@return	The hexadecimal string representing the receiver.
 */
- (NSString *)hexString;

/*!	@brief	Returns the red, green, blue, and alpha components of the receiver as a triplet of decimal numbers from 0 to 255.
 *
 *	@par	The alpha component is only included in the result string if it is not 1. If the alpha component <em>is</em> 1, it will be omitted from the result.
 *
 *	@par	The three or four numbers are separated by commas, with no spaces.
 *
 *	@par	This method assumes that the receiver is in an RGB color space. If it isn't, you will get an exception.
 *
 *	@par	To convert the result from this method back to an \c NSColor, use <code>-[NSString(AIColorAdditions) representedColor]</code>.
 *
 *	@return	The decimal string representing the receiver.
 */
- (NSString *)stringRepresentation;

/*!	@brief	Returns the red, green, blue, and alpha components of the receiver as a CSS color literal.
 *
 *	@par	If the receiver's alpha component is not 1, the literal will use CSS' <code>rgba()</code> function. If it is 1, the literal will be an HTML-style hex literal (e.g., <code>#ffffff</code>).
 *
 *	@par	The returned string is suitable for splicing into CSS code; for example, <code>[NSString stringWithFormat:@"color: %@;", [myColor CSSRepresentation]]</code>.
 *
 *	@return	A string of a CSS literal representing the receiver.
 */
- (NSString *)CSSRepresentation;

@end

/*! @brief	Interprets a hexadecimal digit represented as a character.
 *
 *	@par	\a hex must be ASCII (including UTF-8 and all variants of ISO-8859).
 *
 *	@par	If \a hex is not a valid hexadecimal character, this function returns -1. Remember to check its return value.
 *
 *	@return	The number represented by the digit, or -1.
 */
int hexToInt(char hex);
/*!	@brief	Converts a digit to a character representing a hexadecimal digit.
 *
 *	@par	\a digit must be in the range 0 to 15, inclusive. If it isn't, the return value is NUL (<code>'\0'</code>).
 *
 *	@return	A lowercase character, encoded in ASCII, representing the number in hexadecimal.
 */
char intToHex(NSInteger digit);

@interface NSString (AIColorAdditions_RepresentingColors)

/*!	@brief	Interprets a series of three or four decimal numbers as an RGB or RGBA color.
 *
 *	@par	The numbers must be separated by commas, and must range from 0 to 255, inclusive. Their order is red, green, blue, alpha.
 *
 *	@par	This method returns \c nil if the string does not contain exactly three or four numbers, or has anything before or after the numbers (except that whitespace before the first number is skipped).
 *
 *	@par	To create a string suitable for sending this message to, call <code>-[NSColor(AIColorAdditions) stringRepresentation].
 *
 *	@return	A color in the calibrated RGB color space, or \c nil.
 */
- (NSColor *)representedColor;
/*!	@brief	Interprets a series of three or four decimal numbers as an RGB color, and overrides the alpha component.
 *
 *	@par	The numbers must be separated by commas, and must range from 0 to 255, inclusive. Their order is red, green, blue, alpha.
 *
 *	@par	Unlike <code>-representedColor</code>, this method forces a specific alpha value in the returned color, ignoring (if it's present) the fourth value in the receiver.
 *
 *	@par	The numbers must be separated by commas, and must range from 0 to 255, inclusive.
 *
 *	@par	This method returns \c nil if the string does not contain exactly three or four numbers, or has anything before or after the numbers (except that whitespace before the first number is skipped).
 *
 *	@par	To create a string suitable for sending this message to, call <code>-[NSColor(AIColorAdditions) stringRepresentation].
 *
 *	@return	A color in the calibrated-RGB color space, or \c nil.
 */
- (NSColor *)representedColorWithAlpha:(CGFloat)alpha;

@end

@interface NSColor (AIColorAdditions_RandomColor)

/*!	@brief	Return a color with random red, green, and blue, with its alpha component set to 1.
 *
 *	@par	You do not need to seed a PRNG before calling this method.
 *
 *	@par	If you want the alpha to be random as well, use <code>+randomColorWithAlpha</code> instead.
 *
 *	@return	A random color in the calibrated-RGB color space.
 */
+ (NSColor *)randomColor;
/*!	@brief	Return a color with random red, green, blue, and alpha.
 *
 *	@par	You do not need to seed a PRNG before calling this method.
 *
 *	@par	If you want the alpha to always be 1 as well, use <code>+randomColor</code> instead. You can change the alpha to another static value using <code>-[NSColor colorWithAlphaComponent:]</code>.
 *
 *	@return	A random color in the calibrated-RGB color space.
 */
+ (NSColor *)randomColorWithAlpha;

@end

@interface NSColor (AIColorAdditions_HTMLSVGCSSColors)

/*!	@brief	Interpret an HTML color literal, with a specific fallback in case of a syntax error.
 *
 *	@par	As an extension, this method supports alpha. If \a str contains four or eight characters, the last quarter of the string is the alpha component.
 *
 *	@par	If \a str is shorter than six characters, this method will imagine zeros to fill the shortfall, as WebKit does. For example, “#ff000” (five characters) becomes “#ff0000” (six characters). This does not apply to the abbreviated syntax: a two-character string is illegal.
 *
 *	@par	If \a str is not a valid literal, this method returns \c nil.
 *
 *	@par	This method does not support CSS' <code>rgba()</code> function; therefore, we do not recommend using it as the inverse of <code>-CSSRepresentation</code>.
 *
 *	@param	str	The string to interpret as an HTML color literal.
 *	@return	A color in the calibrated-RGB color space, or \c nil.
 */
+ (id)colorWithHTMLString:(NSString *)str;
/*!	@brief	Interpret an HTML color literal, with a specific fallback in case of a syntax error.
 *
 *	@par	As an extension, this method supports alpha. If \a str contains four or eight characters, the last quarter of the string is the alpha component.
 *
 *	@par	If \a str is shorter than six characters, this method will imagine zeros to fill the shortfall, as WebKit does. For example, “#ff000” (five characters) becomes “#ff0000” (six characters). This does not apply to the abbreviated syntax: a two-character string is illegal.
 *
 *	@par	If \a str is not a valid literal, this method returns \a defaultColor. You may pass \c nil for \a defaultColor.
 *
 *	@par	This method does not support CSS' <code>rgba()</code> function; therefore, we do not recommend using it as the inverse of <code>-CSSRepresentation</code>.
 *
 *	@par	If it creates the color from the input string, this method will use the calibrated-RGB color space. If, instead, it returns \a defaultColor, it will not convert it to the calibrated-RGB color space for you: you will get back whatever you passed in.
 *
 *	@param	str	The string to interpret as an HTML color literal.
 *	@param	defaultColor	The color to return if \a str is invalid. May be \c nil.
 *	@return	A color: either one created from \a str, or \a defaultColor.
 */
+ (id)colorWithHTMLString:(NSString *)str defaultColor:(NSColor *)defaultColor;

@end

@interface NSColor (AIColorAdditions_ObjectColor)

/*!	@brief	Compute a colour for an object based on it's hash, represnted in an HTML color name from within a list of valid colours.
 *
 *	@param	anObject an object for which to compute a matching colour.
 *	@param	validColors an NSArray containing a list of valid colours to return. If nil or empty, the colour will be chosen from a default list.
 *
 *	@return	An NSString containing an HTML colour name.
 */
+ (NSString *)representedColorForObject: (id)anObject withValidColors: (NSArray *)validColors;

@end