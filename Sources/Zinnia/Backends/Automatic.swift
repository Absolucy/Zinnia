//
//  File.swift
//
//
//  Created by Aspen on 3/23/21.
//

import Foundation
import Orion

public extension Backends {
	struct Automatic: Backend {
		var backend: Backend
		public init() {
			if dlopen("/usr/lib/libhooker.dylib", RTLD_NOW) != nil && dlopen("/usr/lib/libblackjack.dylib", RTLD_NOW) != nil {
				NSLog("Zinnia: using libhooker :)")
				self.backend = Libhooker()
			} else if dlopen("/usr/lib/libsubstrate.dylib", RTLD_NOW) != nil {
				NSLog("Zinnia: using Substrate/Substitute :/")
				self.backend = Substrate()
			} else {
				orionError("Zinnia: no hooking backend found. how did you even load this?")
			}
		}
	}
}

public extension Backends.Automatic {
	func apply(descriptors: [HookDescriptor]) {
		backend.apply(descriptors: descriptors)
	}
}
