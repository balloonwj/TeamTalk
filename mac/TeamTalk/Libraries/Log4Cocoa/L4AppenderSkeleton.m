/**
 * For copyright & license, see LICENSE.
 */

#import "L4AppenderSkeleton.h"
#import "L4Filter.h"
#import "L4Level.h"
#import "L4LogEvent.h"
#import "L4LogLog.h"
#import "L4Layout.h"
#import "L4Properties.h"

/**
 * Private methods.
 */
@interface L4AppenderSkeleton ()

/**
 * Returns a new subclass of L4Filter specified by the class name, configured with the supplied properties.
 * @param filterClassName the name of the L4Filter subclass to instantiate.
 * @param filterProperties the properties used to configure the new instance.
 */
- (L4Filter *)filterForClassName:(NSString *)filterClassName andProperties:(L4Properties *)filterProperties;

/**
 * Returns a new subclass of L4Layout specified by the class name, configured with the supplied properties.
 * @param layoutClassName the name of the L4Layout subclass to instantiate.
 * @param layoutProperties the properties used to configure the new instance.
 */
- (L4Layout *)layoutForClassName:(NSString *)layoutClassName andProperties:(L4Properties *)layoutProperties;

@end

@implementation L4AppenderSkeleton

- (id)initWithProperties:(L4Properties *)initProperties
{
    self = [super init];

    if (self) {
        // Configure the layout
        if ([initProperties stringForKey:@"layout"]) {
            L4Properties *layoutProperties = [initProperties subsetForPrefix:@"layout."];
            NSString *className = [initProperties stringForKey:@"layout"];
            L4Layout *newLayout = [self layoutForClassName:className andProperties:layoutProperties];

            if (!newLayout) {
                self.layout = newLayout;
            } else {
                [L4LogLog error:[NSString stringWithFormat:@"Error while creating layout \"%@\".", className]];
                return nil;
            }
        }

        // Support for appender.Threshold in properties configuration file
        if ([initProperties stringForKey:@"Threshold"]) {
            NSString *newThreshold = [[initProperties stringForKey:@"Threshold"] uppercaseString];
            [self setThreshold:[L4Level levelWithName:newThreshold]];
        }

        // Configure the filters
        L4Properties *filtersProperties = [initProperties subsetForPrefix:@"filters."];
        int filterCount = 0;
        while ([filtersProperties stringForKey:[@(++filterCount) stringValue]]) {
            NSString *filterName = [@(filterCount) stringValue];
            L4Properties *filterProperties = [filtersProperties subsetForPrefix:[filterName stringByAppendingString:@"."]];
            NSString *className = [filtersProperties stringForKey:filterName];
            L4Filter *newFilter = [self filterForClassName:className andProperties:filterProperties];

            if (newFilter) {
                [self appendFilter:newFilter];
            } else {
                [L4LogLog error:[NSString stringWithFormat:@"Error while creating filter \"%@\".", className]];
                return nil;
            }
        }
    }

    return self;
}


- (void)append:(L4LogEvent *)anEvent
{
}

- (BOOL)isAsSevereAsThreshold:(L4Level *)aLevel
{
    @synchronized(self) {
        return ((_threshold == nil) || ([aLevel isGreaterOrEqual:_threshold]));
    }
}

#pragma mark - Private methods

- (L4Filter *)filterForClassName:(NSString *)filterClassName andProperties:(L4Properties *)filterProperties
{
    L4Filter *newFilter = nil;
    Class filterClass = NSClassFromString(filterClassName);

    if ( filterClass == nil ) {
        [L4LogLog error:[NSString stringWithFormat:@"Cannot find L4Filter class with name:\"%@\".", filterClassName]];
    } else {
        if ( ![[[filterClass alloc] init] isKindOfClass:[L4Filter class]] ) {
            [L4LogLog error:[NSString stringWithFormat:@"Failed to create instance with name \"%@\" since it is not of kind L4Filter.", filterClass]];
        } else {
            newFilter = [(L4Filter *)[filterClass alloc] initWithProperties:filterProperties];
        }
    }
    return newFilter;
}

- (L4Layout *)layoutForClassName:(NSString *)layoutClassName andProperties:(L4Properties *)layoutProperties
{
    L4Layout *newLayout = nil;
    Class layoutClass = NSClassFromString(layoutClassName);

    if ( layoutClass == nil ) {
        [L4LogLog error:[NSString stringWithFormat:@"Cannot find L4Layout class with name:\"%@\".", layoutClassName]];
    } else {
        if ( ![[[layoutClass alloc] init] isKindOfClass:[L4Layout class]] ) {
            [L4LogLog error:
             [NSString stringWithFormat:
              @"Failed to create instance with name \"%@\" since it is not of kind L4Layout.", layoutClass]];
        } else {
            newLayout = [(L4Layout *)[layoutClass alloc] initWithProperties:layoutProperties];
        }
    }
    return newLayout;
}

#pragma mark - L4AppenderCategory methods

// calls [self append:anEvent] after doing threshold checks
- (void)doAppend:(L4LogEvent *)anEvent
{
    L4Filter *aFilter = [self headFilter];
    BOOL breakLoop = NO;

    if(![self isAsSevereAsThreshold:[anEvent level]]) {
        return;
    }

    BOOL isOkToAppend = YES;

    @synchronized(self) {

        if (_closed) {
            [L4LogLog error:[NSString stringWithFormat:@"Attempted to append to closed appender named: %@", _name]];
            isOkToAppend = NO;
        }

        while (aFilter && !breakLoop) {
            switch([aFilter decide:anEvent]) {
                case L4FilterDeny:
                    isOkToAppend = NO;
                    breakLoop = YES;
                    break;
                case L4FilterAccept:
                    breakLoop = YES;
                    break;
                case L4FilterNeutral:
                default:
                    aFilter = [aFilter next];
                    break;
            }
        }

        if (isOkToAppend) {
            [self append:anEvent]; // passed all threshold checks, append event.
        }
    }
}

- (void)appendFilter:(L4Filter *)newFilter
{
    @synchronized(self) {
        if (!_headFilter) {
            _headFilter = _tailFilter = newFilter;
        } else {
            _tailFilter.next = newFilter;
            _tailFilter = newFilter;
        }
    }
}

- (L4Filter *)headFilter
{
    return _headFilter;
}

- (void)clearFilters
{
    @autoreleasepool {

        @synchronized(self) {
            for (L4Filter *filter = _headFilter; filter; filter = [_headFilter next] ) {
                filter.next = nil;
            }
            _headFilter = nil;
            _tailFilter = nil;
        }

    }
}

- (void)close
{
}

- (BOOL)requiresLayout
{
    return NO;
}

@end
