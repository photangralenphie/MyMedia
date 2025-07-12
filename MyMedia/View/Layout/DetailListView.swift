//
//  DetailListView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 06.07.25.
//

import SwiftUI

struct TableRowData: Identifiable {
	let mediaItem: any MediaItem
	let title: String
	let year: Int
	let dateAdded: Date
	
	var id: UUID { mediaItem.id }
	
	var details: LocalizedStringKey {
		switch mediaItem {
			case let movie as Movie:
				return LocalizedStringKey(MetadataUtil.formatRuntime(minutes: movie.durationMinutes))
			case let tvShow as TvShow:
				let seasons = Set(tvShow.episodes.map { $0.season }).count
				let episodes = tvShow.episodes.count
				return
					"""
					^[\(seasons) Season](inflect: true)
					^[\(episodes) Episode](inflect: true) 
					"""
			case let episode as Episode:
				return LocalizedStringKey(MetadataUtil.formatRuntime(minutes: episode.durationMinutes))
			default:
				return ""
		}
	}
	
	init(mediaItem: any MediaItem) {
		self.mediaItem = mediaItem
		self.title = mediaItem.title
		self.year = mediaItem.year
		self.dateAdded = mediaItem.dateAdded
	}
}

struct DetailListView: View {
	
	@State var mediaItemsWrapper: [TableRowData]
	
	init(filteredMediaItems: [any MediaItem]) {
		self.mediaItemsWrapper = filteredMediaItems
			.map(TableRowData.init)
			.sorted(by: {$0.title < $1.title})
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
			.width(LayoutConstants.artworkWidth * 0.3)
			
			TableColumn("Title", value: \.title)
			
			TableColumn("Year", value: \.year) { rowData in
				Text(String(rowData.year))
			}
			.width(60)
			
			TableColumn("Date Added", value: \.dateAdded) { rowData in
				Text(rowData.dateAdded, style: .date)
			}

			TableColumn("Details") { rowData in
				Text(rowData.details)
					.lineLimit(2)
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
		.onChange(of: sortOrder) { _, sortOrder in
			mediaItemsWrapper = mediaItemsWrapper.sorted(using: sortOrder)
		}
		.navigationDestination(item: $selectedId) { id in
			let mediaItem = mediaItemsWrapper.first { $0.id == id }?.mediaItem
			switch mediaItem {
				case let tvShow as TvShow:
					TvShowDetailView(tvShow: tvShow)
				case let movie as Movie:
					MovieDetailView(movie: movie)
				default:
					Text("Episodes are not supported in Grid view")
			}
		}
    }
}
