/**
 * For copyright & license, see LICENSE.
 */

#import "L4Logger.h"
#import "L4AppenderAttachable.h"
#import "L4Level.h"
#import "L4LoggerStore.h"
#import "L4LogEvent.h"
#import "L4LogLog.h"
#import "L4RootLogger.h"


static L4LoggerStore *_loggerRepository = nil;

@implementation L4Logger

+ (void) initialize
{
    id rootLogger = [[L4RootLogger alloc] initWithLevel:[L4Level debug]];
    _loggerRepository = [[L4LoggerStore alloc] initWithRoot:rootLogger];
    
    // Initialize Event timmer
    [L4LogEvent startTime];
}

- (id)init
{
    return nil; // never use this constructor
}

- (id)initWithName:(NSString *) aName
{
    self = [super init];
    
    if (self) {
        _name = [aName copy];
        _additivity = YES;
    }
    
    return self;
}

- (L4Level *) effectiveLevel
{
    @synchronized(self) {
        for (L4Logger *logger = self; logger; logger = logger.parent) {
            if (logger.level)
                return logger.level;
        }
    }
    
    [L4LogLog error:@"Root Logger Not Found!"];
    return nil;
}


#pragma mark - AppenderRelatedMethods methods

- (void)callAppenders:(L4LogEvent *) event
{
    int writes = 0;
    
    @synchronized(self) {
        for (L4Logger *logger = self; logger; logger = logger.parent) {
            if (logger.aai)
                writes += [logger.aai appendLoopOnAppenders:event];
            
            if (!logger.additivity)
                break;
        }
    }
    
    if (writes == 0)
        [self.repository emitNoAppenderWarning:self];
}

- (L4AppenderAttachable *) aai
{
    return aai;
}

- (NSArray *) allAppenders
{
    return [aai allAppenders];
}

- (id <L4Appender>) appenderWithName:(NSString *) aName
{
    return [aai appenderWithName:aName];
}

- (void) addAppender:(id <L4Appender>) appender
{
    @synchronized(self) {
        if (!aai)
            aai = [[L4AppenderAttachable alloc] init];
        
        [aai addAppender:appender];
    }
}

- (BOOL) isAttached:(id <L4Appender>) appender
{
    BOOL isAttached = NO;
    @synchronized(self) {
        if((appender != nil) && (aai != nil)) {
            isAttached = [aai isAttached:appender];
        }
    }
    return isAttached;
}

- (void) closeNestedAppenders
{
    @synchronized(self) {
        NSEnumerator *enumerator = [[self allAppenders] objectEnumerator];
        id <L4Appender> anObject;
        
        while ((anObject = (id <L4Appender>)[enumerator nextObject])) {
            [anObject close];
        }
    }
}

- (void) removeAllAppenders
{
    @synchronized(self) {
        [aai removeAllAppenders];
        aai = nil;
    }
}

- (void) removeAppender:(id <L4Appender>) appender
{
    [aai removeAppender:appender];
}

- (void) removeAppenderWithName:(NSString *) aName
{
    [aai removeAppenderWithName:aName];
}


#pragma mark - CoreLoggingMethods methods

// ALL < TRACE < DEBUG < INFO < WARN < ERROR < FATAL < OFF

- (BOOL) isTraceEnabled
{
    return [self isEnabledFor:[L4Level trace]];
}
- (BOOL) isDebugEnabled
{
    return [self isEnabledFor:[L4Level debug]];
}
- (BOOL) isInfoEnabled
{
    return [self isEnabledFor:[L4Level info]];
}
- (BOOL) isWarnEnabled
{
    return [self isEnabledFor:[L4Level warn]];
}
- (BOOL) isErrorEnabled
{
    return [self isEnabledFor:[L4Level error]];
}
- (BOOL) isFatalEnabled
{
    return [self isEnabledFor:[L4Level fatal]];
}

- (BOOL) isEnabledFor:(L4Level *) aLevel
{
    if([self.repository isDisabled:[aLevel intValue]]) {
        return NO;
    }
    return [aLevel isGreaterOrEqual:[self effectiveLevel]];
}

- (void) lineNumber:(int) lineNumber
           fileName:(char *) fileName
         methodName:(char *) methodName
             assert:(BOOL) anAssertion
                log:(NSString *) aMessage
{
    if( !anAssertion ) {
        [self lineNumber:lineNumber
                fileName:fileName
              methodName:methodName
                 message:aMessage
                   level:[L4Level error]
               exception:nil];
    }
}

- (void) lineNumber:(int) lineNumber
           fileName:(char *) fileName
         methodName:(char *) methodName
            message:(id) aMessage
              level:(L4Level *) aLevel
          exception:(NSException *) e
{
    if ([self.repository isDisabled:[aLevel intValue]]) {
        return;
    }
    
    if([aLevel isGreaterOrEqual:[self effectiveLevel]]) {
        [self forcedLog:[L4LogEvent logger:self
                                     level:aLevel
                                lineNumber:lineNumber
                                  fileName:fileName
                                methodName:methodName
                                   message:aMessage
                                 exception:e]];
    }
}

- (void) forcedLog:(L4LogEvent *) event
{
    [self callAppenders:event];
}


#pragma mark - Logger management methods

+ (id <L4LoggerRepository>) loggerRepository
{
    return _loggerRepository;
}

+ (instancetype)rootLogger
{
    return [_loggerRepository rootLogger];
}

+ (instancetype)loggerForClass:(Class) aClass
{
    return [_loggerRepository loggerForClass:aClass];
}

+ (instancetype)loggerForName:(NSString *) aName
{
    return [_loggerRepository loggerForName:aName];
}

+ (instancetype)loggerForName:(NSString *) aName factory:(id <L4LoggerFactory>) aFactory
{
    return [_loggerRepository loggerForName:aName factory:aFactory];
}

+ (NSArray *) currentLoggers
{
    return [_loggerRepository currentLoggers];
}

+ (void) shutdown
{
    return [_loggerRepository shutdown];
}

+ (void) resetConfiguration
{
    return [_loggerRepository resetConfiguration];
}

@end


@implementation L4FunctionLogger
static L4FunctionLogger *instance;
+ (L4FunctionLogger *)instance
{
    if (instance == nil) {
        instance = [[L4FunctionLogger alloc] init];
    }
    return instance;
}

@end
