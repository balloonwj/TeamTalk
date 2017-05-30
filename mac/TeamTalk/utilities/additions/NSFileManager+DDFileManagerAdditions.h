

#import <Foundation/Foundation.h>

@interface NSFileManager (DDFileManagerAdditions)

/*
 * @brief Determine the state of FileVault
 *
 * @result YES if FileVault is turned on; NO if it is not.
 */
- (BOOL)isFileVaultEnabled;

/*
 * @brief Move a file or directory to the trash
 *
 * sourcePath does not need to be tildeExpanded; it will be expanded if necessary.
 * @param sourcePath Path to the file or directory to trash
 * @result YES if trashing was successful or the file already does not exist; NO if it failed
 */
- (BOOL)trashFileAtPath:(NSString *)sourcePath;

/*
 * @brief Delete or trash all files in a directory starting with <b>prefix</b>
 *
 * The files must begin with characters matching <b>prefix</b> exactly; the comparison is case sensitive.
 * @param dirPath The directory in which to search
 * @param prefix The prefix for which to look, case sensitively
 * @param moveToTrash If YES, move the files to the trash. If NO, delete them permanently.
 */
- (void)removeFilesInDirectory:(NSString *)dirPath withPrefix:(NSString *)prefix movingToTrash:(BOOL)moveToTrash;

#pragma mark -

/*
 * @brief Returns the pathname passed in if it exists on disk (test -e). Doesn't care whether the path is a file or a directory.
 * @result The pathname passed in, or nil.
 */
- (NSString *)pathIfExists:(NSString *)path;

/*
 * @brief Returns the pathname passed in if it exists on disk as a directory (test -d).
 * @result The pathname passed in, or nil.
 */
- (NSString *)pathIfDirectory:(NSString *)path;

/*
 * @brief Returns the pathname passed in if it exists on disk as a non-directory (test ! -d).
 * @result The pathname passed in, or nil.
 */
- (NSString *)pathIfNotDirectory:(NSString *)path;

- (NSString *)uniquePathForPath:(NSString *)inPath;

- (NSString *)findFolderOfType:(OSType)type inDomain:(short)domain createFolder:(BOOL)createFolder;

/*
 * @brief Returns the pathname of the user's application support directory
 * @result The pathname of the application support dir, or nil on error
 */
- (NSString *)userApplicationSupportFolder;

/*
 * @brief Returns the actual path pointed to by an alias, or the path itself if it is not an alias
 *
 * It's safe to pass this any path.
 *
 * @result Resolved alias path or the original pathame passed in if it is not an alias
 */
- (NSString *)pathByResolvingAlias:(NSString *)path;

@end
