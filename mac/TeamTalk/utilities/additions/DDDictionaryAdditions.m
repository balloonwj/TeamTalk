//
//  NSDictionary+DDDictionaryAdditions.m
//  Duoduo
//
//  Created by maye on 13-10-30.
//  Copyright (c) 2013年 zuoye. All rights reserved.
//

#import "DDDictionaryAdditions.h"
#import "DDSharedWriterQueue.h"

@implementation NSDictionary (DDDictionaryAdditions)
// returns the dictionary from the specified path
+ (NSDictionary *)dictionaryAtPath:(NSString *)path withName:(NSString *)name create:(BOOL)create
{
    NSParameterAssert(path != nil); NSParameterAssert([path length] != 0);
    NSParameterAssert(name != nil); NSParameterAssert([name length] != 0);
    
	NSDictionary	*dictionary = [NSDictionary dictionaryWithContentsOfFile:[[path stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"plist"]];
    
	if (!dictionary && create) dictionary = [NSDictionary dictionary];
    
    return dictionary;
}

- (BOOL)writeToPath:(NSString *)path withName:(NSString *)name
{
	NSParameterAssert(path != nil); NSParameterAssert([path length] != 0);
    NSParameterAssert(name != nil); NSParameterAssert([name length] != 0);
    
	[[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL]; //make sure the path exists
    
    NSData *plistData;
    NSString *retainedError = nil;
    plistData = [NSPropertyListSerialization dataFromPropertyList:self
                                                           format:NSPropertyListBinaryFormat_v1_0
                                                 errorDescription:&retainedError];
    if (plistData) {
        BOOL success = [plistData writeToFile:[[path stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"plist"]
                                   atomically:YES];
        if (!success)
            DDLog(@"%s: Error writing path %@, name %@ (%@)", __PRETTY_FUNCTION__, path, name, [[path stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"plist"]);
        
        return success;
    } else {
        DDLog(@"%s: Could not serialize. Error: \"%@\".", __PRETTY_FUNCTION__, retainedError);
        [self validateAsPropertyList];
        
        return NO;
    }
	return YES;
}

- (BOOL)validateAsPropertyList
{
	BOOL validated = YES;
	for (NSString *key in self) {
		if (![key isKindOfClass:[NSString class]]) {
			DDLog(@"** Dictionary failed validation: %@: Key %@ is a %@ but must be an NSString",
				  self, key, NSStringFromClass([key class]));
			validated = NO;
		}
        
		id value = [self objectForKey:key];
		Class valueClass = [value class];
		if (![value isKindOfClass:[NSString class]] &&
			![value isKindOfClass:[NSData class]] &&
			![value isKindOfClass:[NSNumber class]] &&
			![value isKindOfClass:[NSArray class]] &&
			![value isKindOfClass:[NSDictionary class]] &&
			![value isKindOfClass:[NSDate class]]) {
			DDLog(@"** Dictionary failed validation: %@: Value %@ is a %@ but must be a string, data, number, array, dictionary, or date",
				  self, value, NSStringFromClass(valueClass));
			validated = NO;
		}
		
		if ([value isKindOfClass:[NSArray class]] ||[value isKindOfClass:[NSDictionary class]]) {
			BOOL successOfValue = [value validateAsPropertyList];
			if (validated) validated = successOfValue;
		}
	}
    
    return validated;
}


// saves this dictionary to the specified path
- (void)asyncWriteToPath:(NSString *)path withName:(NSString *)name
{
	NSParameterAssert(path != nil); NSParameterAssert([path length] != 0);
	NSParameterAssert(name != nil); NSParameterAssert([name length] != 0);
    
	[DDSharedWriterQueue addOperation:^{
        [self writeToPath:path withName:name];
    }];
}

@end




@implementation NSMutableDictionary(DDDictionaryAdditions)

// returns the dictionary from the specified path
+ (NSMutableDictionary *)dictionaryAtPath:(NSString *)path withName:(NSString *)name create:(BOOL)create
{
	NSMutableDictionary	*dictionary;
	
    NSParameterAssert(path != nil); NSParameterAssert([path length] != 0);
    NSParameterAssert(name != nil); NSParameterAssert([name length] != 0);
	
	NSData *plistData;
	NSString *error;
	
	plistData = [[NSData alloc] initWithContentsOfFile:[[path stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"plist"]];
	
	dictionary = [NSPropertyListSerialization propertyListFromData:plistData
												  mutabilityOption:NSPropertyListMutableContainers
															format:NULL
												  errorDescription:&error];
    
	if (!dictionary && create) dictionary = [NSMutableDictionary dictionary];
	
    return dictionary;
}

@end
