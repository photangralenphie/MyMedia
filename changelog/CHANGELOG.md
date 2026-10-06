# Changelog

## Current Development Version (v3.1.0)

Version 3.1 focuses artwork and other small improvements and bug fixes.

### Features:

- 


### Enhancements:

 - Adds an empty state to collections.
 - Restores icons in collection and media item action views.
 - Restores app icons on macOS 27.
 - Adds Enter and Escape button actions to confirm and close dialogs.
 - Prevents documentation from being built in every debug build.

### Bugfixes:

 - Prevents creating a collection with an empty title.
 - Fixes wrong subtitles on cell views.
 - Fixes the image downsize toggle help description.
 - Removes stars in the person view.


---


## v3.0.0

Version 3.0 brings library search, Android TV support, and several other improvements and fixes.

### Features:

#### 1. Proper Library Search:

 - Search for titles and people, as well as descriptions of your media.
 - New tab for library-wide search.
 - Use CMD + F to switch to the search tab.

#### 2. Android TV support:

 - MyMedia now runs on Android TV.
 - See [this repository](https://github.com/photangralenphie/MyMediaAndroidTV) for downloads.
 - Runs through the new MyMedia Server/API.

#### 3. Person Details:

 - You can now click on a person to show all media in which they are credited.
 - Accessible through the details of a media item or search.

#### 4. MyMedia Server/API (optional):

 - You can now make your library accessible to other apps on your home network.
 - Developers can now create their own apps compatible with the MyMedia API.
 - The Developer Settings tab contains API documentation and settings.
 - The Server/API is disabled by default and can be enabled through settings if needed.

#### 5. You can now pin Episodes.

### Enhancements:

 - Updated the project for macOS 27.
 - Improved artwork sizing in the grid when the window is resized.
 - Refined the "About" window.
 - Improved translations.
 - DRM-protected media will now automatically open in QuickTime.

### Bugfixes:

 - Restored collection descriptions that could disappear.

**Full commit history**: [v2.1.0...v3.0.0](https://github.com/photangralenphie/MyMedia/compare/v2.1.0...v3.0.0)


---


## v2.1.0

![Screenshot of the artwork selection feature](https://github.com/photangralenphie/MyMedia/changelog/assets/v2.1.0/artworkSelection.jpeg)

### Features:

 - You can now select which season artwork to display in your library for a TV Show.
 - Adds a Mini-Series tab (can be hidden) for TV Shows tagged with “Mini-Series”, “Mini Series” or “Limited Series” as a genre.

### Enhancements:

 - Adds link to GitHub to the menu bar.
 - Help menubar entry now links to the GitHub wiki.

### Bugfixes:

 - Fixes a bug that would prevent episodes of a TV Show from being played in the correct order.

### **New**: Install with Homebrew:
    brew install photangralenphie/homebrew-tap/mymedia

**Full commit history**: [v2.0.1...v2.1.0](https://github.com/photangralenphie/MyMedia/compare/v2.0.1...v2.1.0)


---


## v2.0.1

### Enhancements:

 - Depending on the setting to use the built-in or default player, the context menu now shows the option to use the other player.
 - Adds a new context menu entry to show the original file in Finder.
 - Minor UI enhancements.

### Bugfixes:

 - Fixes [#16](https://github.com/photangralenphie/MyMedia/issues/16): Picture in Picture now working.
 - Fixes a bug that would cause a crash after MyMedia was quit while playing a video.

**Full commit history**: [v2.0.0...v2.0.1](https://github.com/photangralenphie/MyMedia/compare/v2.0.0...v2.0.1)


---


## v2.0.0

### Features:
 
 - support for macOS 26 and Liquid Glass
 - new list view for media items
 - new table view for media items
 - new details view for episodes
 - support for Now Playing
 - toggle sections on or off
 - You can now select more than one folder when importing.

### Enhancements:

 - set your preferred description length in settings
 - the play button is now placed in the artwork and will appear on hover. (+ adds setting for old style)
 - improves error messages shown to user

### Bugfixes:

 - collection artwork no longer disappears after editing a collection
 - some items were not playable even though the files were accessible

**Full commit history**: [v1.1...v2.0.0](https://github.com/photangralenphie/MyMedia/compare/v1.1...v2.0.0)


---


## v1.1.0

### Features:
 
 - Collections: Add movies, shows to a collection to group them together.
 - German translation
 - Picture-in-Picture support for built in player.

### Enhancements: 

 - User choose-able player style.
 - Option to auto quit when closing.
 - Option to downsize images to save resources.

**Full commit history**: [v1.0.3...v1.1](https://github.com/photangralenphie/MyMedia/compare/v1.0.3...v1.1)


---


## v1.0.3

### Features:

 - adds option to re-import file

### Enhancements:

 - makes sidebar completely reorderable

### Bugfixes:

 - fixes language flags appearing black
 - fixes cell alignments when title text is wider than artwork
 - fixes importing of single files

**Full commit history**: [v1.0.2...v1.0.3](https://github.com/photangralenphie/MyMedia/compare/v1.0.2...v1.0.3)


---


## v1.0.2

### Features:

 - adds an option to import a folder and all its content in bulk (cmd+shift+I)

### Enhancements: 

 - If a file cannot be imported because of missing metadata, the app will now tell you the file name.

### Bugfixes:

 - Fixes problems importing and playing media because of missing access rights

> Due to changed access rights, you might have to re-import media into the library.

**Full commit history**: [v1.0.1....v1.0.2](https://github.com/photangralenphie/MyMedia/compare/v1.0.1...v1.0.2)


---


## v1.0.1

### Bugfixes

 - fixes a crash when trying to play a video

**Full commit history**: [v1.0.0...v1.0.1](https://github.com/photangralenphie/MyMedia/compare/v1.0.0...v1.0.1)

## v1.0.0

Initial Release
