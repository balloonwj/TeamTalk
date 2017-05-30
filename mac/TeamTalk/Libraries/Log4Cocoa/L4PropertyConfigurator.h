#import <Foundation/Foundation.h>

@class L4Properties;

/**
 * The class responsible for configuring the logging system with a properties file.
 */
@interface L4PropertyConfigurator : NSObject {
    L4Properties* properties;       /**< The internal collection in which individual properties are stored.*/
    NSMutableDictionary* appenders; /**< The internal collection in which individual configured appenders are stored.*/
}

/**
 * Returns a newly created instance of L4PropertyConfigurator set to use a given file name for the properties.
 * @param aName the name of the file to read the properties from,
 * @return the new instance of L4PropertyConfigurator.
 */
+ (instancetype)propertyConfiguratorWithFileName:(NSString *)aName;

/**
 * Returns a newly created instance of L4PropertyConfigurator set to use a given properties instance.
 * @param aProperties The properties to use in configuring the system.
 * @return the new instance of L4PropertyConfigurator.
 */
+ (instancetype)propertyConfiguratorWithProperties:(L4Properties *)aProperties;

/**
 * This method initializes a new instance of this class with the specified file path.
 * @param aName the file path of the properties file you want to read from.
 * @return An initialized instance of this class.
 */
- (id)initWithFileName:(NSString *) aName;

/**
 * This method initializes a new instance of this class with the specified properties.
 * @param aProperties an initialized properties collection that contains the properties you want.
 * @return An initialized instance of this class.
 */
- (id)initWithProperties:(L4Properties *) aProperties;

/**
 * Read configuration from a file. The existing configuration is not cleared nor reset.
 *
 * The configuration file consists of statements in the format key=value.
 * The syntax of different configuration elements are discussed below.
 * 
 * Appender configuration
 *
 * Appender configuration syntax is:
 *
 * <code>
 * # For appender named "appenderName", set its class.\n
 * log4cocoa.appender.appenderName=name_of_appender_class
 *
 * # Set appender specific options.\n
 * log4cocoa.appender.appenderName.option1=value1\n
 * ...\n
 * log4cocoa.appender.appenderName.optionN=valueN\n
 *
 * For each named appender you can configure its layout. The syntax for configuring an appender's layout is:\n
 * log4cocoa.appender.appenderName.layout=name_of_layout_class\n
 * log4cocoa.appender.appenderName.layout.option1=value1\n
 * ....\n
 * log4cocoa.appender.appenderName.layout.optionN=valueN
 *
 * Configuring loggers
 *
 * The syntax for configuring the root logger is:\n
 * <code>log4cocoa.rootLogger=[LogLevel], appenderName, appenderName, ...</code>
 *
 * This syntax means that an optional LogLevel value can be supplied followed by appender names separated by commas.
 *
 * The LogLevel value can consist of the string values FATAL, ERROR, WARN, INFO or DEBUG.
 *
 * If a LogLevel value is specified, then the root LogLevel is set to the corresponding LogLevel.  If no LogLevel value
 * is specified, then the root LogLevel remains untouched.
 *
 * The root logger can be assigned multiple appenders.
 *
 * Each appenderName (separated by commas) will be added to the root logger. The named appender is defined using the
 * appender syntax defined above.
 *
 * For non-root loggers the syntax is almost the same:\n
 * <code>log4cocoa.logger.logger_name=[LogLevel|INHERITED], appenderName, appenderName, ...</code>
 *
 * The meaning of the optional LogLevel value is discussed above in relation to the root logger. In addition however, 
 * the value INHERITED can be specified meaning that the named logger should inherit its LogLevel from the logger 
 * hierarchy.
 *
 * By default loggers inherit their LogLevel from the hierarchy.  However, if you set the LogLevel of a logger and
 * later decide that that logger should inherit its LogLevel, then you should specify INHERITED as the value for the 
 * LogLevel value.
 *
 * Similar to the root logger syntax, each <i>appenderName</i> (separated by commas) will be attached to the named 
 * logger.
 *
 * <b>Example</b>
 *
 * An example configuration is given below.\n
 *<code>
 * # Set options for appender named "A1".\n
 * # Appender "A1" will be a L4ConsoleAppender\n
 * log4cocoa.appender.A1=L4ConsoleAppender
 *
 * # The console appender should write to standard out\n
 * log4cocoa.appender.A1.LogToStandardOut=true
 *
 * # A1's layout is a L4PatternLayout, using the conversion pattern "%-5p : %m%n". Thus, the log output will include:\n
 * # - the relative time since the start of the application in milliseconds, \n
 * # - followed by the LogLevel of the log request,\n
 * # - followed by the two rightmost components of the logger name,\n
 * # - followed by the callers method name, \n
 * # - followed by the line number,\n
 * # - the nested disgnostic context,\n
 * # - and finally the message itself.\n
 * # - Refer to the documentation of L4PatternLayout for further information on the syntax of the ConversionPattern 
 *    key.\n
 * log4cocoa.appender.A1.layout=L4PatternLayout\n
 * log4cocoa.appender.A1.layout.ConversionPattern=%-5p : %m%n
 *
 * # Set options for appender named "A2"\n
 * # A2 should be a RollingFileAppender, with maximum file size of 10 MB using at most one backup file. A2's layout is\n
 * #L4PatternLayout using the default conversion pattern.\n
 * log4cocoa.appender.A2=L4RollingFileAppender\n
 * log4cocoa.appender.A2.MaximumFileSize=10MB\n
 * log4cocoa.appender.A2.MaxBackupIndex=1\n
 * log4cocoa.appender.A2.layout=L4PatternLayout
 *
 * # Root logger set to DEBUG using the A2 appender defined above.\n
 * log4cocoa.rootLogger=DEBUG, A2
 *
 * # The logger "class_of_the_day" inherits its LogLevel from the\n
 * # logger hierarchy.  Output will go to the appender's of the root\n
 * # logger, A2 in this case.\n
 * log4cocoa.logger.class_of_the_day=INHERIT
 *
 * </code> </code>
 *
 * Refer to the <b>initWithProperties:</b> method in each L4Appender and L4Layout for class specific properties.
 *
 * Use the <code>#</code> character at the beginning of a line for comments.
 */
- (void) configure;

@end
// For copyright & license, see LICENSE.
