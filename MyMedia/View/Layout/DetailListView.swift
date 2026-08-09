//
//  DetailListView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 06.07.25.
//

import SwiftUI

private struct TableRowData: Identifiable {
	let mediaItem: any MediaItem
	let title: String
	let year: Int
	let dateAdded: Date
	let numEpisode: Int
	let runtime: Int
	
	var id: UUID { mediaItem.id }
	
	var details: String {
		switch mediaItem {
			case let movie as Movie:
				return MetadataUtil.formatRuntime(minutes: movie.durationMinutes)
			case let tvShow as TvShow:
				let seasons = Set(tvShow.episodes.map { $0.season }).count
				let episodes = tvShow.episodes.count
				return String(localized: "\(seasons) Season") + "\n" + String(localized: "\(episodes) Episode")
			case let episode as Episode:
				return MetadataUtil.formatRuntime(minutes: episode.durationMinutes)
			default:
				return ""
		}
	}
	
	init(mediaItem: any MediaItem) {
		self.mediaItem = mediaItem
		self.title = mediaItem.title
		self.year = mediaItem.year
		self.dateAdded = mediaItem.dateAdded
		
		switch mediaItem {
			case let movie as Movie:
				self.numEpisode = 0
				self.runtime = movie.durationMinutes
			case let tvShow as TvShow:
				self.numEpisode = tvShow.episodes.count
				self.runtime = 0
			default:
				self.numEpisode = 0
				self.runtime = 0
		}
	}
}

struct DetailListView: View {
	
	public let filteredMediaItems: [any MediaItem]
	private var mediaItemsWrapper: [TableRowData] {
		filteredMediaItems
			.map(TableRowData.init)
			.sorted(using: sortOrder)
	}
	
	@State private var sortOrder = [
		KeyPathComparator(\TableRowData.title),
		KeyPathComparator(\TableRowData.year),
		KeyPathComparator(\TableRowData.dateAdded),
	]
	
	@State private var selectedId: TableRowData.ID?
	
    var body: some View {
		Table(of: TableRowData.self, selection: $selectedId, sortOrder: $sortOrder) {
			TableColumn("Poster") { rowData in
				ArtworkView(imageData: rowData.mediaItem.artwork, title: rowData.mediaItem.title, subtitle: "\(rowData.mediaItem.title)", scale: 0.3)
					.mediaItemDraggable(mediaItem: rowData.mediaItem)
					.onTapGesture { selectedId = rowData.id }
			}
			.width(LayoutConstants.defaultArtworkWidth * 0.3)
			
			TableColumn("Title", value: \.title)
			
			TableColumn("Year", value: \.year) { rowData in
				Text(String(rowData.year))
			}
			.width(60)
			
			if mediaItemsWrapper.allSatisfy({ $0.mediaItem is Movie }) {
				TableColumn("Runtime", value: \.runtime) { rowData in
					Text(rowData.details)
				}
			}
			
			if mediaItemsWrapper.allSatisfy({ $0.mediaItem is TvShow }) {
				TableColumn("# Episodes", value: \.numEpisode) { rowData in
					Text(rowData.details)
						.lineLimit(2)
				}
			}
			
			if !mediaItemsWrapper.allSatisfy({ $0.mediaItem is Movie }) && !mediaItemsWrapper.allSatisfy({ $0.mediaItem is TvShow }) {
				TableColumn("Details") { rowData in
					Text(rowData.details)
						.lineLimit(2)
				}
			}

			TableColumn("Date Added", value: \.dateAdded) { rowData in
				Text(rowData.dateAdded, style: .date)
			}
			
			TableColumn("\(Image(systemName: "eye"))") { rowData in
				Image(systemName: rowData.mediaItem.isWatched ? "eye" : "eye.slash")
					.help(rowData.mediaItem.isWatched ? "Watched" : "Unwatched")
			}
			.width(20)
			
			TableColumn("\(Image(systemName: "star.fill"))") { rowData in
				Image(systemName: rowData.mediaItem.isFavorite ? "star.fill" : "star")
			}
			.width(20)
		} rows: {
			ForEach(mediaItemsWrapper) { rowData in
				Group {
					TableRow(rowData)
				}
				.contextMenu {
					MediaItemActionsView(mediaItem: rowData.mediaItem, applyShortcuts: false) { }
				}
			}
		}
		.navigationDestination(item: $selectedId) { id in
			if let mediaItem = mediaItemsWrapper.first(where: { $0.id == id })?.mediaItem {
				MediaItemDestinationView(mediaItem: mediaItem)
			}
		}
    }
}
