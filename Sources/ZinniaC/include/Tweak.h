#import "../drm/drm.h"
#import "../drm/udid.h"
#import "../interface/popups.h"
#import "../obfuscation/string_table.h"
#import "bridge.h"
#import "libblackjack.h"
#import "libhooker.h"
#import "libpddokdo.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

int CTGetSignalStrength();

extern void MSHookMessageEx(Class _class, SEL sel, IMP imp, IMP* result) __attribute__((weak_import));
extern CFArrayRef CPBitmapCreateImagesFromData(CFDataRef cpbitmap, void*, int, void*);

UIImage* lockScreenWallpaper();

@interface AVFlashlight : NSObject
@property(getter=isAvailable, nonatomic, readonly) bool available;
@property(nonatomic, readonly) float flashlightLevel;
@property(getter=isOverheated, nonatomic, readonly) bool overheated;

+ (bool)hasFlashlight;
+ (void)initialize;

- (void)_handleNotification:(id)arg1 payload:(id)arg2;
- (void)_reconnectToServer;
- (void)_setupFlashlight;
- (void)_teardownFlashlight;
- (void)dealloc;
- (float)flashlightLevel;
- (id)init;
- (bool)isAvailable;
- (bool)isOverheated;
- (bool)setFlashlightLevel:(float)arg1 withError:(id*)arg2;
- (void)turnPowerOff;
- (bool)turnPowerOnWithError:(id*)arg1;
@end

@interface CSQuickActionsViewController : UIViewController
@end
@interface CSProudLockViewController : UIViewController
@end
@interface CSQuickActionsButton : UIControl
@end

@interface CSCoverSheetViewController : UIViewController
- (void)setPasscodeLockVisible:(BOOL)arg1 animated:(BOOL)arg2;
- (void)activatePage:(unsigned long long)arg1 animated:(BOOL)arg2 withCompletion:(/*^block*/ id)arg3;
@end

@interface SBWiFiManager : NSObject
- (BOOL)isAssociated;
- (int)signalStrengthBars;
@end

@interface _UIStatusBarSignalView : UIView
@property(assign, nonatomic) long long numberOfActiveBars;
@end

@interface _UIStatusBarCellularSignalView : _UIStatusBarSignalView
@end

@interface SASLockStateMonitor : NSObject
- (void)setUnlockedByTouchID:(BOOL)arg1;
- (void)setLockState:(unsigned long long)arg1;
@end

@interface SBLockScreenManager : NSObject
@property(nonatomic, readonly) CSCoverSheetViewController* coverSheetViewController;
+ (id)sharedInstance;
- (BOOL)unlockUIFromSource:(int)arg1 withOptions:(id)arg2;
@end

@interface SpringBoard : UIApplication
- (void)_simulateLockButtonPress;
- (void)_simulateHomeButtonPress;
@end

@interface CSMainPageContentViewController : UIViewController
@end

@interface NSTask : NSObject

@property(copy) NSURL* executableURL;
@property(copy) NSArray* arguments;
@property(copy) NSDictionary* environment;
@property(copy) NSURL* currentDirectoryURL;
@property(retain) id standardInput;
@property(retain) id standardOutput;
@property(retain) id standardError;
@property(readonly) int processIdentifier;
@property(getter=isRunning, readonly) BOOL running;
@property(readonly) int terminationStatus;
@property(readonly) long long terminationReason;
@property(copy) void (^terminationHandler)(NSTask*);
@property(assign) long long qualityOfService;
+ (id)allocWithZone:(NSZone*)arg1;
+ (id)currentTaskDictionary;
+ (id)launchedTaskWithDictionary:(id)arg1;
+ (id)launchedTaskWithLaunchPath:(id)arg1 arguments:(id)arg2;
+ (id)launchedTaskWithExecutableURL:(id)arg1
						  arguments:(id)arg2
							  error:(out id*)arg3
				 terminationHandler:(void (^)(NSTask*))arg4;
- (id)init;
- (BOOL)resume;
- (int)processIdentifier;
- (NSURL*)executableURL;
- (NSArray*)arguments;
- (id)currentDirectoryPath;
- (long long)qualityOfService;
- (void)setQualityOfService:(long long)arg1;
- (NSDictionary*)environment;
- (void)setArguments:(NSArray*)arg1;
- (void)setCurrentDirectoryPath:(id)arg1;
- (id)launchPath;
- (void)setLaunchPath:(id)arg1;
- (void)setTerminationHandler:(void (^)(NSTask*))arg1;
- (id)terminationHandler;
- (int)terminationStatus;
- (long long)terminationReason;
- (BOOL)isRunning;
- (void)launch;
- (BOOL)launchAndReturnError:(id*)arg1;
- (void)setCurrentDirectoryURL:(NSURL*)arg1;
- (NSURL*)currentDirectoryURL;
- (void)setEnvironment:(NSDictionary*)arg1;
- (void)setExecutableURL:(NSURL*)arg1;
- (void)interrupt;
- (void)terminate;
- (BOOL)suspend;
- (long long)suspendCount;
- (void)setStandardInput:(id)arg1;
- (void)setStandardOutput:(id)arg1;
- (void)setStandardError:(id)arg1;
- (id)standardInput;
- (id)standardOutput;
- (id)standardError;
- (void)setSpawnedProcessDisclaimed:(BOOL)arg1;
- (BOOL)isSpawnedProcessDisclaimed;
- (void)waitUntilExit;
@end

extern CSCoverSheetViewController* csvc;
