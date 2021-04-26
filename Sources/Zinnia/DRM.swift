import CryptoKit
import Foundation
import UIKit
import ZinniaC

private enum MyError: Error {
	case err(String)
}

internal struct ZinniaDRM {
	internal static var ticket: AuthorizationTicket? = AuthorizationTicket()
	private static var fetchingNewTicket = false
	private static var authInProgress = false
	private static var authSemaphore = DispatchSemaphore(value: 0)
	private static var ticketCooldown = false

	internal static func ticketAuthorized() -> Bool {
		#if DRM
			if authInProgress, !fetchingNewTicket {
				authSemaphore.wait()
			}
			ticket = ticket ?? AuthorizationTicket()
			if let ticket = self.ticket, !ticketCooldown, !fetchingNewTicket, !ticket.isTrial(), ticket.daysLeft() <= 5 {
				#if DEBUG
					NSLog("Zinnia: fetching new ticket, current ticket only has \(ticket.daysLeft()) days remaining")
				#endif
				ticketCooldown = true
				DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1800) {
					ticketCooldown = false
				}
				if ticket.isSignatureValid() {
					var myThread: pthread_t?
					func thread(_: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? {
						if ZinniaDRM.fetchingNewTicket {
							return nil
						}
						ZinniaDRM.fetchingNewTicket = true
						#if DEBUG
							NSLog("Zinnia: updating ticket from new thread")
						#endif
						ZinniaDRM.silentlyUpdateTicket()
						ZinniaDRM.fetchingNewTicket = false
						return nil
					}
					if ticket.validTime() {
						pthread_create(&myThread, nil, thread, nil)
					} else {
						requestTicket()
					}
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
		#if DEBUG
			let errPipe = Pipe()
		#endif
		let task = NSTask()!
		task.setLaunchPath(getStr(8))
		task.standardOutput = outPipe
		task.standardInput = inPipe
		#if DEBUG
			task.standardError = errPipe
		#endif
		task.launch()
		#if DEBUG
			NSLog("Zinnia: launched DRM task, PID \(task.processIdentifier)")
		#endif

		task.terminationHandler = { _ in
			#if DEBUG
				NSLog("Zinnia: DRM handler (PID \(task.processIdentifier)) exited with status \(task.terminationStatus)")
				NSLog(
					"Zinnia: DRM handler (PID \(task.processIdentifier)) stderr: \(String(data: errPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)!)"
				)
			#endif
			authSemaphore.signal()
		}

		inPipe.fileHandleForWriting.write("a".data(using: .ascii)!)
		inPipe.fileHandleForWriting.write(createCommunicationData().data(using: .ascii)!)
		inPipe.fileHandleForWriting.write("\n".data(using: .ascii)!)

		return (task, outPipe)
	}

	internal static func silentlyUpdateTicket() {
		authInProgress = true
		defer {
			authInProgress = false
		}
		let (task, outPipe) = runAuthHandler()
		task.waitUntilExit()
		if task.terminationStatus != 0 {
			#if DEBUG
				NSLog("Zinnia: silent ticket update failed with status \(task.terminationStatus)")
			#endif
			return
		}
		let output = outPipe.fileHandleForReading.readDataToEndOfFile()
		#if DEBUG
			NSLog("Zinnia: got output from DRM task:\n\(String(data: output, encoding: .utf8)!)")
		#endif
		guard let ticket = try? JSONDecoder().decode(AuthorizationTicket.self, from: output), ticket.isValid() else { return }
		ticket.save()
		self.ticket = ticket
		#if DEBUG
			NSLog("Zinnia: updated with new ticket")
		#endif
	}

	internal static func requestTicket() {
		authInProgress = true

		if !check_for_plist() {
			UIAlertView(
				title: getStr(0),
				message: getStr(2),
				delegate: nil,
				cancelButtonTitle: getStr(5)
			)
			.show()
			authInProgress = false
			authSemaphore.signal()
			return
		}

		#if TRIAL
			let alert = UIAlertView(
				title: getStr(0),
				message: getStr(13),
				delegate: nil,
				cancelButtonTitle: nil
			)
		#else
			let alert = UIAlertView(
				title: getStr(0),
				message: getStr(1),
				delegate: nil,
				cancelButtonTitle: nil
			)
		#endif

		alert.show()

		let (task, outPipe) = runAuthHandler()

		DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
			defer {
				authInProgress = false
			}
			if case .timedOut = authSemaphore.wait(timeout: DispatchTime.now() + 5) {
				task.terminate()
				#if DEBUG
					NSLog("Zinnia: timed out waiting for ticket")
				#endif
				alert.dismiss(withClickedButtonIndex: 0, animated: false)
				#if DEBUG
					UIAlertView(
						title: getStr(0),
						message: "timed out",
						delegate: nil,
						cancelButtonTitle: getStr(5)
					)
					.show()
				#else
					UIAlertView(
						title: getStr(0),
						message: getStr(3),
						delegate: nil,
						cancelButtonTitle: getStr(5)
					)
					.show()
				#endif
				return
			}

			let output = outPipe.fileHandleForReading.readDataToEndOfFile()
			#if DEBUG
				NSLog("Zinnia: got output from DRM task:\n\(String(data: output, encoding: .utf8)!)")
			#endif
			if task.terminationStatus == 0 {
				if let ticket = try? JSONDecoder().decode(AuthorizationTicket.self, from: output) {
					if ticket.isValid() {
						ticket.save()
						self.ticket = ticket
						#if DEBUG
							NSLog("Zinnia: saved ticket")
						#endif
						alert.message = String(format: getStr(4), 3)
						DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
							alert.message = String(format: getStr(4), 2)
						}
						DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
							alert.message = String(format: getStr(4), 1)
						}
						DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
							let sbreload = NSTask()!
							sbreload.setLaunchPath(getStr(9))
							sbreload.launch()
							// just in case sbreload screws up somehow
							alert.dismiss(withClickedButtonIndex: 0, animated: false)
							sbreload.waitUntilExit()
						}
					} else {
						alert.dismiss(withClickedButtonIndex: 0, animated: false)
						#if DEBUG
							UIAlertView(
								title: getStr(0),
								message: "invalid ticket??",
								delegate: nil,
								cancelButtonTitle: getStr(5)
							)
							.show()
						#else
							UIAlertView(
								title: getStr(0),
								message: getStr(2),
								delegate: nil,
								cancelButtonTitle: getStr(5)
							)
							.show()
						#endif
					}
				} else {
					alert.dismiss(withClickedButtonIndex: 0, animated: false)
					#if DEBUG
						UIAlertView(
							title: getStr(0),
							message: "ticket didn't decode",
							delegate: nil,
							cancelButtonTitle: getStr(5)
						)
						.show()
					#else
						UIAlertView(
							title: getStr(0),
							message: getStr(3),
							delegate: nil,
							cancelButtonTitle: getStr(5)
						)
						.show()
					#endif
				}
			} else {
				alert.dismiss(withClickedButtonIndex: 0, animated: false)
				#if DEBUG
					UIAlertView(
						title: getStr(0),
						message: "DRM returned non-zero status \(task.terminationStatus)",
						delegate: nil,
						cancelButtonTitle: getStr(5)
					).show()
				#else
					if task.terminationStatus == 7 {
						#if TRIAL
							UIAlertView(title: getStr(0), message: getStr(14), delegate: nil,
							            cancelButtonTitle: getStr(5)).show()
						#else
							UIAlertView(title: getStr(0), message: getStr(2), delegate: nil,
							            cancelButtonTitle: getStr(5)).show()
						#endif
					} else {
						UIAlertView(title: getStr(0), message: getStr(3), delegate: nil,
						            cancelButtonTitle: getStr(5)).show()
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
		formatter.locale = Locale(identifier: getStr(7))
		formatter.timeZone = TimeZone(secondsFromGMT: 0)
		formatter.dateFormat = getStr(6)

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
		formatter.locale = Locale(identifier: getStr(7))
		formatter.timeZone = TimeZone(secondsFromGMT: 0)
		formatter.dateFormat = getStr(6)

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
		guard let encryptedTicket = try? Data(contentsOf: URL(fileURLWithPath: getStr(11))),
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
		try? sealedBox.combined.write(to: URL(fileURLWithPath: getStr(11)))
	}

	func daysLeft() -> Int {
		let now = Date()
		return Calendar.current.dateComponents([.day], from: now, to: e).day ?? 0
	}

	func minutesLeft() -> Int {
		let now = Date()
		return Calendar.current.dateComponents([.minute], from: now, to: e).minute ?? 0
	}

	func isTrial() -> Bool {
		(f & (1 << 0)) == 1
	}

	func isSignatureValid() -> Bool {
		guard let publicKey = try? Curve25519.Signing.PublicKey(rawRepresentation: pubkey()!) else { return false }
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
		// Now we check the signature's validity!
		return publicKey.isValidSignature(s, for: data)
	}

	func validTime() -> Bool {
		let now = Date()
		return now >= (i - 300) && now < e
	}

	func isValid() -> Bool {
		isSignatureValid() && validTime()
	}
}

internal func prepareGoldenTicket() {
	let path = getStr(10)
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

internal func getStr(_ index: UInt32) -> String {
	let cs = st_get(index)!
	defer { free(cs) }
	return String(cString: cs, encoding: .utf8)!
}
