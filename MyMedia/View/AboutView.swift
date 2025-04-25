//
//  AboutView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 18.04.25.
//

import SwiftUI
import AwesomeSwiftyComponents

struct AboutView: View {
	
	private let currentYear = "2025"
	private let version: String
	
	init(){
		self.version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
	}
	
    var body: some View {
		HStack {
			Image("About")
				.resizable()
				.scaledToFit()
				.frame(width: 100, height: 100)
				.clipShape(RoundedRectangle(cornerRadius: 20))
			VStack {
				Text("MyMedia")
				Section("Credits") {
					NavigationStack {
						NavigationLink("AwesomeSwiftyComponents") {
							LicenceView(licence: .mit(name: "AwesomeSwiftyComponents", author: "Jonas Helmer", year: "2025"))
								.frame(minWidth: 500, minHeight: 400)
						}
						NavigationLink("swift-collections") {
							LicenceView(licence: .apache(name: "swift-collections", author: "Apple", year: currentYear))
								.frame(minWidth: 500, minHeight: 400)
						}
					}
				}
				
				Text("Version \(version)")
				Text("© \(currentYear) Jonas Helmer")
			}
		}
		.scenePadding()
    }
}
