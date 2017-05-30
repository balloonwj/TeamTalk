extern NSString *AIFontFamilyAttributeName;
extern NSString *AIFontSizeAttributeName;
extern NSString *AIFontWeightAttributeName;
extern NSString *AIFontStyleAttributeName;

/*!
 * @category NSMutableAttributedString(AIAttributedStringAdditions)
 * @brief Additions to NSMutableAttributedString
 *
 * These methods add string replacement, <tt>NSData</tt> conversion, color adjustment, and more.
 */
@interface NSMutableAttributedString (AIAttributedStringAdditions)
/*!
 * @brief Append a string and set its attributes
 *
 * Appends <b>aString</b>, setting its attributes to <b>attributes</b>
 * @param aString The string to append
 * @param attributes The attributes to use
 */
- (void)appendString:(NSString *)aString withAttributes:(NSDictionary *)attributes;

/*!
 * @brief Find and replace on an attributed string
 *
 * Operation is identical to <tt>NSMutableString</tt>'s method of the same name.  The replacement string has the attributes of the string it replaced.
 * @param target The string to search for
 * @param replacement The string with which to replace <b>target</b>
 * @param opts Search options, as with NSMutableString's method
 * @param searchRange The range in which to search
 * @return Returns the number of replacements made
 */
- (NSUInteger)replaceOccurrencesOfString:(NSString *)target withString:(NSString*)replacement options:(NSStringCompareOptions)opts range:(NSRange)searchRange;

/*!
 * @brief Find and replace on an attributed string setting the attributes of the replacements
 *
 * Operation is identical to <tt>NSMutableString</tt>'s method of the same name.  The replacement string has the specified attributes.
 * @param target The string to search for
 * @param replacement The string with which to replace <b>target</b>
 * @param attributes The attributes to apply to <b>replacement</b> for each replacement
 * @param opts Search options, as with NSMutableString's method
 * @param searchRange The range in which to search
 * @return Returns the number of replacements made
 */
- (NSUInteger)replaceOccurrencesOfString:(NSString *)target withString:(NSString*)replacement attributes:(NSDictionary*)attributes options:(NSStringCompareOptions)opts range:(NSRange)searchRange;

/*!
 * @brief Apply color adjustments for a background
 *
 * Adjust all colors in the attributed string so they are visible on the specified background
 * @param backgroundColor The background color
 */
- (void)adjustColorsToShowOnBackground:(NSColor *)backgroundColor;

/*!
 * @brief Apply color adjustments for a background
 *
 * Adjust all colors in the attributed string so they are visible on the background, adjusting brightness in a manner proportional to the original background
 * @param backgroundColor The background color
 */
- (void)adjustColorsToShowOnBackgroundRelativeToOriginalBackground:(NSColor *)backgroundColor;

/*!
 * @brief Apply link appearance attributes where appropriate
 *
 * Sets color and underline attributes for any areas with NSLinkAttributeName set
 */
- (void)addFormattingForLinks;

/*!
 * @brief Convert attachments to strings
 *
 * Generate an NSAttributedString without attachments by substituting their string value if possible
 * (if the attachment responds to &#64;selector(string)), and if not, substituting a characteristic string.
 * @param inPlaceholder The string to use in place of attachments if a string value can not be found
 */
- (void)convertAttachmentsToStringsUsingPlaceholder:(NSString *)inPlaceholder;
@end

/*!
 * @category NSData(AIAppleScriptAdditions)
 * @brief Adds the ability to obtain an <tt>NSAttributedString</tt> from data.
 *
 * This category on <tt>NSData</tt> complements a method in the NSAttributedString(AIAttributedStringAdditions) category.
 */
@interface NSData (AIAttributedStringAdditions)

/*!
 * @brief Return an <tt>NSAttributedString</tt> from this data
 *
 * Return an <tt>NSAttributedString</tt> from this data. The data should have been created via -[NSAttributedString dataRepresentation].
 * @return An <tt>NSAttributedString</tt>
 */
- (NSAttributedString *)attributedString;
@end

@interface NSAttributedString (AIAttributedStringAdditions)
/*!
 *	@brief Returns the set of \c NSAttributedString attributes that can be represented in CSS by \c +CSSStringForTextAttributes:.
 *	@return An \c NSSet.
 *
 */
+ (NSSet *)CSSCapableAttributesSet;

