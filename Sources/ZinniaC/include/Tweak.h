#import "libpddokdo.h"
#import "libhooker.h"
#import "libblackjack.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

int CTGetSignalStrength();

@interface AVFlashlight : NSObject
@property (getter=isAvailable, nonatomic, readonly) bool available;
@property (nonatomic, readonly) float flashlightLevel;
@property (getter=isOverheated, nonatomic, readonly) bool overheated;

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
- (void)activatePage:(unsigned long long)arg1 animated:(BOOL)arg2 withCompletion:(/*^block*/id)arg3 ;
@end

@interface SBWiFiManager : NSObject
- (BOOL)isAssociated;
- (int)signalStrengthBars;
@end

@interface _UIStatusBarSignalView : UIView
@property(assign, nonatomic)long long numberOfActiveBars;
@end

@interface _UIStatusBarCellularSignalView : _UIStatusBarSignalView
@end

@interface SASLockStateMonitor : NSObject
-(void)setUnlockedByTouchID:(BOOL)arg1;
-(void)setLockState:(unsigned long long)arg1 ;
@end

@interface SBLockScreenManager : NSObject
@property (nonatomic,readonly) CSCoverSheetViewController * coverSheetViewController; 
+ (id)sharedInstance;
- (BOOL)unlockUIFromSource:(int)arg1 withOptions:(id)arg2;
@end

@interface SpringBoard : UIApplication
- (void)_simulateLockButtonPress;
- (void)_simulateHomeButtonPress;
@end

@interface CSMainPageContentViewController : UIViewController
@end
