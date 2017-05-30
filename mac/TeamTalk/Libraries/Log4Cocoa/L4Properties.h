// For copyright & license, see LICENSE.

#import <Foundation/Foundation.h>

/**
 *Defines the name for the no conversion pattern exception
 * This exception is thrown if you try to use an L4PatternLayout before setting its conversion pattern
 */
extern NSString* const L4PropertyMissingException;

/**
 * The L4Properties class provides a dictionary like interface to properties used to configure the logging system. Even
 * though these properties would typically be read in from a file, they can also be set from an NSDictionary.
 */
@interface L4Properties : NSObject

/**
 * Returns an empty properties instance.
 * @return the newly created, empty properties instance.
 */
+ (instancetype)properties;

/**
 * Creates and returns a new instance, reading in properties from the specified file.
 * @param aName the name of the file containing the properties to use.
 * @return the newly created, configured properties instance.
 */
+ (instancetype)propertiesWithFileName:(NSString *) aName;

/**
 * Creates and returns a new instance, using the supplied dictionary for the property values.
 * @param aProperties the dictionary containing the properties to use.
 * @return the newly created, configured properties instance.
 */
+ (instancetype)propertiesWithProperties:(NSDictionary *) aProperties;

/**
 * Returns all the keys in this property list.
 * @return an array of all the keys in this property list.
 */
- (NSArray *)allKeys;

/**
 * Accessor for the int value of the number of entries in this collection.
 * @return the int value of the number of entries in this collection.
 */
- (NSUInteger)count;

/**
 * This method initializes a new instance of this class with the specified file path.
 * @param aName the file path of the properties file you want to read from.
 * @return An initialized instance of this class.
 */
- (id)initWithFileName:(NSString *)aName;

/**
 * This method initializes a new instance of this class with the specified dictionary.
 * @param aProperties an initialized dictionary that contains the properties you want.
 * @return An initialized instance of this class.
 */
- (id)initWithProperties:(NSDictionary *)aProperties;

/**
 * Removes the property indexed by <code>key</code> from this property list.
 * @param aKey the name of the property which is to be removed from the property list.
 */
- (void)removeStringForKey:(NSString *)aKey;

/**
 * Searches for the property with the specified key in this property list. If the key is not found in this property 
 * list, the default property list, and its defaults, recursively, are then checked. 
 * @param aKey the name of the property which is requested.
 * @return the value of the requested property or <code>nil</code> if the specified property was not found.
 */
- (NSString *)stringForKey:(NSString *)aKey;

/**
 * Searches for the property with the specified key in this property list. If the key is not found in this property
 * list, the default property list, and its defaults, recursively, are then checked. 
 * @param aKey the name of the property which is requested.
 * @param aDefaultValue the default value to be returned if the specified property was not found.
 * @return the value of the requested property or the default value argument if the specified property was not found.
 */
- (NSString *)stringForKey:(NSString *)aKey withDefaultValue:(NSString *)aDefaultValue;

/**
 * Inserts <code>aString</code> into this property list indexed by <code>aKey</code>.
 * @param aString the value for the property to be inserted.
 * @param aKey the name of the property which is to be inserted into the property list.
 */
- (void)setString:(NSString *)aString forKey:(NSString *)aKey;

/**
 * Returns a subset of the properties whose keys start with the specified prefix.
 * The returned properties have the specified prefix trimmed from their keys.
 * @param aPrefix the property name prefix to search for, and remove from the returned property list subset.
 * @return a subset of the original property list which contains all the properties whose keys started with the 
 *        specified prefix, but have had the prefix trimmed from them.
 */
- (L4Properties *)subsetForPrefix:(NSString *)aPrefix;

@end