/*!
 *	@brief Create a string of CSS attributes for AppKit text attributes.
 *
 *	Methods used by this method:
 -[NSColor  CSSRepresentation]: Returns color name when color space is named; else, # + hexString
 -[NSShadow CSSRepresentation]: Color, space, offset, space, blur radius
 -[NSCursor CSSRepresentation]: Cursor name
 -[NSFont   CSSRepresentation]: [Font weight, space, ]size, space, family(?) name (name in quotes if >1 words); example: @"12pt \"Lucida Grande\""
 
 Not currently used:
 -[NSURL    CSSRepresentation]: &#64;url
 -[NSString CSSRepresentation]: Quoted form, unless it's a URL, in which case &#64;url
 -[NSValue  CSSRepresentation]: If NSRect, &#64;"top right bottom left". Else, nil.
 
 Note that NSLinkAttributeName and NSAttachmentAttributeName will not be included in the CSS. Those must be implemented as HTML (\<a\> and \<img\>).
 
 Attribute                            CSS property
 NSFontAttributeName                  font             (use -CSSRepresentation)
 NSForegroundColorAttributeName       color            (use -CSSRepresentation)
 NSBackgroundColorAttributeName       background-color (use -CSSRepresentation)
 NSStrikethroughStyleAttributeName    text-decoration
 NSUnderlineStyleAttributeName        text-decoration
 NSSuperscriptAttributeName           vertical-align
 NSShadowAttributeName                text-shadow      (use -CSSRepresentation)
 NSCursorAttributeName                cursor           (use -CSSRepresentation)
 *
 *	@return A \c NSString of CSS code.
 */
+ (NSString *)CSSStringForTextAttributes:(NSDictionary *)attrs;

/*!
 * @brief Determine the height needed to display an NSAttributedString with certain attributes
 *
 * Returns the height which a string with <b>attributes</b> will require for drawing purposes
 * @param attributes An <tt>NSDictionary</tt> of attributes
 * @return The needed height, as a float
 */
+ (CGFloat)stringHeightForAttributes:(NSDictionary *)attributes;

/*!
 * @brief Determine the height needed for display at a width
 *
 * Returns the height need to display at the passed width
 * @param width The available width for display
 * @return The needed height, as a float
 */
- (CGFloat)heightWithWidth:(CGFloat)width;

/*!
 * @brief Encode to <tt>NSData</tt>
 *
 * Archives the <tt>NSAttributedString</tt> and returns <tt>NSData</tt> suitable for storage
 * @return The attributed string represented as <tt>NSData</tt>
 */
- (NSData *)dataRepresentation;

/*!
 * @brief Obtain an <tt>NSAttributedString</tt> from encoded data
 *
 * Retrieves an <tt>NSAttributedString</tt> from <tt>NSData</tt> created with -[NSAttributedString dataRepresentation]
 * @param inData The source <tt>NSData</tt>
 * @return The decoded <tt>NSAttributedString</tt>
 */
+ (NSAttributedString *)stringWithData:(NSData *)inData;

/*!
 * @brief Generate an NSAttributedString without attachments
 *
 * Generate an NSAttributedString without attachments by substituting their string value if possible
 * (if the attachment responds to &#64;selector(string)), and if not, substituting a characteristic string.
 * @return An <tt>NSAttributedString</tt> without attachments; it may be identical to the original object.
 */
- (NSAttributedString *)attributedStringByConvertingAttachmentsToStrings;

/*!
 * @brief Generate an NSAttributedString without links
 *
 * This method replaces each link from the receiver with “title (URI)” in the result.
 *
 * @return An autoreleased copy of the receiver with each link expanded to the title followed by its URI.
 */
- (NSAttributedString *)attributedStringByConvertingLinksToStrings;

/*!
 * @brief Generate an NSAttributedString without links
 *
 * This method replaces each link from the receiver with its URI in the result.
 *
 * @return An autoreleased copy of the receiver with each link expanded to its URI.
 */
- (NSAttributedString *)attributedStringByConvertingLinksToURLStrings;

/*!
 * @brief Create a new NSAttributedString, apply link appearance attributes where appropriate
 *
 * Sets color and underline attributes for any areas with NSLinkAttributeName set and returns the resulting <tt>NSAttributedString</tt>
 * @return A formatted <tt>NSAttributedString</tt>
 */
- (NSAttributedString *)stringByAddingFormattingForLinks;

/*!
 * @brief Create a new NSAttributedString from an NSString
 *
 * @return An autoreleased <tt>NSAttributedString</tt>.
 */
+ (NSAttributedString *)stringWithString:(NSString *)inString;

/*!	@brief	Create a new NSAttributedString from an NSString and a URL.
 *
 *	@param	inString	The string that will be the hot text.
 *	@param	link	An NSURL or NSString representing an absolute URL. This method will convert the object to an NSURL if necessary.
 *	@throws	NSInvalidArgumentException	\a inString or \a link is \c nil.
 *	@return	An autoreleased \c NSAttributedString.
 */
+ (NSAttributedString *)attributedStringWithLinkLabel:(NSString *)inString linkDestination:(id)inLink;

/*!	@brief	Create a new NSAttributedString containing a hyperlink.
 *
 *	@par	It is legal, though insensible, to pass an empty \a linkRange.
 *
 *	@param	inString	The string that will contain the hot text.
 *	@param	linkRange	The range defining the substring of \a inString to linkify.
 *	@param	link	An NSURL or NSString representing an absolute URL. This method will convert the object to an NSURL if necessary.
 *	@throws	NSInvalidArgumentException	\a inString or \a link is \c nil, or \a linkRange falls outside the extent of \a inString.
 *	@return	An autoreleased \c NSAttributedString.
 */
+ (NSAttributedString *)attributedStringWithString:(NSString *)inString linkRange:(NSRange)linkRange linkDestination:(id)inLink;

@end
