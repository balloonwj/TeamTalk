/**
 * For copyright & license, see LICENSE.
 */

#import "L4LogEvent.h"
#import "L4Logger.h"

static const int   NO_LINE_NUMBER = -1;
static const char *NO_FILE_NAME   = "";
static const char *NO_METHOD_NAME = "";

static NSDate *startTime = nil;

@implementation L4LogEvent

@synthesize renderedMessage = _renderedMessage;

+ (void) initialize
{
    startTime = [NSDate date];
}

+ (NSDate *) startTime
{
    return startTime;
}

+ (instancetype)logger:(L4Logger *)aLogger
                 level:(L4Level *)aLevel
               message:(id)aMessage
{
    return [self logger:aLogger
                  level:aLevel
             lineNumber:NO_LINE_NUMBER
               fileName:NO_FILE_NAME
             methodName:NO_METHOD_NAME
                message:aMessage
              exception:nil];
}

+ (instancetype)logger:(L4Logger *)aLogger
                 level:(L4Level *)aLevel
               message:(id)aMessage
             exception:(NSException *)e;
{
    return [self logger:aLogger
                  level:aLevel
             lineNumber:NO_LINE_NUMBER
               fileName:NO_FILE_NAME
             methodName:NO_METHOD_NAME
                message:aMessage
              exception:e];
}

+ (instancetype)logger:(L4Logger *)aLogger
                 level:(L4Level *)aLevel
            lineNumber:(int)aLineNumber
              fileName:(const char *)aFileName
            methodName:(const char *)aMethodName
               message:(id)aMessage
             exception:(NSException *)e
{
    return [[L4LogEvent alloc] initWithLogger:aLogger
                                        level:aLevel
                                   lineNumber:aLineNumber
                                     fileName:aFileName
                                   methodName:aMethodName
                                      message:aMessage
                                    exception:e
                               eventTimestamp:[NSDate date]];
}

- (id) init
{
    return nil;
}

- (id) initWithLogger:(L4Logger *) aLogger
                level:(L4Level *) aLevel
           lineNumber:(int) aLineNumber
             fileName:(const char *) aFileName
           methodName:(const char *) aMethodName
              message:(id) aMessage
            exception:(NSException *) e
       eventTimestamp:(NSDate *) aDate
{
    self = [super init];
    if (self) {
        _lineNumber = @(aLineNumber);
        _fileName = @(aFileName);
        _methodName = @(aMethodName);
        
        _logger = aLogger;
        _level = aLevel;
        _message = aMessage;
        _exception = e;
        _timestamp = aDate;
    }
    return self;
}

- (long) millisSinceStart
{
    // its a double in seconds
    NSTimeInterval time = [_timestamp timeIntervalSinceDate:startTime];
    return (long) (time * 1000);
}

- (NSString *) renderedMessage
{
    if (!_renderedMessage && _message) {
        if ([_message isKindOfClass:[NSString class]]) {
            _renderedMessage = [_message copy];  // if its a string return it.
        } else {
            _renderedMessage = [_message description];
        }
    }
    
    return _renderedMessage;
}

@end
