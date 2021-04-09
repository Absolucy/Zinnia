/*
 import Foundation
 import Orion
 import ZinniaC

 extension Backends {
 	struct Libhooker: Backend {
 		init() {}
 	}
 }

 extension Backends.Libhooker {
 	func apply(descriptors: [HookDescriptor]) {
 		descriptors.forEach {
 			switch $0 {
 			case let .method(cls, sel, replacement, completion):
 				var old: IMP?
 				let lh_status = LBHookMessage(cls, sel, replacement, &old)
 				let method = "\(class_isMetaClass(cls) ? "+" : "-")[\(cls) \(sel)]"
 				if lh_status != LIBHOOKER_OK {
 					let error = String(validatingUTF8: LHStrError(lh_status))!
 					orionError("Zinnia: Could not hook method \(method): \(error)")
 				}
 				guard let unwrapped = old else {
 					orionError("Zinnia: Could not hook method \(method)")
 				}
 				completion(.init(unwrapped))
 			default:
 				orionError("Zinnia: this should NOT happen, we only hook objc methods")
 			}
 		}
 	}
 }
 */
