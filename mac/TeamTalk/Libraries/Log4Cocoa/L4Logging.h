/**
 * For copyright & license, see LICENSE.
 */
#import <Foundation/Foundation.h>
#import "Log4CocoaDefines.h"
#import "L4Level.h"

/**
 * LOGGING MACROS: These macros are convience macros that easily allow the capturing of
 * line number, source file, and method name information without interupting the flow of
 * your source code.
 *
 * The base macros are not meant to be used directly; they are there for the other
 * to use as they define the basic function call.
 */

LOG4COCOA_EXTERN void log4Log(id object, int line, const char *file, const char *method, SEL sel, L4Level *level, BOOL isAssertion,
                              BOOL assertion, id exception, id message, ...);


#pragma mark - Base macros used for logging from objects

#define L4_LOG(type, e) self, __LINE__, __FILE__, __PRETTY_FUNCTION__, @selector(lineNumber:fileName:methodName:message:level:exception:), type, NO, YES, e
#define L4_ASSERTION(assertion) self, __LINE__, __FILE__, __PRETTY_FUNCTION__, @selector(lineNumber:fileName:methodName:assert:log:), [L4Level error], YES, assertion, nil


#pragma mark - Base macros used for logging from C functions

#define L4C_LOG(type, e) [L4FunctionLogger instance], __LINE__, __FILE__, __PRETTY_FUNCTION__, @selector(lineNumber:fileName:methodName:message:level:exception:), type, NO, YES, e
#define L4C_ASSERTION(assertion) [L4FunctionLogger instance], __LINE__, __FILE__, __PRETTY_FUNCTION__, @selector(lineNumber:fileName:methodName:assert:log:), [L4Level error], YES, assertion, nil


#pragma mark - Macros that log from objects

#define log4Trace(message, ...) if([[self l4Logger] isDebugEnabled]){ log4Log(L4_LOG([L4Level trace], nil), message, ##__VA_ARGS__);}
#define log4Debug(message, ...) if([[self l4Logger] isDebugEnabled]){ log4Log(L4_LOG([L4Level debug], nil), message, ##__VA_ARGS__);}
#define log4Info(message, ...)  if([[self l4Logger] isInfoEnabled]){ log4Log(L4_LOG([L4Level info], nil), message, ##__VA_ARGS__);}
#define log4Warn(message, ...)  log4Log(L4_LOG([L4Level warn], nil), message, ##__VA_ARGS__)
#define log4Error(message, ...) log4Log(L4_LOG([L4Level error], nil), message, ##__VA_ARGS__)
#define log4Fatal(message, ...) log4Log(L4_LOG([L4Level fatal], nil), message, ##__VA_ARGS__)


#pragma mark - Macros that log from C functions

#define log4CDebug(message, ...) if([[[L4FunctionLogger instance] l4Logger] isDebugEnabled]){ log4Log(L4C_LOG([L4Level debug], nil), message, ##__VA_ARGS__);}
#define log4CInfo(message, ...)  if([[[L4FunctionLogger instance] l4Logger] isInfoEnabled]){ log4Log(L4C_LOG([L4Level info], nil), message, ##__VA_ARGS__);}
#define log4CWarn(message, ...)  log4Log(L4C_LOG([L4Level warn], nil), message, ##__VA_ARGS__)
#define log4CError(message, ...) log4Log(L4C_LOG([L4Level error], nil), message, ##__VA_ARGS__)
#define log4CFatal(message, ...) log4Log(L4C_LOG([L4Level fatal], nil), message, ##__VA_ARGS__)


#pragma mark - Macros that log with an exception from objects

#define log4DebugWithException(message, e, ...) if([[self l4Logger] isDebugEnabled]){ log4Log(L4_LOG([L4Level debug], e), message, ##__VA_ARGS__);}
#define log4InfoWithException(message, e, ...)  if([[self l4Logger] isInfoEnabled]){ log4Log(L4_LOG([L4Level info], e), message, ##__VA_ARGS__);}
#define log4WarnWithException(message, e, ...)  log4Log(L4_LOG([L4Level warn], e), message, ##__VA_ARGS__)
#define log4ErrorWithException(message, e, ...) log4Log(L4_LOG([L4Level error], e), message, ##__VA_ARGS__)
#define log4FatalWithException(message, e, ...) log4Log(L4_LOG([L4Level fatal], e), message, ##__VA_ARGS__)


#pragma mark Macros that log with an exception from C functions

#define log4CDebugWithException(message, e, ...) if([[[L4FunctionLogger instance] l4Logger] isDebugEnabled]){ log4Log(L4C_LOG([L4Level debug], e), message, ##__VA_ARGS__);}
#define log4CInfoWithException(message, e, ...)  if([[[L4FunctionLogger instance] l4Logger] isInfoEnabled]){ log4Log(L4C_LOG([L4Level info], e), message, ##__VA_ARGS__);}
#define log4CWarnWithException(message, e, ...)  log4Log(L4C_LOG([L4Level warn], e), message, ##__VA_ARGS__)
#define log4CErrorWithException(message, e, ...) log4Log(L4C_LOG([L4Level error], e), message, ##__VA_ARGS__)
#define log4CFatalWithException(message, e, ...) log4Log(L4C_LOG([L4Level fatal], e), message, ##__VA_ARGS__)


#pragma mark - Macro that log when an assertion is false from objects

#define log4Assert(assertion, message, ...) log4Log(L4_ASSERTION(assertion), message, ##__VA_ARGS__)


#pragma mark - Macro that log when an assertion is false from C functions

#define log4CAssert(assertion, message, ...) log4Log(L4C_ASSERTION(assertion), message, ##__VA_ARGS__)

