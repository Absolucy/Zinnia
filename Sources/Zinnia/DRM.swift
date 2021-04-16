import CryptoKit
import Foundation
import UIKit
import ZinniaC

private enum MyError: Error {
	case err(String)
}

internal struct ZinniaDRM {
	private static var ticket: AuthorizationTicket? = AuthorizationTicket()
	private static var fetchingNewTicket = false
	private static var authInProgress = false
	private static var authSemaphore = DispatchSemaphore(value: 0)
	private static var fetchSemaphore = DispatchSemaphore(value: 0)

	internal static func ticketAuthorized() -> Bool {
		#if DRM
			if authInProgress {
				authSemaphore.wait()
			}
			ticket = ticket ?? AuthorizationTicket()
			if let ticket = self.ticket, !fetchingNewTicket, !ticket.isTrial(), ticket.daysLeft() <= 5 {
				#if DEBUG
					NSLog("Zinnia: fetching new ticket, current ticket only has \(ticket.daysLeft()) days remaining")
				#endif
				defer { fetchingNewTicket = false }
				fetchingNewTicket = true
				requestTicket(visible: false)
				if case .timedOut = fetchSemaphore.wait(timeout: DispatchTime.now() + 1.3e10) {
					#if DEBUG
						NSLog("Zinnia: timed out waiting for new ticket to be fetched.")
					#endif
				}
			}
			return ticket?.isValid() ?? false
		#else
			return true
		#endif
	}

	internal static func runAuthHandler() -> (NSTask, Pipe) {
		let outPipe = Pipe()
		let inPipe = Pipe()
		let task = NSTask()!
		task.setLaunchPath(drm_path()!)
		task.standardOutput = outPipe
		task.standardInput = inPipe
		task.launch()
		#if DEBUG
			NSLog("Zinnia: launched DRM task, pid \(task.processIdentifier)")
		#endif

		task.terminationHandler = { _ in
			authSemaphore.signal()
		}

		inPipe.fileHandleForWriting.write("a".data(using: .ascii)!)
		inPipe.fileHandleForWriting.write(createCommunicationData().data(using: .ascii)!)
		inPipe.fileHandleForWriting.write("\n".data(using: .ascii)!)

		return (task, outPipe)
	}

