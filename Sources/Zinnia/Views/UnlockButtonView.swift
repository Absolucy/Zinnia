//
//  SwiftUIView.swift
//
//
//  Created by Aspen on 3/18/21.
//

import SwiftUI
import UIKit

struct UnlockButtonView: View {
	@ObservedObject var globals = ZinniaSharedData.global

	@State private var anim_stroke_size = CGFloat(10.0)
	@State private var anim_faceid_alpha = 1.0

	public var unlock: () -> Void

	private static var gradient_start = Color.pink
	private static var gradient_end = Color(
		UIColor.blend(
			color1: .systemPink,
			color2: .white
		)
	)

	var body: some View {
		GeometryReader { frame in
			VStack {
				Spacer()
				Text("Tap to unlock").alignmentGuide(HorizontalAlignment.center, computeValue: { $0.width / 2.0 })
				HStack {
					Spacer()
					Circle()
						.frame(width: frame.size.width * 0.25, height: frame.size.width * 0.25)
						.foregroundColor(.primary)
						.overlay(
							Circle()
								.stroke(
									LinearGradient(
										gradient: Gradient(colors: [Self.gradient_start, Self.gradient_end]),
										startPoint: .leading,
										endPoint: .trailing
									),
									lineWidth: anim_stroke_size
								)
								.animation(Animation.easeInOut.repeatForever().speed(0.25))
								.overlay(
									Image(systemName: "faceid")
										.foregroundColor(.accentColor)
										.opacity(anim_faceid_alpha)
										.animation(Animation.easeInOut.repeatForever().speed(0.25))
										.font(.system(size: 60))
										.scaledToFit()
										.padding()
										.onAppear(perform: {
											self.anim_faceid_alpha = 0.0
										}).opacity(globals.unlocked ? 0.0 : 1.0)
								)
								.onAppear(perform: {
									anim_stroke_size = 5.0
								})
						)
						.padding()
						.onTapGesture {
							unlock()
						}
					Spacer()
				}
			}.frame(height: frame.size.height)
		}
	}
}
