//
//  HomeView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 31.03.25.
//

import SwiftUI
import SwiftData
import AwesomeSwiftyComponents



struct HomeView: View {
	
	@Environment(\.modelContext) private var moc
	@Query(sort: \TvShow.title) private var tvShows: [TvShow]
	@Query(sort: \Movie.title) private var movies: [Movie]
	@Query(sort: \Episode.title) private var episodes: [Episode]
	@Query(sort: \MediaCollection.title) private var collections: [MediaCollection]
	
	@AppStorage("selectedTab") private var selectedTab: String = Tabs.unwatched.id
	@AppStorage("sidebarCustomizations") private var tabViewCustomization: TabViewCustomization
	
	@Environment(CommandResource.self) private var commandResource
	@Environment(\.openURL) private var openURL
	
    var body: some View {
		TabView(selection: $selectedTab) {
			TabSection("Library") {
				UnwatchedTab(tvShows: tvShows, movies: movies)
				FavoritesTab(tvShows: tvShows, movies: movies)
				GenresTab(tvShows: tvShows, movies: movies)
				CollectionsTab()
//				SearchTab(tvShows: tvShows, movies: movies, episodes: episodes)
			}
			.customizationID(Tabs.generalSection)
			
			TabSection("Movies") {
				MoviesTab(movies: movies)
				MoviesGenresTab(movies: movies)
			}
			.customizationID(Tabs.moviesSection)
			
			TabSection("TV Shows") {
				TvShowsTab(tvShows: tvShows)
				TvShowsGenresTab(tvShows: tvShows)
				TvShowsMiniSeriesTab(tvShows: tvShows)
			}
			.customizationID(Tabs.tvShowsSection)
			
			PinnedTabs(tvShows: tvShows, movies: movies, collections: collections)
		}
		.tabViewCustomization($tabViewCustomization)
		.tabViewStyle(.sidebarAdaptable)
		.tabViewSidebarBottomBar() {
			ImportingView()
		}
		.alert(commandResource.errorTitle, isPresented: .constant(commandResource.errorMessage != nil)) {
			Button("OK"){ commandResource.clearError() }
			Button("Get Help") { openURL(URL(string: "https://github.com/photangralenphie/MyMedia/wiki/Help-%E2%80%90-Error-Codes")!) }
		} message: {
			commandResource.errorMessage ?? Text("Unknown Error")
		}
		.sheet(item: Bindable(commandResource).tvShowArtworkToEdit) { tvShow in
			ArtworkSelectorView(tvShow: tvShow)
		}
//		.onKeyPress { keyPress in
//			if keyPress.characters == "f" && keyPress.modifiers == [.command] {
//				selectedTab = Tabs.search.id
//			}
//
//			return .handled
//		}
    }
}
