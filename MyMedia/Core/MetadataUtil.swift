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
}
