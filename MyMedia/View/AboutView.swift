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
	@State private var showCmarkGfmLicense: Bool = false
	@State private var cmarkGfmLicense: String
	
	init(){
		self.version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
		
		if let asset = NSDataAsset(name: "CmarkGfmLicense"),
		   let content = String(data: asset.data, encoding: .utf8) {
				self.cmarkGfmLicense = content
		} else {
			self.cmarkGfmLicense = ""
		}
	}
	
    var body: some View {
		HStack {
			Image("About")
				.resizable()
				.scaledToFit()
				.frame(width: 100, height: 100)
			
			VStack {
				Text("MyMedia")
					.font(.title)
					.padding(.bottom)
				
				VStack(alignment: .leading) {
					Text("Credits:")
					Button("AwesomeSwiftyComponents") {
						licence = .mit(name: "AwesomeSwiftyComponents", author: "Jonas Helmer", year: "2025")
					}
					
					Button("cmark-gfm") {
						showCmarkGfmLicense.toggle()
					}
					
					Button("NetworkImage") {
						licence = .mit(name: "NetworkImage", author: "Guille Gonzalez", year: "2020")
					}
					
					Button("swift-collections") {
						licence = .apache(name: "swift-collections", author: "Apple", year: currentYear)
					}
					
					Button("swift-markdown-ui") {
						licence = .mit(name: "swift-markdown-ui", author: "Guillermo Gonzalez", year: "2020")
					}
					
					Button("swiftui-introspect") {
						licence = .apache(name: "swiftui-introspect", author: "Timber Software", year: "2019")
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
			.sheet(isPresented: $showCmarkGfmLicense) {
				VStack {
					ScrollView {
						Text(cmarkGfmLicense)
							.padding()
					}
					.frame(minHeight: 400)
					
					Button("Close") { showCmarkGfmLicense.toggle() }
						.padding(.bottom)
				}
			}
		}
		.scenePadding()
    }
}
