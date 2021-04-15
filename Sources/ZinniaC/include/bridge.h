#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

UIViewController* makeUnlockButton(void (^)(), void (^)());
UIViewController* makeTimeDate();
bool tweakEnabled();
bool isValidated();
void consumeLockState(uint64_t);
void consumeUnlocked(bool);
