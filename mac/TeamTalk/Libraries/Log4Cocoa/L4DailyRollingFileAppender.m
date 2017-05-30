/**
 * For copyright & license, see LICENSE.
 */

#import "L4DailyRollingFileAppender.h"
#import "L4Layout.h"
#import "L4LogLog.h"
#import "L4Properties.h"

#import <math.h>

NSString *const L4RollingFrequencyKey = @"L4RollingFrequency";

NSString *const L4RollingFrequencyNever = @"L4RollingFrequencyNever";
NSString *const L4RollingFrequencyMonthly = @"L4RollingFrequencyMonthly";
NSString *const L4RollingFrequencyWeekly = @"L4RollingFrequencyWeekly";
NSString *const L4RollingFrequencyDaily = @"L4RollingFrequencyDaily";
NSString *const L4RollingFrequencyHalfDaily = @"L4RollingFrequencyHalfDaily";
NSString *const L4RollingFrequencyHourly = @"L4RollingFrequencyHourly";
NSString *const L4RollingFrequencyMinutely = @"L4RollingFrequencyMinutely";

/**
 * Private methods for the L4DailyRollingFileAppender class.
 */
@interface L4DailyRollingFileAppender ()
/**
 * Accessor for the lastRolloverDate property.
 */
- (NSDate *)lastRolloverDate;
/**
 * Mutator for the lastRolloverDate property.
 */
- (void)setLastRolloverDate:(NSDate*)date;

/**
 * Causes a new log file to be generated.
 */
- (void)rollOver;

@end

@implementation L4DailyRollingFileAppender

- (id)init
{
    return [self initWithLayout:nil fileName:nil rollingFrequency:L4RollingFrequencyNever];
}

- (id)initWithLayout:(L4Layout*)aLayout fileName:(NSString*)aName rollingFrequency:(NSString *)aRollingFrequency
{
    self = [super initWithLayout:aLayout fileName:aName append:YES];
    
    if (self != nil) {
        [self setRollingFrequency:aRollingFrequency];
    }
    
    return self;
}

- (void)setRollingFrequency:(NSString *)aRollingFrequency
{    
    _rollingFrequency = [aRollingFrequency copy];
    [self setLastRolloverDate:[NSDate date]];
}

/* ********************************************************************* */
#pragma mark L4PropertiesConfigurable protocol methods
/* ********************************************************************* */
- (id) initWithProperties:(L4Properties *) initProperties
{    
    self = [super initWithProperties:initProperties];
    
    if (self) {
        // Support for appender.L4RollingFrequency in properties configuration file
        NSString *rollingFrequency = [initProperties stringForKey:L4RollingFrequencyKey];
        if (rollingFrequency) {
            self.rollingFrequency = rollingFrequency;
        }
    }
    
    return self;
}

/* ********************************************************************* */
#pragma mark Protected methods
/* ********************************************************************* */
- (void)subAppend:(L4LogEvent*)event
{
    [self rollOver];    
    [super subAppend:event];
}

/* ********************************************************************* */
#pragma mark Private methods
/* ********************************************************************* */
- (NSDate*)lastRolloverDate
{
    return _lastRolloverDate;
}

- (void)setLastRolloverDate:(NSDate*)date
{
    @synchronized(self) {
        if (_lastRolloverDate != date) {
            _lastRolloverDate = date;
        }
    }
}

/** 
 * Rolls file name
 */
- (void)rollOver
{
    // if the rolling frequency is never, return
    if ([self.rollingFrequency isEqualToString:L4RollingFrequencyNever])
        return;
    
    @synchronized(self) {

        NSDate *now = [NSDate date];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *nowDateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit 
                                                                    | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit)
                                                          fromDate:now];
        
        NSDateComponents *lastDateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit 
                                                                     | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) 
                                                           fromDate:self.lastRolloverDate];
        
        bool doRollover = NO;
        NSString *format;
        
        if ([self.rollingFrequency isEqualToString:L4RollingFrequencyMonthly]) {
            doRollover = ([nowDateComponents year] != [lastDateComponents year]) 
            || ([nowDateComponents month] != [lastDateComponents month]);
            
            format = @"yyyy";
            
        } else if ([self.rollingFrequency isEqualToString:L4RollingFrequencyWeekly]) {
            doRollover = ([nowDateComponents year] != [lastDateComponents year]) 
            || ([nowDateComponents week] != [lastDateComponents week]);
            
            format = @"yyyy-MM";
            
        } else if ([self.rollingFrequency isEqualToString:L4RollingFrequencyDaily]) {
            doRollover = ([nowDateComponents year] != [lastDateComponents year]) 
            || ([nowDateComponents month] != [lastDateComponents month])
            || ([nowDateComponents day] != [lastDateComponents day]);
            
            format = @"yyyy-MM-dd";
            
        } else if ([self.rollingFrequency isEqualToString:L4RollingFrequencyHalfDaily]) {
            doRollover = ([nowDateComponents year] != [lastDateComponents year]) 
            || ([nowDateComponents month] != [lastDateComponents month])
            || ([nowDateComponents day] != [lastDateComponents day])
            || (([nowDateComponents hour] / 12) != ([lastDateComponents hour] / 12));
            
            format = @"yyyy-MM-dd-HH";
            
        } else if ([self.rollingFrequency isEqualToString:L4RollingFrequencyHourly]) {
            doRollover = ([nowDateComponents year] != [lastDateComponents year]) 
            || ([nowDateComponents month] != [lastDateComponents month])
            || ([nowDateComponents day] != [lastDateComponents day])
            || ([nowDateComponents hour] != [lastDateComponents hour]); 
            
            format = @"yyyy-MM-dd-HH";
            
        } else if ([self.rollingFrequency isEqualToString:L4RollingFrequencyMinutely]) {
            doRollover = ([nowDateComponents year] != [lastDateComponents year]) 
            || ([nowDateComponents month] != [lastDateComponents month])
            || ([nowDateComponents day] != [lastDateComponents day])
            || ([nowDateComponents hour] != [lastDateComponents hour])
            || ([nowDateComponents minute] != [lastDateComponents minute]); 
            
            format = @"yyyy-MM-dd-HH-mm";
        }
        
        if (doRollover) {
            // generate the new filename extension
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = format;
            NSString *filenameExtension = [dateFormatter stringFromDate:[self lastRolloverDate]];
            
            // generate the new rollover log file name
            NSString *newFileName = [[self fileName] stringByAppendingPathExtension:filenameExtension];
            
            // close the current log file
            [self closeFile];
            
            // rename the current log file to the new rollover log file name
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if (![fileManager moveItemAtPath:[self fileName] toPath:newFileName error:nil]) {
                // if we can't rename the file, log an error
                [L4LogLog error:[NSString stringWithFormat:@"Unable to move file from %@ to %@", [self fileName], newFileName]];
            }
            
            // re-activate this appender (this will open a new log file named [self fileName])
            [self setupFile];
            
            [self setLastRolloverDate:now];
        }
        
    }
}
@end
