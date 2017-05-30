// For copyright & license, see LICENSE.

#import "L4WriterAppender.h"
#import "L4Layout.h"
#import "L4LogEvent.h"
#import "L4LogLog.h"
#import "L4Properties.h"

static NSData *lineBreakChar;

@implementation L4WriterAppender

+ (void)initialize
{
    lineBreakChar = [@"\n" dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
}

- (id) init
{
    self = [super init];
    if (self) {
        _immediateFlush = YES;
        _lossyEncoding = YES;
        _encoding = NSUTF8StringEncoding;
    }
    return self;
}

- (id) initWithProperties:(L4Properties *) initProperties
{    
    self = [super initWithProperties:initProperties];
    
    if (self) {
        BOOL newImmediateFlush = YES;
        
        // Support for appender.ImmediateFlush in properties configuration file
        if ([initProperties stringForKey:@"ImmediateFlush"]) {
            NSString *buf = [[initProperties stringForKey:@"ImmediateFlush"] lowercaseString];
            newImmediateFlush = [buf isEqualToString:@"true"];
        }
        
        self.immediateFlush = newImmediateFlush;
        _lossyEncoding = YES;
        _encoding = NSUTF8StringEncoding;
    }
    
    return self;
}

- (id) initWithLayout:(L4Layout *)aLayout fileHandle:(NSFileHandle *)aFileHandle
{
    self = [super init];
    if (self) {
        self.layout = aLayout;
        _fileHandle = aFileHandle;
        _immediateFlush = YES;
        _lossyEncoding = YES;
        _encoding = NSUTF8StringEncoding;
    }
    return self;
}

- (void)append:(L4LogEvent *)anEvent
{
    @synchronized(self) {
        if ([self checkEntryConditions]) {
            [self subAppend:anEvent];
        }
    }
}

- (void)subAppend:(L4LogEvent *)anEvent
{
    [self write:[self.layout format:anEvent]];
}

- (BOOL) checkEntryConditions
{
    if (_closed) {
        [L4LogLog warn:@"Not allowed to write to a closed appender."];
        return NO;
    }

    if (!_fileHandle) {
        [L4LogLog error:[@"No file handle for output stream set for the appender named:" stringByAppendingString:self.name]];
        return NO;
    }

    if (!self.layout) {
        [L4LogLog error:[@"No layout set for the appender named:" stringByAppendingString:self.name]];
        return NO;
    }
    
    return YES;
}

- (void) closeWriter
{
    @try {
        [_fileHandle closeFile];
    }
    @catch (NSException *localException) {
        [L4LogLog error:[NSString stringWithFormat:@"Could not close file handle:%@\n%@", _fileHandle,  localException]];
    }
}

- (void)setFileHandle:(NSFileHandle*)fh
{
    @synchronized(self) {
        if (_fileHandle != fh) {
            [self closeWriter];
            _fileHandle = fh;
        }
    }
}

- (void) reset
{
    [self closeWriter];
}

- (void) write:(NSString *)string
{
    if (string) {
        @try {
            @synchronized(self) {
                // TODO ### -- NEED UNIX EXPERT IS THIS THE BEST WAY ??
                // TODO - ### - NEED TO WORK ON ENCODING ISSUES (& THEN LATER LOCALIZATION)
                //
                [_fileHandle writeData:[string dataUsingEncoding:_encoding allowLossyConversion:_lossyEncoding]];
                [_fileHandle writeData:lineBreakChar];
            }
        }
        @catch (NSException *localException) {
            [L4LogLog error:[NSString stringWithFormat:@"Appender failed to write string:%@\n%@", string, localException]];
        }
    }
}

- (void) writeHeader
{
    [self write:[self.layout header]];
}

- (void) writeFooter
{
    [self write:[self.layout footer]];
}


#pragma mark - L4AppenderCategory methods

- (void) close
{
    @synchronized(self) {
        if (!_closed) {
            _closed = YES;
            [self writeFooter];
            [self reset];
        }
    }
}

- (BOOL) requiresLayout
{
    return YES;
}

@end
