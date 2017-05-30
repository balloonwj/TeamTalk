@interface NSFontManager (AIFontManagerAdditions)

//find a font by family name, using case-insensitive matching.
- (NSFont *)fontWithFamilyInsensitively:(NSString *)name traits:(NSFontTraitMask)fontTraitMask weight:(NSInteger)weight size:(CGFloat)size;

@end