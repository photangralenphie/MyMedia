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
	
	@State private var licence: Licence?
	
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
					.font(.title)
					.padding(.bottom)
				
				VStack(alignment: .leading) {
					Text("Credits:")
					Button("AwesomeSwiftyComponents") {
						licence = .mit(name: "AwesomeSwiftyComponents", author: "Jonas Helmer", year: "2025")
					}
					Button("swift-collections") {
						licence = .apache(name: "swift-collections", author: "Apple", year: currentYear)
					}
				}
				.padding(.bottom)
				
				Text("Version \(version)")
				Button("MyMedia is licensed under the MIT Licence") {
					licence = .mit(name: "MyMedia", author: "Jonas Helmer", year: "2025")
				}
				Text("© \(currentYear) Jonas Helmer")
			}
			.sheet(item: $licence) { sheetLicence in
				VStack{
					LicenceView(licence: sheetLicence)
					Button("Close") { licence = nil }
						.padding(.bottom)
				}
				.frame(minHeight: 400)
			}
		}
		.scenePadding()
    }
}