	internal static func requestTicket(visible: Bool = true) {
		if !fetchingNewTicket, ticketAuthorized() {
			#if DEBUG
				NSLog("Zinnia: ticket is already authorized")
			#endif
			return
		}
		authInProgress = true

		if !check_for_plist() {
			if visible {
				UIAlertView(
					title: dont_panic_message(),
					message: failed_message(),
					delegate: nil,
					cancelButtonTitle: continue_without_message()
				)
				.show()
			}
			authInProgress = false
			authSemaphore.signal()
			return
		}

		let alert = visible ? UIAlertView(
			title: dont_panic_message(),
			message: ensuring_message(),
			delegate: nil,
			cancelButtonTitle: nil
		) : nil
		alert?.show()

		let (task, outPipe) = runAuthHandler()

		DispatchQueue.main.asyncAfter(deadline: .now() + (visible ? 2 : 0)) {
			defer {
				authInProgress = false
				fetchSemaphore.signal()
			}
			if case .timedOut = authSemaphore.wait(timeout: DispatchTime.now() + 1.3e10) {
				task.terminate()
				#if DEBUG
					NSLog("Zinnia: timed out waiting for ticket")
				#endif
				if !visible {
					return
				}
				alert?.dismiss(withClickedButtonIndex: 0, animated: false)
				#if DEBUG
					UIAlertView(
						title: dont_panic_message(),
						message: "timed out",
						delegate: nil,
						cancelButtonTitle: continue_without_message()
					)
					.show()
				#else
					UIAlertView(
						title: dont_panic_message(),
						message: drm_down_message(),
						delegate: nil,
						cancelButtonTitle: continue_without_message()
					)
					.show()
				#endif
				return
			}

			if task.terminationStatus == 0 {
				let output = outPipe.fileHandleForReading.readDataToEndOfFile()
				#if DEBUG
					NSLog("Zinnia: got output from DRM task:\n\(String(data: output, encoding: .utf8)!)")
				#endif
				if let ticket = try? JSONDecoder().decode(AuthorizationTicket.self, from: output) {
					if ticket.isValid() {
						ticket.save()
						self.ticket = ticket
						#if DEBUG
							NSLog("Zinnia: saved ticket")
						#endif
						if !visible {
							return
						}
						alert?.message = String(format: success_message(), 3)
						DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
							alert?.message = String(format: success_message(), 2)
						}
						DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
							alert?.message = String(format: success_message(), 1)
						}
						DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
							let sbreload = NSTask()!
							sbreload.setLaunchPath(sbreload_path()!)
							sbreload.launch()
							// just in case sbreload screws up somehow
							alert?.dismiss(withClickedButtonIndex: 0, animated: false)
							sbreload.waitUntilExit()
						}
					} else {
						if !visible {
							return
						}
						alert?.dismiss(withClickedButtonIndex: 0, animated: false)
						#if DEBUG
							UIAlertView(
								title: dont_panic_message(),
								message: "invalid ticket??",
								delegate: nil,
								cancelButtonTitle: continue_without_message()
							)
							.show()
						#else
							UIAlertView(
								title: dont_panic_message(),
								message: failed_message(),
								delegate: nil,
								cancelButtonTitle: continue_without_message()
							)
							.show()
						#endif
					}
				} else {
					if !visible {
						return
					}
					alert?.dismiss(withClickedButtonIndex: 0, animated: false)
					#if DEBUG
						UIAlertView(
							title: dont_panic_message(),
							message: "ticket didn't decode",
							delegate: nil,
							cancelButtonTitle: continue_without_message()
						)
						.show()
					#else
						UIAlertView(
							title: dont_panic_message(),
							message: drm_down_message(),
							delegate: nil,
							cancelButtonTitle: continue_without_message()
						)
						.show()
					#endif
				}
			} else {
				if !visible {
					return
				}
				alert?.dismiss(withClickedButtonIndex: 0, animated: false)
				#if DEBUG
					UIAlertView(
						title: dont_panic_message(),
						message: "DRM returned non-zero status \(task.terminationStatus)",
						delegate: nil,
						cancelButtonTitle: continue_without_message()
					).show()
				#else
					if task.terminationStatus == 7 {
						UIAlertView(title: dont_panic_message(), message: failed_message(), delegate: nil,
						            cancelButtonTitle: continue_without_message()).show()
					} else {
						UIAlertView(title: dont_panic_message(), message: drm_down_message(), delegate: nil,
						            cancelButtonTitle: continue_without_message()).show()
					}
				#endif
			}
		}
	}

	private static func createCommunicationData() -> String {
		var key = randomBytes(32)!
		let keyXor = randomBytes(32)!
		var udidNonce = randomBytes(12)!
		var modelNonce = randomBytes(12)!
		let nonceXor = randomBytes(12)!
		NSLog("Zinnia: udid is \(udid()!)")
		let udidData = udid()!.data(using: .ascii)!
		let modelData = model()!.data(using: .ascii)!
		guard let encryptedUdid = try? ChaChaPoly.seal(
			udidData,
			using: SymmetricKey(data: key),
			nonce: ChaChaPoly.Nonce(data: udidNonce)
		) else { return "" }
		guard let encryptedModel = try? ChaChaPoly.seal(
			modelData,
			using: SymmetricKey(data: key),
			nonce: ChaChaPoly.Nonce(data: modelNonce)
		) else { return "" }
		var output = Data(capacity: 32 + 32 + 12 + 12 + encryptedUdid.ciphertext.count + encryptedUdid.tag
			.count + encryptedModel.ciphertext.count + encryptedModel.tag.count + MemoryLayout<UInt64>
			.size + MemoryLayout<UInt64>.size
			+ 15 + 5 + 3 + 30 + 30 + 30 + 29 + 29 + 29 + 29 + 4)
		// the \x2A\x2A\x2A\x2A magic
		output.append(contentsOf: [42, 42, 42, 42])
		// _a1
		output.append(randomBytes(15)!)
		// key_xor
		output.append(keyXor)
		// key
		for i in 0 ..< 32 {
			key[i] = key[i] ^ keyXor[i]
		}
		output.append(key)
		// _a2
		output.append(randomBytes(5)!)
		// nonce_xor
		output.append(nonceXor)
		// _a3
		output.append(randomBytes(3)!)
		// udid_nonce
		for i in 0 ..< 12 {
			udidNonce[i] = udidNonce[i] ^ nonceXor[i]
		}
		output.append(udidNonce)
		// _a4, _a5
		output.append(randomBytes(60)!)
		// _udid_size
		var udidSize = UInt64(encryptedUdid.ciphertext.count + encryptedUdid.tag.count).littleEndian
		withUnsafeBytes(of: &udidSize) {
			output.append(contentsOf: $0)
		}
		// _a6
		output.append(randomBytes(30)!)
		// udid
		output.append(encryptedUdid.ciphertext)
		output.append(encryptedUdid.tag)
		// _model_size
		var modelSize = UInt64(encryptedModel.ciphertext.count + encryptedModel.tag.count).littleEndian
		withUnsafeBytes(of: &modelSize) {
			output.append(contentsOf: $0)
		}
		// _a7, _a8, _a9
		output.append(randomBytes(29 * 3)!)
		// model
		output.append(encryptedModel.ciphertext)
		output.append(encryptedModel.tag)
		// _a10
		output.append(randomBytes(29)!)
		// model_nonce
		for i in 0 ..< 12 {
			modelNonce[i] = modelNonce[i] ^ nonceXor[i]
		}
		output.append(modelNonce)
		return output.base64EncodedString()
	}
}

