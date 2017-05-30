/**
 * For copyright & license, see LICENSE.
 */

#import <objc/message.h>
#import "L4Logging.h"
#import "NSObject+Log4Cocoa.h"

void log4Log(id object, int line, const char *file, const char *method, SEL sel, L4Level *level, BOOL isAssertion, BOOL assertion,  id exception, id message, ...)
{
    NSString *combinedMessage;
    if ([message isKindOfClass:[NSString class]] ) {
        va_list args;
        va_start(args, message);
        combinedMessage = [[NSString alloc] initWithFormat:message arguments:args];
        va_end(args);
    } else {
        combinedMessage = message;
    }
    
    if (isAssertion) {
        objc_msgSend([object l4Logger], sel, line, file, method, assertion, combinedMessage);
    } else {
        objc_msgSend([object l4Logger], sel, line, file, method, combinedMessage, level, exception);
    }
}

