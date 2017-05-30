// For copyright & license, see LICENSE.

#import <Foundation/Foundation.h>
#import "L4FileAppender.h"

/**
 * The accepted constants for L4DailyRollingFileAppenderFrequency's <code>setFrequency:</code> method.
 */
extern NSString *const L4RollingFrequencyKey;

extern NSString *const L4RollingFrequencyNever;     /**< Never roll the file. */
extern NSString *const L4RollingFrequencyMonthly;   /**< Roll the file over every month. */
extern NSString *const L4RollingFrequencyWeekly;    /**< Roll the file over every week. */
extern NSString *const L4RollingFrequencyDaily;     /**< Roll the file over every day. */
extern NSString *const L4RollingFrequencyHalfDaily; /**< Roll the file over every 12 hours. */
extern NSString *const L4RollingFrequencyHourly;    /**< Roll the file over every hour. */
extern NSString *const L4RollingFrequencyMinutely;  /**< Roll the file over every minute. */

/**
 * L4DailyRollingFileAppender extends L4FileAppender so that the underlying file is rolled over at a 
 * user-chosen frequency. For example, if the fileName is set to /foo/bar.log and the frequency is set
 * to daily, on 2001-02-16 at midnight, the logging file /foo/bar.log will be copied to /foo/bar.log.2001-02-16
 * and logging for 2001-02-17 will continue in /foo/bar.log until it rolls over the next day.
 * It is possible to specify monthly, weekly, half-daily, daily, hourly, or minutely rollover schedules.  
*/
@interface L4DailyRollingFileAppender : L4FileAppender {
    NSDate      *_lastRolloverDate; /**< The date the last role-over ocured.*/
}

/** The frequency with which the file should be rolled.*/
@property (nonatomic, copy) NSString *rollingFrequency;

/**
 * This initializer calls the <code>initWithLayout:fileName:rollingFrequency:</code> method with the respective values:nil, nil, never.
 */
- (id)init;

/**
 * Initializes an instance of this class with the specified layout, file name, and rolling frequency.
 * @param aLayout The layout object for this appender
 * @param aName The file path to the file in which you want logging output recorded
 * @param aRollingFrequency The frequency at which you want the log file rolled over
 */
- (id)initWithLayout:(L4Layout*)aLayout fileName:(NSString*)aName rollingFrequency:(NSString *)aRollingFrequency;

/**
 * Initializes an instance from properties.  The properties supported are:
 * - <c>L4RollingFrequencyKey:</c> specifies the frequency when the log file should be rolled.  See L4RollingFrequency.
 * If the values are being set in a file, this is how they could look:
 *    <code>log4cocoa.appender.A2.L4RollingFrequency=L4RollingFrequencyDaily</code>
 * @param initProperties the proterties to use.
 */
- (id) initWithProperties:(L4Properties *) initProperties;

@end

/**
 * These methods are "protected" methods and should not be called except by subclasses.
*/
@interface L4DailyRollingFileAppender (ProtectedMethods)

/**
 This method overrides the implementation in L4WriterAppender.  It checks if the rolling frequency has been exceeded.
 * If so, it rolls the file over.
 * @param event An L4LoggingEvent that contains logging specific information.
 */
- (void)subAppend: (L4LogEvent*)event;

@end
