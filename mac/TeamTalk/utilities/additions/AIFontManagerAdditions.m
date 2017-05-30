#import "AIFontManagerAdditions.h"

@implementation NSFontManager (AIFontManagerAdditions)

- (NSFont *)fontWithFamilyInsensitively:(NSString *)name traits:(NSFontTraitMask)fontTraitMask weight:(NSInteger)weight size:(CGFloat)size
{
	NSFont			*theFont = nil;
	NSFontManager	*fontManager = [NSFontManager sharedFontManager];
    
	@try
	{
		theFont = [fontManager fontWithFamily:name traits:fontTraitMask weight:weight size:size];
		theFont = [fontManager convertFont:theFont toHaveTrait:fontTraitMask];
	}
	@catch (NSException *localException)
	{
		theFont = nil;
	}
    
	if (!theFont) {
		for (NSString *thisName in [fontManager availableFontFamilies]) {
			if ([thisName caseInsensitiveCompare:name] == NSOrderedSame) {
				@try
				{
					theFont = [fontManager fontWithFamily:thisName traits:fontTraitMask weight:weight size:size];
					theFont = [fontManager convertFont:theFont toHaveTrait:fontTraitMask];
					break;
				}
				@catch (NSException *localException)
				{
					theFont = nil;
				}
			}
		}
	}
    
	return theFont;
}

@end