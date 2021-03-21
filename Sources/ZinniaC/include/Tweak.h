#import "libpddokdo.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

int CTGetSignalStrength();

@interface SBFLockScreenDateViewController : UIViewController
@end

@interface SBFLockScreenDateView : UIView
@end

@interface CSCoverSheetViewController : UIViewController
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
