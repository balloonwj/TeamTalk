/**
 * For copyright & license, see LICENSE.
 */

#import "L4FileAppender.h"
#import "L4Layout.h"
#import "L4LogLog.h"
#import "L4Properties.h"

@implementation L4FileAppender

- (id) init
{
    return [self initWithLayout:nil fileName:nil append:NO];
}

- (id) initWithProperties:(L4Properties *) initProperties
{    
    self = [super initWithProperties:initProperties];
    
    if (self) {
        // Support for appender.File in properties configuration file
        NSString *buf = [initProperties stringForKey:@"File"];
        if (!buf) {
            [L4LogLog error:@"Invalid filename; L4FileAppender properties require a file be specified."];
            return nil;
        }
        _fileName = [buf stringByExpandingTildeInPath];
        
        // Support for appender.Append in properties configuration file
        _append = YES;
        if ([initProperties stringForKey:@"Append"]) {
            NSString *buf = [[initProperties stringForKey:@"Append"] lowercaseString];
            _append = [buf isEqualToString:@"true"];
        }
        [self setupFile];
    }
    
    return self;
}

- (id) initWithLayout:(L4Layout *) aLayout fileName:(NSString *) aName
{
    return [self initWithLayout:aLayout fileName:aName append:NO];
}

- (id) initWithLayout:(L4Layout *) aLayout fileName:(NSString *) aName append:(BOOL) flag
{
    self = [super init];
    if (self != nil)
    {
        [self setLayout:aLayout];
        _fileName = [aName stringByExpandingTildeInPath];
        _append = flag;
        [self setupFile];
    }
    return self;
}

- (void)setupFile
{
    NSFileManager*    fileManager = nil;

    @synchronized(self) {
        if (!_fileName || _fileName.length == 0) {
            [self closeFile];
            _fileName = nil;
            [self setFileHandle:nil];
        } else {
        
            fileManager = [NSFileManager defaultManager];
        
            // if file doesn't exist, try to create the file
            if (![fileManager fileExistsAtPath:_fileName]) {
                // if the we cannot create the file, raise a FileNotFoundException
                if (![fileManager createFileAtPath:_fileName contents:nil attributes:nil]) {
                    [NSException raise:@"FileNotFoundException" format:@"Couldn't create a file at %@", _fileName];
                }
            }
        
            // if we had a previous file name, close it and release the file handle
            if (_fileName)
               [self closeFile];
        
            // open a file handle to the file
            [self setFileHandle:[NSFileHandle fileHandleForWritingAtPath:_fileName]];
        
            // check the append option
            if (_append)
                [_fileHandle seekToEndOfFile];
            else
                [_fileHandle truncateFileAtOffset:0];
        }
    }
}


#pragma mark - Protected methods

- (void) closeFile
{
    @synchronized(self) {
        [_fileHandle closeFile];
        
        // Deallocate the file handle because trying to read from or write to a closed file raises exceptions.  Sending messages to nil objects are no-ops.
        _fileHandle = nil;
    }
}
@end

