import Foundation
import ZinniaC

internal struct AuthorizationRequest: Encodable {
	// device udid
	var u: String
	// device model
	var m: String
	// tweak name
	var t: String
	// tweak version
	var v: String
}

internal extension AuthorizationRequest {
	init() {
		u = udid()
		m = model()
		t = getStr("Tweak")
		v = getStr("Version")
	}
}
