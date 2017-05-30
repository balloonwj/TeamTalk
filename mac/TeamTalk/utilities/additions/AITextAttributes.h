
#define AIBodyColorAttributeName	@"AIBodyColor"

/*!
 * @class AITextAttributes
 * @brief Encapsulates attributes that can be applied to a block of text
 *
 * Allows easy modification of various attributes which can be applied to a block of texxt.  To use, simply use its -[AITextAttributes dictionary] method to return an <tt>NSDictionary</tt> suitable for passing to <tt>NSAttributedString</tt> or the like.
 */
@interface AITextAttributes : NSObject<NSCopying> {
    NSMutableDictionary	*dictionary;
    
    NSString			*fontFamilyName;
    NSFontTraitMask		fontTraitsMask;
    NSInteger					fontSize;
}

/*!
 * @brief Create a new <tt>AITextAttributes</tt> instance
 *
 * @param inFamilyName The family name for font attributes
 * @param inTraits	<tt>NSFontTraitMask</tt> of initial traits.  Pass 0 for no traits.
 * @param inSize Font point size
 * @return The newly created (autoreleased) <tt>AITextAttributes</tt> object
 */
+ (id)textAttributesWithFontFamily:(NSString *)inFamilyName traits:(NSFontTraitMask)inTraits size:(NSInteger)inSize;

/*!
 * @brief Create a new <tt>AITextAttributes</tt> instance from a dictionary of attributes
 *
 * @param inAttributes A dictionary of attributes such as is returned by <tt>NSAttributedString</tt>'s attributesAtIndex:effectiveRange:
 * @return The newly created (autoreleased) <tt>AITextAttributes</tt> object
 */
+ (id)textAttributesWithDictionary:(NSDictionary *)inAttributes;

/*!
 * @brief Return the dictionary of attributes
 *
 * Return the dictionary of attributes of this <tt>AITextAttributes</tt> suitable for passing to <tt>NSAttributedString</tt> or the like.
 * @return The <tt>NSDictionary</tt> of attributes
 */
- (NSDictionary *)dictionary;

/*!
 * @brief Reset the font-related attributes.
 *
 * This sets to default values font family, font size, foreground color, background color, and language value.
 */
- (void)resetFontAttributes;

/*!
 * @brief Set the font family
 *
 * Set the font family
 * @param inFamilyName The family name for font attributes
 */
- (void)setFontFamily:(NSString *)inFamilyName;

/*!
 * @brief Font family
 */
- (NSString *)fontFamily;

/*!
 * @brief Set the font size
 *
 * Set the font size
 * @param inSize Font point size
 */
- (void)setFontSize:(NSInteger)inSize;

- (NSInteger)fontSize;

/*!
 * @brief Add a trait to the current mask
 *
 * Add an <tt>NSFontTraitMask</tt> to the current mask of traits
 * @param inTrait The <tt>NSFontTraitMask</tt> to add
 */
- (void)enableTrait:(NSFontTraitMask)inTrait;

/*!
 * @brief Remove a trait from the current mask
 *
 * Remove an <tt>NSFontTraitMask</tt> from the current mask of traits
 * @param inTrait The <tt>NSFontTraitMask</tt> to remove
 */
- (void)disableTrait:(NSFontTraitMask)inTrait;

- (NSFontTraitMask)traits;

/*!
 * @brief Set the underline attribute
 *
 * Set the underline attribute
 * @param inUnderline A BOOL of the new underline attribute
 */
- (void)setUnderline:(BOOL)inUnderline;

- (BOOL)underline;
/*!
 * @brief Set the strikethrough attribute
 *
 * Set the strikethrough attribute
 * @param inStrikethrough A BOOL of the new strikethrough attribute
 */
- (void)setStrikethrough:(BOOL)inStrikethrough;

- (BOOL)strikethrough;
/*!
 * @brief Set the subscript attribute
 *
 * Set the subscript attribute
 * @param inSubscript A BOOL of the new subscript attribute
 */
- (void)setSubscript:(BOOL)inSubscript;

/*!
 * @brief Set the superscript attribute
 *
 * Set the superscript attribute
 * @param inSuperscript A BOOL of the new superscript attribute
 */
- (void)setSuperscript:(BOOL)inSuperscript;

/*!
 * @brief Set the text foreground color
 *
 * Set  the text foreground color
 * @param inColor A <tt>NSColor</tt> of the new text foreground color
 */
- (void)setTextColor:(NSColor *)inColor;

- (NSColor *)textColor;

/*!
 * @brief Set the text background color
 *
 * Set the text background color.  This is drawn only behind the text.
 * @param inColor A <tt>NSColor</tt> of the new text background color
 */
- (void)setTextBackgroundColor:(NSColor *)inColor;

- (NSColor *)textBackgroundColor;

/*!
 * @brief Set the background color
 *
 * Set the background color which should be used for the entire rectangle containing the text. It is stored under the key   It is stored under the key <b>AIBodyColorAttributeName</b>. It is the responsibility of drawing code elsewhere to make use of this value if desired.
 * @param inColor A <tt>NSColor</tt> of the new background color
 */
- (void)setBackgroundColor:(NSColor *)inColor;

- (NSColor *)backgroundColor;

/*!
 * @brief Set a link attribute
 *
 * Set a URL to be associated with these attributes.
 * @param inURL An <tt>NSURL</tt> of the link URL
 */
- (void)setLinkURL:(NSURL *)inURL;

/*!
 * @brief Set the language value
 *
 * No relevance to normal display; may be used for internal bookkeeping or the like
 * @param inLanguageValue The language value
 */
- (void)setLanguageValue:(id)inLanguageValue;

/*!
 * @brief Retrieve the language value
 *
 * No relevance to normal display; may be used for internal bookkeeping or the like
 */
- (id)languageValue;

- (void)setWritingDirection:(NSWritingDirection)inDirection;

@end