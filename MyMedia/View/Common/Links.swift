//
//  Links.swift
//  MyMedia
//
//  Created by Jonas Helmer on 13.04.26.
//

import SwiftUI

struct GitHubLink: View {
    var body: some View {
		Link(destination: URL(string: "https://github.com/photangralenphie/MyMedia")!) {
			Label("GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
		}
    }
}

struct WikiLink: View {
	var body: some View {
		Link(destination: URL(string: "https://github.com/photangralenphie/MyMedia/wiki")!) {
			Label("Wiki", systemImage: "info.circle")
		}
	}
}


#Preview {
	VStack {
		// in AboutView
		HStack {
			GitHubLink()
			WikiLink()
		}
		.labelStyle(LinkButtonStyle())
		
		// in Menubar
		Menu("MenuBar") {
			GitHubLink()
			WikiLink()
		}
	}
}