internal func sealBox(_ data: Data) -> ChaChaPoly.SealedBox? {
	let key = SymmetricKey(data: getDeviceKey()!)
	let ad = getDeviceAD()!
	return try? ChaChaPoly.seal(data, using: key, authenticating: ad)
}

internal func openBox(_ box: ChaChaPoly.SealedBox) -> Data? {
	let key = SymmetricKey(data: getDeviceKey()!)
	let ad = getDeviceAD()!
	return try? ChaChaPoly.open(box, using: key, authenticating: ad)
}

internal struct AuthorizationTicket {
	// random uuid
	var x: UUID
	// time issued (seconds since unix epoch)
	var i: Date
	// time expired (seconds since unix epoch)
	var e: Date
	// bitflags relating to the ticket
	var f: UInt8
	// ed25519 signature
	var s: Data

	enum CodingKeys: String, CodingKey {
		case x
		case i
		case e
		case f
		case s
	}
}

extension AuthorizationTicket: Encodable {
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(x, forKey: .x)

		let formatter = DateFormatter()
		formatter.calendar = Calendar(identifier: .iso8601)
		formatter.locale = Locale(identifier: date_locale()!)
		formatter.timeZone = TimeZone(secondsFromGMT: 0)
		formatter.dateFormat = date_format()!

		try container.encode(formatter.string(from: i), forKey: .i)
		try container.encode(formatter.string(from: e), forKey: .e)
		try container.encode(f, forKey: .f)
		try container.encode([UInt8](s), forKey: .s)
	}
}

extension AuthorizationTicket: Decodable {
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)

		x = try values.decode(UUID.self, forKey: .x)

		let formatter = DateFormatter()
		formatter.calendar = Calendar(identifier: .iso8601)
		formatter.locale = Locale(identifier: date_locale()!)
		formatter.timeZone = TimeZone(secondsFromGMT: 0)
		formatter.dateFormat = date_format()!

		guard let issued = formatter.date(from: try values.decode(String.self, forKey: .i))
		else { throw MyError.err("issued was not date") }
		i = issued

		guard let expiry = formatter.date(from: try values.decode(String.self, forKey: .e))
		else { throw MyError.err("expiry was not date") }
		e = expiry

		f = try values.decode(UInt8.self, forKey: .f)
		s = Data(try values.decode([UInt8].self, forKey: .s))
	}
}

internal extension AuthorizationTicket {
	init?() {
		prepareGoldenTicket()
		guard let encryptedTicket = try? Data(contentsOf: URL(fileURLWithPath: golden_ticket()!)),
		      let sealedTicket = try? ChaChaPoly.SealedBox(combined: encryptedTicket),
		      let unsealedTicket = openBox(sealedTicket),
		      let ticket = try? JSONDecoder().decode(AuthorizationTicket.self, from: unsealedTicket)
		else { return nil }
		self = ticket
	}

	func save() {
		prepareGoldenTicket()
		guard let json = try? JSONEncoder().encode(self),
		      let sealedBox = sealBox(json) else { return }
		try? sealedBox.combined.write(to: URL(fileURLWithPath: golden_ticket()!))
	}

	func daysLeft() -> Int {
		let now = Date()
		return Calendar.current.dateComponents([.day], from: now, to: e).day ?? 0
	}

	func isTrial() -> Bool {
		(f & (1 << 0)) == 1
	}

	func isValid() -> Bool {
		let publicKey = try! Curve25519.Signing.PublicKey(rawRepresentation: pubkey()!)
		var data = Data(capacity: 16 + MemoryLayout<UInt64>.size + MemoryLayout<UInt64>.size)

		// Serialize the UUID into our data
		withUnsafePointer(to: x) {
			data.append(Data(bytes: $0, count: MemoryLayout.size(ofValue: x)))
		}
		// Serialize UDID, model, and tweak name into the data next
		data.append(udid()!.data(using: .utf8)!)
		data.append(model()!.data(using: .utf8)!)
		data.append(tweakName()!.uppercased().data(using: .utf8)!)
		// Convert issued/expired dates to seconds, then serialize them into our data
		data.append(UInt64(i.timeIntervalSince1970).littleEndian.data)
		data.append(UInt64(e.timeIntervalSince1970).littleEndian.data)
		// Serialize the bitflag
		data.append(f.littleEndian.data)
		// XOR all data by 42
		for i in 0 ..< data.count {
			data[i] ^= 42
		}
		let now = Date()
		// Now we check the signature's validity!
		return publicKey.isValidSignature(s, for: data) && now >= i && now < e
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

internal extension FixedWidthInteger {
	var data: Data {
		let data = withUnsafeBytes(of: self) { Data($0) }
		return data
	}
}
