import CommonCrypto
import Foundation
import ZinniaC

private func blake3(_ data: Data) -> Data {
	var hash = [UInt8](repeating: 0, count: Int(BLAKE3_OUT_LEN))
	data.withUnsafeBytes { bytes in
		var hasher = blake3_hasher()
		blake3_hasher_init(&hasher)
		blake3_hasher_update(&hasher, bytes.baseAddress!, data.count)
		blake3_hasher_finalize(&hasher, &hash, Int(BLAKE3_OUT_LEN))
	}
	return Data(hash)
}

internal class PinningDelegate: NSObject, URLSessionDelegate {
	private static let eccAsn1Header = getData(33)
	private static let pubkey = getData(17)

	func urlSession(_: URLSession,
	                didReceive challenge: URLAuthenticationChallenge,
	                completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
	{
		guard let serverTrust = challenge.protectionSpace.serverTrust else {
			completionHandler(.cancelAuthenticationChallenge, nil)
			return
		}

		// Set SSL policies for domain name check
		let policies = NSMutableArray()
		policies.add(SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString))
		SecTrustSetPolicies(serverTrust, policies)

		var isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)

		if isServerTrusted, challenge.protectionSpace.host == getStr(32) {
			let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)
			let policy = SecPolicyCreateBasicX509()
			let cfCertificates = [certificate] as CFArray

			var trust: SecTrust?
			SecTrustCreateWithCertificates(cfCertificates, policy, &trust)

			guard trust != nil, let pubKey = SecTrustCopyKey(trust!) else {
				#if DEBUG
					NSLog("Zinnia: failed SecTrustCopyKey crap")
				#endif
				completionHandler(.cancelAuthenticationChallenge, nil)
				return
			}

			var error: Unmanaged<CFError>?
			if let pubKeyData = SecKeyCopyExternalRepresentation(pubKey, &error) {
				var keyWithHeader = Data(PinningDelegate.eccAsn1Header)
				keyWithHeader.append(pubKeyData as Data)
				let b3Key = blake3(keyWithHeader)
				if PinningDelegate.pubkey != b3Key {
					isServerTrusted = false
				}
			} else {
				isServerTrusted = false
			}
		}

		if isServerTrusted {
			let credential = URLCredential(trust: serverTrust)
			completionHandler(.useCredential, credential)
		} else {
			completionHandler(.cancelAuthenticationChallenge, nil)
		}
	}
}
