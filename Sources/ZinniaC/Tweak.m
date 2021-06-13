#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#ifdef THEOS_SWIFT
#import "Zinnia-Swift.h"
#endif
#import "include/Tweak.h"
#import "include/libblackjack.h"
#import "include/libhooker.h"

extern void runDrm();
extern void initialize_string_table();

#define VALIDITY_CHECK                                                                                                 \
	if (!isValidated()) {                                                                                              \
		return;                                                                                                        \
	}

UIViewController* unlockButton;
UIViewController* popups;
UIViewController* timeDate;
CSCoverSheetViewController* csvc;

static void (*orig_CSCoverSheetViewController_viewDidLoad)(CSCoverSheetViewController* self, SEL cmd);
static void hook_CSCoverSheetViewController_viewDidLoad(CSCoverSheetViewController* self, SEL cmd) {
	orig_CSCoverSheetViewController_viewDidLoad(self, cmd);

	if (!unlockButton) {
		unlockButton = makeUnlockButton();
		unlockButton.view.backgroundColor = UIColor.clearColor;
	}
	if (isValidated()) {
		if (!popups) {
			VALIDITY_CHECK
			popups = makeUnlockPopups();
			VALIDITY_CHECK
			popups.view.backgroundColor = UIColor.clearColor;
			VALIDITY_CHECK
		}
		if (!timeDate) {
			VALIDITY_CHECK
			timeDate = makeTimeDate();
			VALIDITY_CHECK
			timeDate.view.backgroundColor = UIColor.clearColor;
			VALIDITY_CHECK
		}
	} else {
		if (popups) {
			popups.view.frame = CGRectMake(0, 0, 0, 0);
			[popups.view removeFromSuperview];
			[popups removeFromParentViewController];
			[popups didMoveToParentViewController:nil];
			popups = NULL;
		}
		if (timeDate) {
			timeDate.view.frame = CGRectMake(0, 0, 0, 0);
			[timeDate.view removeFromSuperview];
			[timeDate removeFromParentViewController];
			[timeDate didMoveToParentViewController:nil];
			timeDate = NULL;
		}
	}
	if (!csvc)
		csvc = self;

	if (isValidated()) {
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
	}

	if (isValidated()) {
		popups.view.frame = self.view.frame;
		[self addChildViewController:popups];
		[self.view addSubview:popups.view];
		popups.view.translatesAutoresizingMaskIntoConstraints = false;
		[NSLayoutConstraint activateConstraints:@[
			[popups.view.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
			[popups.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
		]];
		[popups didMoveToParentViewController:self];
	}

	unlockButton.view.frame = self.view.frame;
	[self addChildViewController:unlockButton];
	[self.view addSubview:unlockButton.view];
	unlockButton.view.translatesAutoresizingMaskIntoConstraints = false;
	[NSLayoutConstraint activateConstraints:@[
		[unlockButton.view.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
		[unlockButton.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
	]];
	[unlockButton didMoveToParentViewController:self];

	VALIDITY_CHECK

	if (isValidated()) {
		timeDate.view.frame = self.view.frame;
		[self addChildViewController:timeDate];
		[self.view addSubview:timeDate.view];
		timeDate.view.translatesAutoresizingMaskIntoConstraints = false;
		[NSLayoutConstraint activateConstraints:@[
			[timeDate.view.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
			[timeDate.view.topAnchor constraintEqualToAnchor:self.view.topAnchor]
		]];
		[timeDate didMoveToParentViewController:self];
	}
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

static bool (*orig_UIViewController_canShowWhileLocked)(UIViewController* self, SEL cmd);
static bool hook_UIViewController_canShowWhileLocked(UIViewController* self, SEL cmd) {
	if (!isValidated())
		return orig_UIViewController_canShowWhileLocked(self, cmd);
	return true;
}

static void (*orig_CSProudLockViewController_viewDidLoad)(UIViewController* self, SEL cmd);
static void hook_CSProudLockViewController_viewDidLoad(UIViewController* self, SEL cmd) {
	if (!isValidated())
		return orig_CSProudLockViewController_viewDidLoad(self, cmd);
}

static void (*orig_CSQuickActionsViewController_viewDidLoad)(UIViewController* self, SEL cmd);
static void hook_CSQuickActionsViewController_viewDidLoad(UIViewController* self, SEL cmd) {
	if (!isValidated())
		return orig_CSQuickActionsViewController_viewDidLoad(self, cmd);
}

static void (*orig_SBFLockScreenDateViewController_viewDidLoad)(UIViewController* self, SEL cmd);
static void hook_SBFLockScreenDateViewController_viewDidLoad(UIViewController* self, SEL cmd) {
	if (!isValidated())
		return orig_SBFLockScreenDateViewController_viewDidLoad(self, cmd);
}

static UIView* (*orig_CSQuickActionsButton_initWithFrame)(UIView* self, SEL cmd, CGRect frame);
static UIView* hook_CSQuickActionsButton_initWithFrame(UIView* self, SEL cmd, CGRect frame) {
	if (!isValidated())
		return orig_CSQuickActionsButton_initWithFrame(self, cmd, frame);
	return orig_CSQuickActionsButton_initWithFrame(self, cmd, CGRectMake(0, 0, 0, 0));
}

static UIView* (*orig_SBFLockScreenDateView_initWithFrame)(UIView* self, SEL cmd, CGRect frame);
static UIView* hook_SBFLockScreenDateView_initWithFrame(UIView* self, SEL cmd, CGRect frame) {
	if (!isValidated())
		return orig_SBFLockScreenDateView_initWithFrame(self, cmd, frame);
	return orig_SBFLockScreenDateView_initWithFrame(self, cmd, CGRectMake(0, 0, 0, 0));
}

static void (*orig_SBFLockScreenDateViewController_setContentAlpha)(UIViewController* self, SEL cmd, double alpha,
																	bool subtitleVisible);
static void hook_SBFLockScreenDateViewController_setContentAlpha(UIViewController* self, SEL cmd, double alpha,
																 bool subtitleVisible) {
	if (!isValidated())
		return orig_SBFLockScreenDateViewController_setContentAlpha(self, cmd, alpha, subtitleVisible);
	return orig_SBFLockScreenDateViewController_setContentAlpha(self, cmd, 0.0, false);
}

static void (*orig_SBFLockScreenDateView_layoutSubviews)(UIView* self, SEL cmd);
static void hook_SBFLockScreenDateView_layoutSubviews(UIView* self, SEL cmd) {
	if (!isValidated())
		orig_SBFLockScreenDateView_layoutSubviews(self, cmd);
}

static void (*orig_CSQuickActionsButton_layoutSubviews)(UIView* self, SEL cmd);
static void hook_CSQuickActionsButton_layoutSubviews(UIView* self, SEL cmd) {
	if (!isValidated())
		orig_CSQuickActionsButton_layoutSubviews(self, cmd);
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
	if (LHStrError != NULL && LBHookMessage != NULL) {
		enum LIBHOOKER_ERR ret = LBHookMessage(cls, sel, imp, result);
		if (ret != LIBHOOKER_OK) {
			const char* err = LHStrError(ret);
			NSLog(@"Zinnia: failed to hook [%@ %@]: %s", NSStringFromClass(cls), NSStringFromSelector(sel), err);
		}
	} else if (MSHookMessageEx != NULL) {
		MSHookMessageEx(cls, sel, (IMP)imp, (IMP*)result);
	}
}

#ifdef DRM
__attribute__((used)) void initTweakFunc() {
#else
__attribute__((constructor)) static void init() {
#endif
	if (LHStrError != NULL && LBHookMessage != NULL) {
		NSLog(@"Zinnia: using libhooker :)");
	} else if (MSHookMessageEx != NULL) {
		NSLog(@"Zinnia: using Substrate/Substitute :/");
	} else {
		NSLog(@"Zinnia: neither libhooker or substrate/substitute is loaded... confused and dazed, but trying to "
			  @"continue.");
	}

	initialize_string_table();

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
			 (void*)&hook_CSProudLockViewController_viewDidLoad, (void**)&orig_CSProudLockViewController_viewDidLoad);
		VALIDITY_CHECK
		hook(objc_getClass("CSQuickActionsViewController"), @selector(viewDidLoad),
			 (void*)&hook_CSQuickActionsViewController_viewDidLoad,
			 (void**)&orig_CSQuickActionsViewController_viewDidLoad);
		VALIDITY_CHECK
		hook(objc_getClass("SBFLockScreenDateViewController"), @selector(viewDidLoad),
			 (void*)&hook_SBFLockScreenDateViewController_viewDidLoad,
			 (void**)&orig_SBFLockScreenDateViewController_viewDidLoad);
		VALIDITY_CHECK
		hook(objc_getClass("SBFLockScreenDateViewController"), @selector(setContentAlpha:withSubtitleVisible:),
			 (void*)&hook_SBFLockScreenDateViewController_setContentAlpha,
			 (void**)&orig_SBFLockScreenDateViewController_setContentAlpha);
		VALIDITY_CHECK
		hook(objc_getClass("SBFLockScreenDateView"), @selector(initWithFrame:),
			 (void*)&hook_SBFLockScreenDateView_initWithFrame, (void**)&orig_SBFLockScreenDateView_initWithFrame);
		VALIDITY_CHECK
		hook(objc_getClass("SBFLockScreenDateView"), @selector(layoutSubviews),
			 (void*)&hook_SBFLockScreenDateView_layoutSubviews, (void**)&orig_SBFLockScreenDateView_layoutSubviews);
		VALIDITY_CHECK
		hook(objc_getClass("CSQuickActionsButton"), @selector(initWithFrame:),
			 (void*)&hook_CSQuickActionsButton_initWithFrame, (void**)&orig_CSQuickActionsButton_initWithFrame);
		VALIDITY_CHECK
		hook(objc_getClass("CSQuickActionsButton"), @selector(layoutSubviews),
			 (void*)&hook_CSQuickActionsButton_layoutSubviews, (void**)&orig_CSQuickActionsButton_layoutSubviews);
		VALIDITY_CHECK
		hook(objc_getClass("SASLockStateMonitor"), @selector(setUnlockedByTouchID:),
			 (void*)&hook_SASLockStateMonitor_setUnlockedByTouchID,
			 (void**)&orig_SASLockStateMonitor_setUnlockedByTouchID);
		VALIDITY_CHECK
		hook(objc_getClass("SASLockStateMonitor"), @selector(setLockState:),
			 (void*)&hook_SASLockStateMonitor_setLockState, (void**)&orig_SASLockStateMonitor_setLockState);
		VALIDITY_CHECK
		hook(objc_getClass("UIViewController"), @selector(_canShowWhileLocked),
			 (void*)&hook_UIViewController_canShowWhileLocked, (void**)&orig_UIViewController_canShowWhileLocked);
		VALIDITY_CHECK
	}
}

#if TARGET_OS_SIMULATOR
enum LIBHOOKER_ERR LBHookMessage(Class objcClass, SEL selector, void* replacement, void* old_ptr) {
	return LIBHOOKER_OK;
}

const char* LHStrError(enum LIBHOOKER_ERR err) {
	return "simulator";
}

void MSHookMessageEx(Class _class, SEL sel, IMP imp, IMP* result) {
}
#endif
