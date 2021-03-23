#import "libpddokdo.h"
#import "libhooker.h"
#import "libblackjack.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

int CTGetSignalStrength();

@interface SBFLockScreenDateViewController : UIViewController
@end

@interface SBFLockScreenDateView : UIView
@end

@interface CSLockScreenSettings : NSObject
@end

@interface CSCoverSheetViewController : UIViewController {
	CSLockScreenSettings *_prototypeSettings;
}
- (void)setPasscodeLockVisible:(BOOL)arg1 animated:(BOOL)arg2;
@end

@interface SBLockScreenViewControllerBase : UIViewController
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
+ (id)sharedInstance;
- (BOOL)unlockUIFromSource:(int)arg1 withOptions:(id)arg2 ;
@end

@interface SpringBoard : UIApplication
- (void)_simulateLockButtonPress;
- (void)_simulateHomeButtonPress;
@end

@interface CSCombinedListViewController : UIViewController
@end

@interface SBFTouchPassThroughViewController : UIViewController
-(void)loadView;
-(void)configureTouchPassThroughView:(id)arg1 ;
@end
