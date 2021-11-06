//  Copyright (c) 2021 Lucy <lucy@absolucy.moe>
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

#import "include/Hook.h"
#import <Foundation/Foundation.h>
#import <dlfcn.h>

enum LIBHOOKER_ERR
{
	LIBHOOKER_OK = 0,
	LIBHOOKER_ERR_SELECTOR_NOT_FOUND = 1,
	LIBHOOKER_ERR_SHORT_FUNC = 2,
	LIBHOOKER_ERR_BAD_INSN_AT_START = 3,
	LIBHOOKER_ERR_VM = 4,
	LIBHOOKER_ERR_NO_SYMBOL = 5
};

static enum LIBHOOKER_ERR (*LBHookMessage)(Class class, SEL sel, void* replacement, void* old_ptr);
static const char* (*LHStrError)(enum LIBHOOKER_ERR err);
static void (*HookMessageEx)(Class class, SEL sel, IMP imp, IMP* result);

static void* libhooker;
static void* libblackjack;
static void* substrate;
static void* substitute;

void setupHookingLib() {
	// bender's favorite dlopen!
	if ((libblackjack = dlopen("/usr/lib/libblackjack.dylib", RTLD_LAZY)) != NULL &&
		(libhooker = dlopen("/usr/lib/libhooker.dylib", RTLD_LAZY)) != NULL)
	{
		if ((LBHookMessage = dlsym(libblackjack, "LBHookMessage")) != NULL &&
			(LHStrError = dlsym(libhooker, "LHStrError")) != NULL)
		{
			NSLog(@"[Zinnia] using libhooker :)");
			return;
		}
		// Failed to get the proper symbols, clean up
		LBHookMessage = NULL;
		LHStrError = NULL;
		if (libhooker) {
			dlclose(libhooker);
			libhooker = NULL;
		}
		if (libblackjack) {
			dlclose(libblackjack);
			libblackjack = NULL;
		}
	}
	if ((substitute = dlopen("/usr/lib/libsubstitute.dylib", RTLD_LAZY)) != NULL) {
		if ((HookMessageEx = dlsym(substitute, "SubHookMessageEx")) != NULL) {
			NSLog(@"[Zinnia] using Substitute");
			return;
		}
		// Failed to get the proper symbols, clean up
		HookMessageEx = NULL;
		if (substitute) {
			dlclose(substitute);
			substitute = NULL;
		}
	}
	if ((substrate = dlopen("/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate", RTLD_LAZY)) != NULL) {
		if ((HookMessageEx = dlsym(substrate, "MSHookMessageEx")) != NULL) {
			NSLog(@"[Zinnia] using Substrate");
			return;
		}
		// Failed to get the proper symbols, clean up
		HookMessageEx = NULL;
		if (substrate) {
			dlclose(substrate);
			substrate = NULL;
		}
	}
	NSLog(@"[Zinnia] failed to load hooking library");
}

void hook(Class cls, SEL sel, void* imp, void** result) {
	if (!(LBHookMessage && LHStrError) && !HookMessageEx)
		setupHookingLib();
	if (LBHookMessage && LHStrError) {
		enum LIBHOOKER_ERR ret = LBHookMessage(cls, sel, imp, result);
		if (ret != LIBHOOKER_OK) {
			const char* err = LHStrError(ret);
			NSLog(@"[Zinnia] failed to hook -[%@ %@]: %s", NSStringFromClass(cls), NSStringFromSelector(sel), err);
		}
	} else if (HookMessageEx) {
		HookMessageEx(cls, sel, imp, (IMP*)result);
	} else {
		NSLog(@"[Zinnia] no hooking library present???");
	}
}
