//
//  ColorField.swift
//  NomaePreferences
//
//  Created by Eamon Tracey.
//  Copyright © 2021 Eamon Tracey. All rights reserved.
//

import SwiftUI

/// TextField that displays the color of the corresponding hex string input
/// Intended for iOS 13 use since `ColorPicker` is unavailable
internal struct ColorField: View {
	private let title: String
	@Binding private var selection: String

	internal init(_ title: String, selection: Binding<String>) {
		self.title = title
		self._selection = selection
	}

	internal var body: some View {
		HStack {
			TextField(title, text: $selection)
			RoundedRectangle(cornerRadius: 5)
				.foregroundColor(Color(hexString: selection) ?? .clear)
		}
	}
}
