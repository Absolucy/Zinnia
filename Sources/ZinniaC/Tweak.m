#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#ifdef THEOS_SWIFT
#import "Zinnia-Swift.h"
#endif
#import "drm/drm.h"
#import "include/Tweak.h"
#import "include/libblackjack.h"
#import "include/libhooker.h"

#define VALIDITY_CHECK                                                                                                 \
	if (!isValidated()) {                                                                                              \
		return;                                                                                                        \
	}

UIViewController* unlockButton;
UIViewController* timeDate;
CSCoverSheetViewController* csvc;

static void (*orig_CSCoverSheetViewController_viewDidLoad)(CSCoverSheetViewController* self, SEL cmd);
static void hook_CSCoverSheetViewController_viewDidLoad(CSCoverSheetViewController* self, SEL cmd) {
	orig_CSCoverSheetViewController_viewDidLoad(self, cmd);
	if (!unlockButton) {
		unlockButton = makeUnlockButton(
			^() {
			  [[NSClassFromString(@"SpringBoard") performSelector:@selector(sharedApplication)]
				  performSelector:@selector(_simulateHomeButtonPress)];
			  // we do a little trolling
			  if (!check_for_plist())
				  ((void (*)())NULL)();
			},
			^() {
			  [csvc activatePage:1 animated:YES withCompletion:nil];
			  if (!check_for_plist())
				  ((void (*)())NULL)();
			});
		unlockButton.view.backgroundColor = UIColor.clearColor;
	}
	if (!timeDate) {
		timeDate = makeTimeDate();
		timeDate.view.backgroundColor = UIColor.clearColor;
	}
	if (!csvc)
		csvc = self;

	for (UIViewController* o in self.childViewControllers) {
		NSString* className = NSStringFromClass([o class]);
		if ([className rangeOfString:@"DateView"].location != NSNotFound ||
			[className rangeOfString:@"FixedFooter"].location != NSNotFound ||
			[className rangeOfString:@"TeachableMoments"].location != NSNotFound ||
			[className rangeOfString:@"ProudLock"].location != NSNotFound ||
			[className rangeOfString:@"QuickActions"].location != NSNotFound)
		{
			[o.view removeFromSuperview];
		}
	}

	unlockButton.view.frame = self.view.frame;
	[self addChildViewController:unlockButton];
	[self.view addSubview:unlockButton.view];
	unlockButton.view.translatesAutoresizingMaskIntoConstraints = false;
	[NSLayoutConstraint activateConstraints:@[
		[unlockButton.view.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
		[unlockButton.view.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
		[unlockButton.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
	]];
	[unlockButton didMoveToParentViewController:self];

	timeDate.view.frame = self.view.frame;
	[self addChildViewController:timeDate];
	[self.view addSubview:timeDate.view];
	timeDate.view.translatesAutoresizingMaskIntoConstraints = false;
	[NSLayoutConstraint activateConstraints:@[
		[timeDate.view.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
		[timeDate.view.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
		[timeDate.view.topAnchor constraintEqualToAnchor:self.view.topAnchor]
	]];
	[timeDate didMoveToParentViewController:self];
	[[NSProcessInfo processInfo] operatingSystemVersion];
}

static bool has_drm_ran = false;
static void (*orig_CSCoverSheetViewController_finishUIUnlockFromSource)(CSCoverSheetViewController* self, SEL cmd,
																		int state);
static void hook_CSCoverSheetViewController_finishUIUnlockFromSource(CSCoverSheetViewController* self, SEL cmd,
																	 int state) {
	if (!has_drm_ran)
		runDrm();
	has_drm_ran = true;
	return orig_CSCoverSheetViewController_finishUIUnlockFromSource(self, cmd, state);
}

static bool hook_UIViewController_canShowWhileLocked(UIViewController* self, SEL cmd) {
	return true;
}

static void hook_VariousUIViewControllers_viewDidLoad(UIViewController* self, SEL cmd) {
}

static UIView* (*orig_VariousUIViews_initWithFrame)(UIView* self, SEL cmd, CGRect frame);
static UIView* hook_VariousUIViews_initWithFrame(UIView* self, SEL cmd, CGRect _frame) {
	return orig_VariousUIViews_initWithFrame(self, cmd, CGRectMake(0, 0, 0, 0));
}

static void hook_VariousUIViews_layoutSubviews(UIViewController* self, SEL cmd) {
}

static void (*orig_SASLockStateMonitor_setUnlockedByTouchID)(NSObject* self, SEL cmd, bool state);
static void hook_SASLockStateMonitor_setUnlockedByTouchID(NSObject* self, SEL cmd, bool state) {
	consumeUnlocked(state);
	return orig_SASLockStateMonitor_setUnlockedByTouchID(self, cmd, state);
}

static void (*orig_SASLockStateMonitor_setLockState)(NSObject* self, SEL cmd, UInt64 state);
static void hook_SASLockStateMonitor_setLockState(NSObject* self, SEL cmd, UInt64 state) {
	consumeLockState(state);
	return orig_SASLockStateMonitor_setLockState(self, cmd, state);
}

void hook(Class cls, SEL sel, void* imp, void** result) {
	if (!check_for_plist())
		return;
	if (LHStrError != NULL && LBHookMessage != NULL) {
		if (!check_for_plist())
			return;
		enum LIBHOOKER_ERR ret = LBHookMessage(cls, sel, imp, result);
		if (ret != LIBHOOKER_OK) {
			const char* err = LHStrError(ret);
			NSLog(@"Zinnia: failed to hook [%@ %@]: %s", NSStringFromClass(cls), NSStringFromSelector(sel), err);
		}
	} else if (MSHookMessageEx != NULL) {
		if (!check_for_plist())
			return;
		MSHookMessageEx(cls, sel, (IMP)imp, (IMP*)result);
	}
}

__attribute__((constructor)) static void init() {
	if (LHStrError != NULL && LBHookMessage != NULL) {
		NSLog(@"Zinnia: using libhooker :)");
	} else if (MSHookMessageEx != NULL) {
		NSLog(@"Zinnia: using Substrate/Substitute :/");
	} else {
		NSLog(@"Zinnia: neither libhooker or substrate/substitute is loaded... confused and dazed, but trying to "
			  @"continue.");
	}

	hook(objc_getClass("CSCoverSheetViewController"), @selector(finishUIUnlockFromSource:),
		 (void*)&hook_CSCoverSheetViewController_finishUIUnlockFromSource,
		 (void**)&orig_CSCoverSheetViewController_finishUIUnlockFromSource);

	VALIDITY_CHECK

	if (tweakEnabled()) {
		VALIDITY_CHECK
		hook(objc_getClass("CSCoverSheetViewController"), @selector(viewDidLoad),
			 (void*)&hook_CSCoverSheetViewController_viewDidLoad, (void**)&orig_CSCoverSheetViewController_viewDidLoad);
		VALIDITY_CHECK
		hook(objc_getClass("CSProudLockViewController"), @selector(viewDidLoad),
			 (void*)&hook_VariousUIViewControllers_viewDidLoad, NULL);
		VALIDITY_CHECK
		hook(objc_getClass("CSQuickActionsViewController"), @selector(viewDidLoad),
			 (void*)&hook_VariousUIViewControllers_viewDidLoad, NULL);
		VALIDITY_CHECK
		hook(objc_getClass("SBFLockScreenDateViewController"), @selector(viewDidLoad),
			 (void*)&hook_VariousUIViewControllers_viewDidLoad, NULL);
		VALIDITY_CHECK
		hook(objc_getClass("CSQuickActionsButton"), @selector(initWithFrame:),
			 (void*)&hook_VariousUIViews_initWithFrame, (void**)&orig_VariousUIViews_initWithFrame);
		VALIDITY_CHECK
		hook(objc_getClass("CSQuickActionsButton"), @selector(layoutSubviews),
			 (void*)&hook_VariousUIViews_layoutSubviews, NULL);
		VALIDITY_CHECK
		hook(objc_getClass("SASLockStateMonitor"), @selector(setUnlockedByTouchID:),
			 (void*)&hook_SASLockStateMonitor_setUnlockedByTouchID,
			 (void**)&orig_SASLockStateMonitor_setUnlockedByTouchID);
		VALIDITY_CHECK
		hook(objc_getClass("SASLockStateMonitor"), @selector(setLockState:),
			 (void*)&hook_SASLockStateMonitor_setLockState, (void**)&orig_SASLockStateMonitor_setLockState);
		VALIDITY_CHECK
		hook(objc_getClass("UIViewController"), @selector(_canShowWhileLocked),
			 (void*)&hook_UIViewController_canShowWhileLocked, NULL);
		VALIDITY_CHECK
	}
}
