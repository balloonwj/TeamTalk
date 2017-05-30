/**
 * For copyright & license, see LICENSE.
 */

#import "L4RollingFileAppender.h"
#import "L4Layout.h"
#import "L4LogEvent.h"
#import "L4LogLog.h"
#import "L4Properties.h"

const unsigned long long kL4RollingFileAppenderDefaultMaxFileSize = (1024 * 1024 * 10);

/**
 * Private methods for the L4RollingFileAppender class.
 */
@interface L4RollingFileAppender ()
/**
 * Renames the current log file to have a specific index. Used for rolling log files.
 * @param backupIndex the index of the new file.
 */
- (void)renameLogFile:(unsigned int)backupIndex;

@end


@implementation L4RollingFileAppender

- (id) init
{
    return [self initWithLayout:nil fileName:nil append:YES];
}

- (id) initWithProperties:(L4Properties *)initProperties
{    
    self = [super initWithProperties:initProperties];
    
    if ( self != nil ) {
        unsigned int newMaxFileSize = kL4RollingFileAppenderDefaultMaxFileSize;
        unsigned int newMaxBackupIndex = 1;
        
        // Support for appender.MaximumFileSize in properties configuration file
        if ( [initProperties stringForKey:@"MaximumFileSize"] != nil ) {
            NSString *buf = [[initProperties stringForKey:@"MaximumFileSize"] uppercaseString];
            newMaxFileSize = atoi([buf UTF8String]);
            if ( [buf rangeOfString:@"MB"].location == ([buf length] - 2) ) {
                newMaxFileSize *= (1024 * 1024); // convert to megabytes
            }
            if ( [buf rangeOfString:@"KB"].location == ([buf length] - 2) ) {
                newMaxFileSize *= 1024; // convert to kilobytes
            }
        }
        
        // Support for appender.MaxBackupIndex in properties configuration file
        if ( [initProperties stringForKey:@"MaxBackupIndex"] != nil ) {
            NSString *buf = [[initProperties stringForKey:@"MaxBackupIndex"] uppercaseString];
            newMaxBackupIndex = atoi([buf UTF8String]);
        }
        
        self.maxFileSize = newMaxFileSize;
        self.maxBackupIndex = newMaxBackupIndex;
    }
    
    return self;
}

- (id) initWithLayout:(L4Layout *)aLayout fileName:(NSString *)aName
{
    return [self initWithLayout:aLayout fileName:aName append:YES];
}

- (id) initWithLayout:(L4Layout *)aLayout fileName:(NSString *)aName append:(BOOL) flag
{
    self = [super initWithLayout:aLayout fileName:aName append:flag];
    
    if (self) {
        self.maxFileSize = 1;
        self.maxFileSize = kL4RollingFileAppenderDefaultMaxFileSize;
    }
    
    return self;
}

- (void)rollOver
{
    @synchronized(self) {
        // if maxBackupIndex is 0, truncate file and create no backups
        if (self.maxBackupIndex <= 0) {
            [_fileHandle truncateFileAtOffset:0];
        } else {
            [self closeFile];
            [self renameLogFile:0];
            [self setupFile];
        }
    }
}


#pragma mark - Protected methods

- (void)subAppend:(L4LogEvent*)event
{
    @synchronized(self) {
        // if the file's size has exceeded maximumFileSize, roll the file over
        if ([_fileHandle offsetInFile] >= self.maxFileSize) {
            [self rollOver];
        }
        
        // use the superclass's subAppend
        [super subAppend:event];
    }
}


#pragma mark - Private methods

- (void)renameLogFile:(unsigned int)backupIndex
{
    NSFileManager*  fileManager = nil;
    NSString*       tempOldFileName = nil;
    NSString*       tempNewFileName = nil;
    NSString*       tempPathExtension = nil;
    
    fileManager = [NSFileManager defaultManager];
    
    tempPathExtension = [self.fileName pathExtension];
    
    // if we are trying to rename a backup file > maxBackupIndex
    if (backupIndex >= [self maxBackupIndex]) {
        if ([tempPathExtension length] <= 0) {
            tempOldFileName = [NSString stringWithFormat:@"%@.%d", 
                               [[self fileName] stringByDeletingPathExtension], 
                               [self maxBackupIndex]];
        } else {
            tempOldFileName = [NSString stringWithFormat:@"%@.%d.%@", 
                               [[[self fileName] stringByDeletingPathExtension] stringByDeletingPathExtension], 
                               [self maxBackupIndex], tempPathExtension];
        }
        
        // try to delete the oldest backup file
        if (![fileManager removeItemAtPath:tempOldFileName error:nil]) {
            // if we couldn't delete the file, log an error
            [L4LogLog error:[NSString stringWithFormat:@"Unable to delete the file %@", tempOldFileName]];
        }
    } else {
        // if the backupIndex = 0, we haven't renamed this file before
        if (backupIndex == 0) {
            tempOldFileName = [self fileName];
        } else {
            if ([tempPathExtension length] <= 0) {
                // create the old name of the file
                tempOldFileName = [NSString stringWithFormat:@"%@.%d", 
                                   [[self fileName] stringByDeletingPathExtension],
                                   backupIndex];
            } else {
                // create the old name of the file
                tempOldFileName = [NSString stringWithFormat:@"%@.%d.%@", 
                                   [[[self fileName] stringByDeletingPathExtension] stringByDeletingPathExtension], 
                                   backupIndex, 
                                   tempPathExtension];
            }
        }
        
        // create the new name of the file
        if ([tempPathExtension length] <= 0) {
            tempNewFileName = [NSString stringWithFormat:@"%@.%d", 
                               [[self fileName] stringByDeletingPathExtension], 
                               (backupIndex + 1)];
        } else {
            tempNewFileName = [NSString stringWithFormat:@"%@.%d.%@", 
                               [[[self fileName] stringByDeletingPathExtension] stringByDeletingPathExtension], 
                               (backupIndex + 1), tempPathExtension];
        }
        
        // if the new file name already exists, recursively call this method with the new file name's backup index
        if ([fileManager fileExistsAtPath:tempNewFileName]) {
            [self renameLogFile:(backupIndex + 1)];
        }
        
        // rename the old file
        if (![fileManager moveItemAtPath:tempOldFileName toPath:tempNewFileName error:nil]) {
            [L4LogLog error:[NSString stringWithFormat:@"Unable to move file %@ to %@!", tempOldFileName, tempNewFileName]];
        }
    }
}
@end
