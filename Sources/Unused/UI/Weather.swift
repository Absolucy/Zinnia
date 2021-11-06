//  Copyright (c) 2021 Lucy <lucy@absolucy.moe>
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftUI
import UIKit

enum WeatherInfo {
	// https://gist.github.com/bzerangue/805520
	static var codes: [Int: String] = [
		0: "tornado",
		1: "tropicalstorm",
		2: "hurricane",
		3: "cloud.bolt.rain",
		4: "cloud.bolt",
		5: "cloud.snow",
		6: "cloud.sleet",
		7: "cloud.sleet",
		8: "cloud.drizzle",
		9: "cloud.drizzle",
		10: "cloud.sleet",
		11: "cloud.rain",
		12: "cloud.rain",
		13: "cloud.snow",
		14: "cloud.snow",
		15: "wind.snow",
		16: "cloud.snow",
		17: "cloud.hail",
		18: "cloud.sleet",
		19: "sun.dust",
		20: "cloud.fog",
		21: "sun.haze",
		22: "smoke",
		23: "wind",
		24: "wind",
		25: "thermometer.snowflake",
		26: "cloud",
		27: "cloud.moon",
		28: "cloud.sun",
		29: "cloud.moon",
		30: "cloud.sun",
		31: "moon",
		32: "sun.max",
		33: "moon",
		34: "sun.max",
		35: "cloud.hail",
		36: "thermometer.sun",
		37: "cloud.bolt",
		38: "cloud.bolt",
		39: "cloud.bolt",
		40: "cloud.rain",
		41: "cloud.snow",
		42: "cloud.snow",
		43: "cloud.snow",
		44: "cloud",
		45: "cloud.bolt.rain",
		46: "cloud.snow",
		47: "cloud.bolt.rain",
	]
}
