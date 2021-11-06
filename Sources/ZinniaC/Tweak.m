//  Copyright (c) 2021 Lucy <lucy@absolucy.moe>
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#ifdef THEOS_SWIFT
#import "Zinnia-Swift.h"
#endif
#import "include/Hook.h"
#import "include/Tweak.h"

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

	if (!popups) {
		popups = makeUnlockPopups();
		popups.view.backgroundColor = UIColor.clearColor;
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

	popups.view.frame = self.view.frame;
	[self addChildViewController:popups];
	[self.view addSubview:popups.view];
	popups.view.translatesAutoresizingMaskIntoConstraints = false;
	[NSLayoutConstraint activateConstraints:@[
		[popups.view.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
		[popups.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
	]];
	[popups didMoveToParentViewController:self];

	unlockButton.view.frame = self.view.frame;
	[self addChildViewController:unlockButton];
	[self.view addSubview:unlockButton.view];
	unlockButton.view.translatesAutoresizingMaskIntoConstraints = false;
	[NSLayoutConstraint activateConstraints:@[
		[unlockButton.view.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
		[unlockButton.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
	]];
	[unlockButton didMoveToParentViewController:self];

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

static bool (*orig_UIViewController_canShowWhileLocked)(UIViewController* self, SEL cmd);
static bool hook_UIViewController_canShowWhileLocked(UIViewController* self, SEL cmd) {
	return true;
}

static void (*orig_CSProudLockViewController_viewDidLoad)(UIViewController* self, SEL cmd);
static void hook_CSProudLockViewController_viewDidLoad(UIViewController* self, SEL cmd) {
}

static void (*orig_CSQuickActionsViewController_viewDidLoad)(UIViewController* self, SEL cmd);
static void hook_CSQuickActionsViewController_viewDidLoad(UIViewController* self, SEL cmd) {
}

static void (*orig_SBFLockScreenDateViewController_viewDidLoad)(UIViewController* self, SEL cmd);
static void hook_SBFLockScreenDateViewController_viewDidLoad(UIViewController* self, SEL cmd) {
}

static UIView* (*orig_CSQuickActionsButton_initWithFrame)(UIView* self, SEL cmd, CGRect frame);
static UIView* hook_CSQuickActionsButton_initWithFrame(UIView* self, SEL cmd, CGRect frame) {
	return orig_CSQuickActionsButton_initWithFrame(self, cmd, CGRectMake(0, 0, 0, 0));
}

static UIView* (*orig_SBFLockScreenDateView_initWithFrame)(UIView* self, SEL cmd, CGRect frame);
static UIView* hook_SBFLockScreenDateView_initWithFrame(UIView* self, SEL cmd, CGRect frame) {
	return orig_SBFLockScreenDateView_initWithFrame(self, cmd, CGRectMake(0, 0, 0, 0));
}

static void (*orig_SBFLockScreenDateViewController_setContentAlpha)(UIViewController* self, SEL cmd, double alpha,
																	bool subtitleVisible);
static void hook_SBFLockScreenDateViewController_setContentAlpha(UIViewController* self, SEL cmd, double alpha,
																 bool subtitleVisible) {
	return orig_SBFLockScreenDateViewController_setContentAlpha(self, cmd, 0.0, false);
}

static void (*orig_SBFLockScreenDateView_layoutSubviews)(UIView* self, SEL cmd);
static void hook_SBFLockScreenDateView_layoutSubviews(UIView* self, SEL cmd) {
}

static void (*orig_CSQuickActionsButton_layoutSubviews)(UIView* self, SEL cmd);
static void hook_CSQuickActionsButton_layoutSubviews(UIView* self, SEL cmd) {
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
__attribute__((constructor)) static void init() {
	if (tweakEnabled()) {
		hook(objc_getClass("CSCoverSheetViewController"), @selector(viewDidLoad),
			 (void*)&hook_CSCoverSheetViewController_viewDidLoad, (void**)&orig_CSCoverSheetViewController_viewDidLoad);
		hook(objc_getClass("CSProudLockViewController"), @selector(viewDidLoad),
			 (void*)&hook_CSProudLockViewController_viewDidLoad, (void**)&orig_CSProudLockViewController_viewDidLoad);
		hook(objc_getClass("CSQuickActionsViewController"), @selector(viewDidLoad),
			 (void*)&hook_CSQuickActionsViewController_viewDidLoad,
			 (void**)&orig_CSQuickActionsViewController_viewDidLoad);
		hook(objc_getClass("SBFLockScreenDateViewController"), @selector(viewDidLoad),
			 (void*)&hook_SBFLockScreenDateViewController_viewDidLoad,
			 (void**)&orig_SBFLockScreenDateViewController_viewDidLoad);
		hook(objc_getClass("SBFLockScreenDateViewController"), @selector(setContentAlpha:withSubtitleVisible:),
			 (void*)&hook_SBFLockScreenDateViewController_setContentAlpha,
			 (void**)&orig_SBFLockScreenDateViewController_setContentAlpha);
		hook(objc_getClass("SBFLockScreenDateView"), @selector(initWithFrame:),
			 (void*)&hook_SBFLockScreenDateView_initWithFrame, (void**)&orig_SBFLockScreenDateView_initWithFrame);
		hook(objc_getClass("SBFLockScreenDateView"), @selector(layoutSubviews),
			 (void*)&hook_SBFLockScreenDateView_layoutSubviews, (void**)&orig_SBFLockScreenDateView_layoutSubviews);
		hook(objc_getClass("CSQuickActionsButton"), @selector(initWithFrame:),
			 (void*)&hook_CSQuickActionsButton_initWithFrame, (void**)&orig_CSQuickActionsButton_initWithFrame);
		hook(objc_getClass("CSQuickActionsButton"), @selector(layoutSubviews),
			 (void*)&hook_CSQuickActionsButton_layoutSubviews, (void**)&orig_CSQuickActionsButton_layoutSubviews);
		hook(objc_getClass("SASLockStateMonitor"), @selector(setUnlockedByTouchID:),
			 (void*)&hook_SASLockStateMonitor_setUnlockedByTouchID,
			 (void**)&orig_SASLockStateMonitor_setUnlockedByTouchID);
		hook(objc_getClass("SASLockStateMonitor"), @selector(setLockState:),
			 (void*)&hook_SASLockStateMonitor_setLockState, (void**)&orig_SASLockStateMonitor_setLockState);
		hook(objc_getClass("UIViewController"), @selector(_canShowWhileLocked),
			 (void*)&hook_UIViewController_canShowWhileLocked, (void**)&orig_UIViewController_canShowWhileLocked);
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
