//
//  MetadataUtil.swift
//  MyMedia
//
//  Created by Jonas Helmer on 12.04.25.
//

struct MetadataUtil {
	public static func formatRuntime(minutes: Int) -> String {
		let hours = minutes / 60
		let mins = minutes % 60
		
		if hours > 0 && mins > 0 {
			return "\(hours) hr, \(mins) min"
		} else if hours > 0 {
			return "\(hours) hr"
		} else {
			return "\(mins) min"
		}
	}
	
	public static func getRating(ratingString: String?) -> String? {
		if let ratingString = ratingString {
			if let firstPipe = ratingString.firstIndex(of: "|"), let secondPipe = ratingString[firstPipe...].dropFirst().firstIndex(of: "|") {
				let start = ratingString.index(after: firstPipe)
				let end = secondPipe
				return String(ratingString[start..<end])
			}
		}
		return nil
	}
	
	public static func flagEmojis(for languageCodes: [String]) -> String {
		languageCodes
			.map { languageToFlag[$0] ?? "🏴󠁥󠁳󠁣󠁴󠁿" }
			.joined(separator: " ")
	}
	
	private static let languageToFlag: [String: String] = [
		"ps": "🇵🇰",
		"uz": "🇺🇿",
		"tk": "🇹🇲",
		"sq": "🇦🇱",
		"ar": "🇦🇪",
		"en": "🇬🇧",
		"sm": "🇼🇸",
		"ca": "🏴󠁥󠁳󠁣󠁴󠁿",
		"pt": "🇵🇹",
		"es": "🇪🇸",
		"gn": "🇵🇾",
		"hy": "🇦🇲",
		"ru": "🇷🇺",
		"nl": "🇳🇱",
		"pa": "🇮🇳",
		"de": "🇩🇪",
		"az": "🇦🇿",
		"bn": "🇧🇩",
		"be": "🇧🇾",
		"fr": "🇫🇷",
		"dz": "🇧🇹",
		"ay": "🇧🇴",
		"qu": "🇧🇴",
		"bs": "🇧🇦",
		"hr": "🇭🇷",
		"sr": "🇷🇸",
		"tn": "🇹🇳",
		"no": "🇧🇻",
		"nb": "🇧🇻",
		"nn": "🇧🇻",
		"ms": "🇲🇾",
		"bg": "🇧🇬",
		"ff": "🇸🇳",
		"rn": "🇧🇮",
		"km": "🇰🇭",
		"sg": "🇨🇫",
		"zh": "🇨🇳",
		"ln": "🇨🇩",
		"kg": "🇨🇬",
		"sw": "🇹🇿",
		"lu": "🇨🇩",
		"el": "🇬🇷",
		"tr": "🇹🇷",
		"cs": "🇨🇿",
		"sk": "🇸🇰",
		"da": "🇩🇰",
		"ti": "🇪🇷",
		"et": "🇪🇪",
		"ss": "🇸🇿",
		"am": "🇪🇹",
		"fo": "🇫🇴",
		"fj": "🇫🇯",
		"hi": "🇮🇳",
		"ur": "🇵🇰",
		"fi": "🇫🇮",
		"sv": "🇸🇪",
		"ka": "🇬🇪",
		"kl": "🇬🇱",
		"ch": "🇬🇺",
		"ht": "🇭🇹",
		"it": "🇮🇹",
		"la": "🇻🇦",
		"hu": "🇭🇺",
		"is": "🇮🇸",
		"id": "🇮🇩",
		"fa": "🇮🇷",
		"ku": "🇮🇶",
		"ga": "🇮🇪",
		"gv": "🇮🇲",
		"he": "🇮🇱",
		"ja": "🇯🇵",
		"kk": "🇰🇿",
		"ko": "🇰🇷",
		"ky": "🇰🇬",
		"lo": "🇱🇦",
		"lv": "🇱🇻",
		"st": "🇱🇸",
		"lt": "🇱🇹",
		"lb": "🇱🇺",
		"mg": "🇲🇬",
		"ny": "🇲🇼",
		"dv": "🇲🇻",
		"mt": "🇲🇹",
		"mh": "🇲🇭",
		"ro": "🇲🇩",
		"mn": "🇲🇳",
		"my": "🇲🇲",
		"af": "🇳🇦",
		"na": "🇳🇷",
		"ne": "🇳🇵",
		"mi": "🇳🇿",
		"mk": "🇲🇰",
		"pl": "🇵🇱",
		"rw": "🇷🇼",
		"ta": "🇮🇳",
		"sl": "🇸🇮",
		"so": "🇸🇴",
		"nr": "🇿🇦",
		"ts": "🇿🇦",
		"ve": "🇿🇦",
		"xh": "🇿🇦",
		"zu": "🇿🇦",
		"eu": "🇪🇸",
		"gl": "🇪🇸",
		"oc": "🇪🇸",
		"si": "🇱🇰",
		"tg": "🇹🇯",
		"th": "🇹🇭",
		"to": "🇹🇴",
		"uk": "🇺🇦",
		"bi": "🇻🇺",
		"vi": "🇻🇳",
		"sn": "🇿🇼",
		"nd": "🇿🇦"
	]
	
	public static func genreSymbol(for genre: String) -> String {
		switch genre {
			case "Action":
				return "burst"
			case "Adventure":
				return "map"
			case "Animated", "Animation":
				return "lamp.desk"
			case "Children":
				return "figure.child"
			case "Comedy":
				return "face.smiling"
			case "Crime":
				return "person.fill.viewfinder"
			case "Drama":
				return "theatermasks.fill"
			case "Documentary":
				return "photo.artframe"
			case "Family":
				return "figure.2.and.child.holdinghands"
			case "Fantasy":
				return "wand.and.stars"
			case "History":
				return "crown"
			case "Horror":
				return "figure.run"
			case "Music":
				return "music.note"
			case "Musical":
				return "music.microphone"
			case "Mystery":
				return "magnifyingglass"
			case "Nature":
				return "leaf"
			case "Romance", "Love":
				return "heart"
			case "Sci-Fi", "Science-Fiction", "Science Fiction":
				return "atom"
			case "Sport", "Sports":
				return "soccerball"
			case "Thriller":
				return "waveform.path.ecg"
			case "Trash":
				return "trash"
			case "War":
				return "dot.scope"
			case "Western":
				return "lasso"
			default:
				return "person.crop.square.on.square.angled"
		}
	}
}
