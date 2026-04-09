//
//  LayoutConstant.swift
//  MyMedia
//
//  Created by Jonas Helmer on 12.04.25.
//

import CoreFoundation
import SwiftUI

public struct LayoutConstants {
	// Artwork
	public static let cornerRadius: CGFloat = 20
	public static let defaultArtworkWidth: CGFloat = 300
	public static let defaultArtworkHeight: CGFloat = 168.75
	public static let artworkAspectRation: CGFloat = defaultArtworkHeight / defaultArtworkWidth
	
	// Settings
	public static let settingsWidth: CGFloat = 350
	
	// Grid
	public static let gridMinArtworkWidth: CGFloat = LayoutConstants.defaultArtworkWidth - 50
	public static let gridMaxArtworkWidth: CGFloat = LayoutConstants.defaultArtworkWidth + 100
	public static let gridSpacing: CGFloat = 20
	public static let gridLayout = [GridItem(.adaptive(minimum: LayoutConstants.gridMinArtworkWidth, maximum: LayoutConstants.gridMaxArtworkWidth), spacing: LayoutConstants.gridSpacing, alignment: .top)]
	
	private init() {}
}

