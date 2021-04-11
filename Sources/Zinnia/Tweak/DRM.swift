import ZinniaC
import Foundation
import CryptoKit

internal class ZinniaDRM {
	static let instance = ZinniaDRM()
	
	var ticket: AuthorizationTicket? = AuthorizationTicket()
	
	func downloadTicket(_ callback: @escaping (Bool) -> Void) {
		let authRequest = AuthorizationRequest()
		
		var request = URLRequest(url: URL(string: server_url()!)!)
		request.httpMethod = "POST"
		request.timeoutInterval = 30
		request.httpBody = try! JSONEncoder().encode(authRequest)
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			guard let data = data, error == nil else {
				NSLog(error?.localizedDescription ?? "No data")
				callback(false)
				return
			}
			guard let ticket = try? JSONDecoder().decode(AuthorizationTicket.self, from: data) else {
				callback(false)
				return
			}
			if ticket.isValid() {
				self.ticket = ticket
				callback(true)
			}
		}.resume()
	}
	
	func authorizeTicket() -> Bool {
		self.ticket = AuthorizationTicket()
		if let ticket = self.ticket {
			return ticket.isValid()
		} else {
			return false
		}
	}
}

internal func sealBox(_ data: Data) -> ChaChaPoly.SealedBox {
	let key = SymmetricKey.init(data: getDeviceKey()!)
	let ad = getDeviceAD()!
	return try! ChaChaPoly.seal(data, using: key, authenticating: ad)
}

internal func openBox(_ box: ChaChaPoly.SealedBox) -> Data {
	let key = SymmetricKey.init(data: getDeviceKey()!)
	let ad = getDeviceAD()!
	return try! ChaChaPoly.open(box, using: key, authenticating: ad)
}

internal struct AuthorizationRequest: Encodable {
	// random UUID
	var id = UUID()
	// creation time
	var t = UInt64(Date().timeIntervalSince1970)
	// device udid
	var u: String = udid()!
	// device model
	var m: String = model()!
}

internal struct AuthorizationTicket: Codable {
	// random uuid
	var id: UUID
	// device udid
	var u: String
	// device model
	var m: String
	// time issued (seconds since unix epoch)
	var i: UInt64
	// time expired (seconds since unix epoch)
	var e: UInt64
	// ed25519 signature
	var s: Data
}

internal extension AuthorizationTicket {
	init?() {
		prepareGoldenTicket()
		guard let encryptedTicket = try? Data(contentsOf: URL(fileURLWithPath: golden_ticket()!)),
			  let sealedTicket = try? ChaChaPoly.SealedBox(combined: encryptedTicket),
			  let ticket = try? JSONDecoder().decode(AuthorizationTicket.self, from: openBox(sealedTicket)) else { return nil }
		self = ticket
	}
	
	func save() {
		prepareGoldenTicket()
		guard let json = try? JSONEncoder().encode(self) else { return }
		let sealedBox = sealBox(json)
		try? sealedBox.combined.write(to: URL(fileURLWithPath: golden_ticket()!))
	}
	
	func daysLeft() -> Int {
		let now = Date()
		let expiry = Date(timeIntervalSince1970: TimeInterval(e))
		return Calendar.current.dateComponents([.day], from: now, to: expiry).day ?? 0
	}
	
	func isValid() -> Bool {
		let publicKey = try! Curve25519.Signing.PublicKey(rawRepresentation: pubkey()!)
		var data = Data(capacity: 32 + u.count + m.count)
		withUnsafePointer(to: id) {
			data.append(Data(bytes: $0, count: MemoryLayout.size(ofValue: id)))
		}
		data.append(self.u.data(using: .utf8)!)
		data.append(self.m.data(using: .utf8)!)
		withUnsafePointer(to: self.i) {
			data.append(Data(bytes: $0, count: MemoryLayout.size(ofValue: i)))
		}
		withUnsafePointer(to: self.e) {
			data.append(Data(bytes: $0, count: MemoryLayout.size(ofValue: e)))
		}
		for i in 0 ..< data.count {
			data[i] ^= 42
		}
		let now = UInt64(Date().timeIntervalSince1970)
		return publicKey.isValidSignature(self.s, for: data) && now >= self.i && now < self.e
	}
}

internal func prepareGoldenTicket() {
	let path = golden_ticket_folder()!
	var isDir: ObjCBool = false
	let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
	if !exists || !isDir.boolValue {
		do {
			try FileManager.default.removeItem(atPath: path)
		} catch {}
		do {
			try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
		} catch {}
	}
}
