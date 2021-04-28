import CryptoKit
import Foundation
import ZinniaC

internal func sealBox(_ data: Data) -> ChaChaPoly.SealedBox? {
	let key = SymmetricKey(data: getDeviceKey())
	let ad = getDeviceAD()
	NSLog("Zinnia: key is \(getDeviceKey()), ad is \(ad)")
	return try? ChaChaPoly.seal(data, using: key, authenticating: ad)
}

internal func openBox(_ box: ChaChaPoly.SealedBox) -> Data? {
	let key = SymmetricKey(data: getDeviceKey())
	let ad = getDeviceAD()
	NSLog("Zinnia: key is \(key), ad is \(ad)")
	return try? ChaChaPoly.open(box, using: key, authenticating: ad)
}
