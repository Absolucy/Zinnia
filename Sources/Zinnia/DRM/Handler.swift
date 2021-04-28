import CryptoKit
import Foundation
import UIKit
import ZinniaC

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

	internal static func silentlyUpdateTicket() {
		authInProgress = true
		contactServer { response in
			defer {
				authInProgress = false
				authSemaphore.signal()
			}
			if case let .success(ticket) = response {
				ticket.save()
				self.ticket = ticket
				#if DEBUG
					NSLog("Zinnia: updated with new ticket")
				#endif
			} else {
				#if DEBUG
					NSLog("Zinnia: silent ticket update failed")
				#endif
			}
		}
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

		let artificalWait = DispatchSemaphore(value: 0)
		DispatchQueue.main.asyncAfter(deadline: .now() + 2, qos: .background) {
			artificalWait.signal()
		}

		contactServer { response in
			DispatchQueue.main.async(qos: .userInteractive) {
				defer {
					authInProgress = false
					authSemaphore.signal()
				}
				_ = artificalWait.wait(timeout: .now() + 2)

				switch response {
				case .error:
					alert.dismiss(withClickedButtonIndex: 0, animated: false)
					UIAlertView(title: getStr(0), message: getStr(3), delegate: nil,
					            cancelButtonTitle: getStr(5)).show()
				case .denied:
					alert.dismiss(withClickedButtonIndex: 0, animated: false)
					#if TRIAL
						UIAlertView(title: getStr(0), message: getStr(14), delegate: nil,
						            cancelButtonTitle: getStr(5)).show()
					#else
						UIAlertView(title: getStr(0), message: getStr(2), delegate: nil,
						            cancelButtonTitle: getStr(5)).show()
					#endif
				case let .success(ticket):
					#if DEBUG
						NSLog("Zinnia: ticket \(ticket.isValid()) \(ticket.isSignatureValid()) \(ticket.validTime())")
					#endif
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
				}
			}
		}
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
