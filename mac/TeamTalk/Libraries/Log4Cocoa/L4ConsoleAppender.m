/**
 * For copyright & license, see LICENSE.
 */

#import "L4ConsoleAppender.h"
#import "L4Layout.h"
#import "L4Properties.h"

@implementation L4ConsoleAppender {
    BOOL _isStandardOut; /**< Tracks if this appender is for stdout.*/
}


#pragma mark - Class methods

+ (L4ConsoleAppender *) standardOutWithLayout:(L4Layout *)aLayout
{
    return [[L4ConsoleAppender alloc] initTarget:YES withLayout:aLayout];
}

+ (L4ConsoleAppender *) standardErrWithLayout:(L4Layout *)aLayout
{
    return [[L4ConsoleAppender alloc] initTarget:NO withLayout:aLayout];
}


#pragma mark - Instance methods

- (id) init
{
    return [self initTarget:YES withLayout:[L4Layout simpleLayout]];
}

- (id) initTarget:(BOOL)standardOut withLayout:(L4Layout *)aLayout
{
    self = [super init];
    if (self) {
        if (standardOut) {
            [self setStandardOut];
        } else {
            [self setStandardErr];
        }
        self.layout = aLayout;
    }
    return self;
}

- (BOOL) isStandardOut
{
    return _isStandardOut;
}


#pragma mark - L4Appender protocol methods

- (id) initWithProperties:(L4Properties *)initProperties
{    
    self = [super initWithProperties:initProperties];
    if (self) {
        BOOL logToStandardOut = YES;
        
        // Support for appender.LogToStandardOut in properties configuration file
        if ([initProperties stringForKey:@"LogToStandardOut"]) {
            NSString *buf = [[initProperties stringForKey:@"LogToStandardOut"] lowercaseString];
            logToStandardOut = [buf isEqualToString:@"true"];
        }
        
        if( logToStandardOut ) {
            [self setStandardOut];
        } else {
            [self setStandardErr];
        }
    }
    
    return self;
}


#pragma mark - Private methods

- (void) setStandardOut
{
    @synchronized(self) {
        if (!_isStandardOut || !_fileHandle) {
            _isStandardOut = YES;
            _fileHandle = [NSFileHandle fileHandleWithStandardOutput];
        }
    }
}

- (void) setStandardErr
{
    @synchronized(self) {
        if (_isStandardOut || !_fileHandle) {
            _isStandardOut = NO;
            _fileHandle = [NSFileHandle fileHandleWithStandardError];
        }
    }
}

@end
