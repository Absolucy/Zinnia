#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

UIViewController* makeUnlockButton();
UIViewController* makeUnlockPopups();
UIViewController* makeTimeDate();
bool tweakEnabled();
bool isValidated();
void consumeLockState(uint64_t);
void consumeUnlocked(bool);
