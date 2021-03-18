#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

@interface WFTemperature : NSObject
@property (assign,nonatomic) double celsius;
@property (assign,nonatomic) double fahrenheit;
@property (assign,nonatomic) double kelvin;
@end

@interface WADayForecast : NSObject
@property (nonatomic,copy) WFTemperature * high;
@property (nonatomic,copy) WFTemperature * low;
@end

@interface WACurrentForecast : NSObject
@property(assign, nonatomic)long long conditionCode;
-(WFTemperature *)feelsLike;
@end

@interface WAForecastModel : NSObject
@property(nonatomic,retain) WACurrentForecast* currentConditions;
-(NSDate *)sunrise;
-(NSDate *)sunset;
-(NSArray *)dailyForecasts;
@end

@interface WALockscreenWidgetViewController : UIViewController
-(WAForecastModel *)currentForecastModel;
-(id)_temperature;
-(id)_conditionsLine;
-(id)_locationName;
-(id)_conditionsImage;
-(void)_updateTodayView;
-(void)updateWeather;
@end

@interface PDDokdo : NSObject
+ (instancetype)sharedInstance;
@property (nonatomic, copy, readonly) NSString *currentTemperature;
@property (nonatomic, copy, readonly) NSString *currentConditions;
@property (nonatomic, copy, readonly) NSString *currentLocation;
@property (nonatomic, strong, readonly) UIImage *currentConditionsImage;
@property(nonatomic, strong, readonly) NSDate *sunrise;
@property(nonatomic, strong, readonly) NSDate *sunset;
@property (nonatomic, strong, readonly) NSDictionary *weatherData;
@property (nonatomic, retain, readonly) WALockscreenWidgetViewController *weatherWidget;
-(void)refreshWeatherData;
-(NSString *)highestTemperatureIn:(int)type;
-(NSString *)lowestTemperatureIn:(int)type;
@end
