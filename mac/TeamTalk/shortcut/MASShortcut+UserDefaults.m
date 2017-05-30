#import "MASShortcut+UserDefaults.h"
#import "MASShortcut+Monitoring.h"
#import "DDUserPreferences.h"

@interface MASShortcutUserDefaultsHotKey : NSObject

@property (nonatomic, readonly) NSString *userDefaultsKey;
@property (nonatomic, copy) void (^handler)();
@property (nonatomic, weak) id monitor;

- (id)initWithUserDefaultsKey:(NSString *)userDefaultsKey handler:(void (^)())handler;
- (void)installHotKeyFromUserDefaults;
@end

#pragma mark -

@implementation MASShortcut (UserDefaults)

+ (NSMutableDictionary *)registeredUserDefaultsHotKeys
{
    static NSMutableDictionary *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [NSMutableDictionary dictionary];
    });
    return shared;
}

+ (void)registerGlobalShortcutWithUserDefaultsKey:(NSString *)userDefaultsKey handler:(void (^)())handler;
{
    MASShortcutUserDefaultsHotKey *hotKey = [[MASShortcutUserDefaultsHotKey alloc] initWithUserDefaultsKey:userDefaultsKey handler:handler];
    [[self registeredUserDefaultsHotKeys] setObject:hotKey forKey:userDefaultsKey];
}

+ (void)unregisterGlobalShortcutWithUserDefaultsKey:(NSString *)userDefaultsKey
{
    NSMutableDictionary *registeredHotKeys = [self registeredUserDefaultsHotKeys];
    [registeredHotKeys removeObjectForKey:userDefaultsKey];
}

+ (void)setGlobalShortcut:(MASShortcut *)shortcut forUserDefaultsKey:(NSString *)userDefaultsKey
{
    NSData *shortcutData = shortcut.data;
    if (shortcutData)
       // [[NSUserDefaults standardUserDefaults] setObject:shortcutData forKey:userDefaultsKey];
        [[DDUserPreferences defaultInstance] setShortcut:shortcut forKey:userDefaultsKey];
    //else
      //  [[DDUserPreferences defaultInstance] removeObjectForKey:userDefaultsKey];
}
+(void)reinstallHotkeyBykey:(NSString *)key{
    MASShortcutUserDefaultsHotKey *hotkey = [[self registeredUserDefaultsHotKeys]objectForKey:key];
    if(hotkey){
        [MASShortcut removeGlobalHotkeyMonitor:hotkey.monitor];
        [hotkey installHotKeyFromUserDefaults];

    }
}
@end

#pragma mark -

@implementation MASShortcutUserDefaultsHotKey {
    NSString *_observableKeyPath;
}

@synthesize monitor = _monitor;
@synthesize handler = _handler;
@synthesize userDefaultsKey = _userDefaultsKey;

#pragma mark -

void *MASShortcutUserDefaultsContext = &MASShortcutUserDefaultsContext;

- (id)initWithUserDefaultsKey:(NSString *)userDefaultsKey handler:(void (^)())handler
{
    self = [super init];
    if (self) {
        _userDefaultsKey = userDefaultsKey.copy;
        _handler = [handler copy];
        _observableKeyPath = [@"values." stringByAppendingString:_userDefaultsKey];
        [MASShortcut removeGlobalHotkeyMonitor:self.monitor];
        [self installHotKeyFromUserDefaults];
    }
    return self;
}

- (void)dealloc
{
  //  [[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self forKeyPath:_observableKeyPath context:MASShortcutUserDefaultsContext];
   // [[DDUserPreferences defaultInstance] removeObserver:self forKeyPath:_observableKeyPath context:MASShortcutUserDefaultsContext];
    [MASShortcut removeGlobalHotkeyMonitor:self.monitor];
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == MASShortcutUserDefaultsContext) {
        [MASShortcut removeGlobalHotkeyMonitor:self.monitor];
        [self installHotKeyFromUserDefaults];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)installHotKeyFromUserDefaults
{
    MASShortcut *shortcut = [[DDUserPreferences defaultInstance] ShortcutforKey:_userDefaultsKey];
    if (shortcut == nil) return;
    self.monitor = [MASShortcut addGlobalHotkeyMonitorWithShortcut:shortcut handler:self.handler];
}

@end
