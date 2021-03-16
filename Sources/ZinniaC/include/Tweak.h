#import "libpddokdo.h"
#import <UIKit/UIKit.h>

@interface WACurrentForecast : NSObject
@property(assign, nonatomic)long long conditionCode;
- (void)setConditionCode:(long long)arg1;
@end

@interface WAForecastModel : NSObject
@property(nonatomic,retain) WACurrentForecast* currentConditions;
@end

@interface WALockscreenWidgetViewController : UIViewController
- (WAForecastModel *)currentForecastModel;
@end

@interface PDDokdo (Private)
@property(nonatomic, retain, readonly)WALockscreenWidgetViewController* weatherWidget __attribute__((weak_import));
@end

int CTGetSignalStrength();
