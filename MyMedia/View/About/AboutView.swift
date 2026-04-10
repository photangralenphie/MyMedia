//
//  AboutView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 18.04.25.
//

import SwiftUI
import AwesomeSwiftyComponents

struct AboutView: View {
	
	private let currentYear = "2026"
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
			Image(.about)
				.resizable()
				.scaledToFit()
				.frame(width: 100, height: 100)
				.padding(.trailing)
			
			VStack(alignment: .leading) {
				Text("MyMedia")
					.font(.title)
				
				Text("Version \(version)")
					.font(.subheadline)
					.foregroundStyle(.secondary)
					.padding(.bottom)
				
				Text("Credits:")
				
				ScrollView {
					VStack(alignment: .leading) {
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
						
						Button("swift-syntax") {
							licence = .apache(name: "swift-syntax", author: "Apple", year: "2024")
						}
						
						Button("swift-markdown-ui") {
							licence = .mit(name: "swift-markdown-ui", author: "Guillermo Gonzalez", year: "2020")
						}
						
						Button("swiftui-introspect") {
							licence = .apache(name: "swiftui-introspect", author: "Timber Software", year: "2019")
						}
					}
					.frame(maxWidth: .infinity, alignment: .leading)
				}
				.scrollIndicators(.visible)
				
				HStack {
					Text("© \(currentYear) Jonas Helmer")
						.foregroundStyle(.secondary)
					Button("MIT Licence") {
						licence = .mit(name: "MyMedia", author: "Jonas Helmer", year: currentYear)
					}
					.padding(.leading)
				}
				.padding(.top)
			}
			.sheet(item: $licence) { sheetLicence in
				VStack{
					LicenceView(licence: sheetLicence)
						.scenePadding()
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
    }
}

#Preview {
	AboutView()
		.scenePadding()
		.ignoresSafeArea()
		.frame(width: 420, height: 260)
		.toolbar(removing: .title)
		.toolbarBackground(.hidden, for: .windowToolbar)
		.containerBackground(.regularMaterial, for: .window)
}
