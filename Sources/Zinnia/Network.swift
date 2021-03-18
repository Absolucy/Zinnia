//
//  Network.swift
//
//
//  Created by Aspen on 3/16/21.
//

import CoreTelephony
import Foundation
import NetworkExtension
import ZinniaC

public enum NetworkStatus {
	public static func WifiSignal() -> Double {
		var strength = 0.0
		let semaphore = DispatchSemaphore(value: 0)
		NEHotspotNetwork.fetchCurrent { network in
			strength = network?.signalStrength ?? 0.0
			semaphore.signal()
		}
		switch semaphore.wait(timeout: DispatchTime(uptimeNanoseconds: 500_000_000)) {
		case .success:
			return strength
		case .timedOut:
			return 0.0
		}
	}

	public static func MobileSignal() -> Double {
		Double(CTGetSignalStrength()) * 0.01
	}
}
