//
//  MetadataUtil.swift
//  MyMedia
//
//  Created by Jonas Helmer on 12.04.25.
//

import SwiftUI
import AppKit

struct MetadataUtil {
	private init() { }
	
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
			if let firstPipe = ratingString.firstIndex(of: "|"), let end = ratingString[firstPipe...].dropFirst().firstIndex(of: "|") {
				let start = ratingString.index(after: firstPipe)
				return String(ratingString[start..<end])
			}
		}
		return nil
	}
	
	public static func getDescription(mediaItem: any MediaItem) -> String? {
		let preferShortDescription = UserDefaults.standard.bool(forKey: PreferenceKeys.preferShortDescription)
		
		switch mediaItem {
			case let tvShow as TvShow:
				return tvShow.showDescription
			case let movie as Movie:
				if preferShortDescription {
					return movie.shortDescription ?? movie.longDescription
				}
				return movie.longDescription ?? movie.shortDescription
			case let episode as Episode:
				if preferShortDescription {
					return episode.episodeShortDescription ?? episode.episodeLongDescription
				}
				return episode.episodeLongDescription ?? episode.episodeLongDescription
			default:
				return nil
		}
	}
	
	public static func getMaxImageSize() -> CGSize {
		let width = UserDefaults.standard.integer(forKey: PreferenceKeys.downSizeArtworkWidth)
		let height = UserDefaults.standard.integer(forKey: PreferenceKeys.downSizeArtworkHeight)
		return CGSize(width: width, height: height)
	}
	
	public static func getDownSizedImageSize(originalSize: CGSize, maxSize: CGSize) -> CGSize {
		let widthRatio = maxSize.width / originalSize.width
		let heightRatio = maxSize.height / originalSize.height
		let scaleFactor = min(widthRatio, heightRatio)

		return CGSize(
			width: originalSize.width * scaleFactor,
			height: originalSize.height * scaleFactor
		)
	}
	
	public static func downSizeImage(imageData: Data, newSize: CGSize) -> Data {
		guard let image = NSImage(data: imageData) else { return imageData }
		if image.size.width <= newSize.width && image.size.height <= newSize.height {
			return imageData
		}
		
		let resizedImage = NSImage(size: newSize)
		resizedImage.lockFocus()
		image.draw(
			in: NSRect(origin: .zero, size: newSize),
			from: NSRect(origin: .zero, size: image.size),
			operation: .copy,
			fraction: 1.0
		)
		resizedImage.unlockFocus()
		
		if let tiffData = resizedImage.tiffRepresentation,
		   let bitmap = NSBitmapImageRep(data: tiffData),
		   let downSizedData = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.8]) {
			return downSizedData
		} else {
			return imageData
		}
	}
	
	public static func flagEmojis(for languageCodes: [String]) -> String {
		languageCodes
			.map { languageToFlag[$0] ?? "🏴󠁥󠁳󠁣󠁴󠁿" }
			.joined(separator: " ")
	}
	
	private static let languageToFlag: [String: String] = [
		// I do not guarantee that this list is even remotely correct or complete.
		
		// A
		"aar": "🇪🇹", // Afar – Ethiopia
		"abk": "🇬🇪", // Abkhazian – Georgia (Abkhazia)
		"afr": "🇿🇦", // Afrikaans – South Africa
		"aka": "🇬🇭", // Akan – Ghana
		"amh": "🇪🇹", // Amharic – Ethiopia
		"ara": "🇸🇦", // Arabic – Saudi Arabia (widely spoken)
		"arg": "🇪🇸", // Aragonese – Spain
		"asm": "🇮🇳", // Assamese – India
		"ava": "🇷🇺", // Avaric – Russia (Dagestan)
		"aym": "🇧🇴", // Aymara – Bolivia
		"aze": "🇦🇿", // Azerbaijani – Azerbaijan
		
		// B
		"bak": "🇷🇺", // Bashkir – Russia
		"bam": "🇲🇱", // Bambara – Mali
		"bel": "🇧🇾", // Belarusian – Belarus
		"ben": "🇧🇩", // Bengali – Bangladesh
		"bih": "🇮🇳", // Bihari – India (Bihar region)
		"bis": "🇻🇺", // Bislama – Vanuatu
		"bos": "🇧🇦", // Bosnian – Bosnia and Herzegovina
		"bre": "🇫🇷", // Breton – France (Brittany)
		"bul": "🇧🇬", // Bulgarian – Bulgaria
		"bur": "🇲🇲",  // Burmese (Myanmar) – Myanmar (note: old code, modern is "mya")
		
		// C
		"cat": "🇪🇸", // Catalan – Spain (Catalonia)
		"ces": "🇨🇿", // Czech – Czech Republic
		"cha": "🇲🇵", // Chamorro – Northern Mariana Islands
		"che": "🇷🇺", // Chechen – Russia (Chechnya)
		"chi": "🇨🇳", // Chinese – China (old code, modern is "zho")
		"chv": "🇷🇺", // Chuvash – Russia
		"cos": "🇫🇷", // Corsican – France (Corsica)
		"cre": "🇨🇦", // Cree – Canada
		"cym": "🏴󠁧󠁢󠁷󠁬󠁳󠁿", // Welsh – Wales (officially part of UK; regional flag)
		
		// D
		"dan": "🇩🇰", // Danish – Denmark
		"deu": "🇩🇪", // German - Germany
		"div": "🇲🇻", // Divehi (Dhivehi) – Maldives
		"doi": "🇮🇳", // Dogri – India (Jammu & Kashmir region)
		"dut": "🇳🇱", // Dutch – Netherlands (old code; modern is "nld")
		
		// E
		"ell": "🇬🇷", // Modern Greek – Greece
		"eng": "🇬🇧", // English – United Kingdom (widely spoken globally)
		"est": "🇪🇪", // Estonian – Estonia
		"ewe": "🇹🇬", // Ewe – Togo
		"eus": "🇪🇸", // Basque – Spain (Basque Country)
		
		// F
		"fao": "🇫🇴", // Faroese – Faroe Islands
		"fas": "🇮🇷", // Persian – Iran
		"fij": "🇫🇯", // Fijian – Fiji
		"fin": "🇫🇮", // Finnish – Finland
		"fra": "🇫🇷", // French – France
		"fre": "🇫🇷", // French – France (old code; modern is "fra")
		"fry": "🇳🇱", // Western Frisian – Netherlands
		"ful": "🇸🇳", // Fulah – Senegal (widely spoken in West Africa)
		
		// G
		"gla": "🏴󠁧󠁢󠁳󠁣󠁴󠁿", // Scottish Gaelic – Scotland (part of UK)
		"gle": "🇮🇪", // Irish – Ireland
		"glg": "🇪🇸", // Galician – Spain (Galicia)
		"glv": "🇮🇲", // Manx – Isle of Man
		"geo": "🇬🇪", // Georgian – Georgia (old code; modern is "kat")
		"ger": "🇩🇪", // German – Germany (old code; modern is "deu")
		"gil": "🇰🇮", // Gilbertese – Kiribati
		"gor": "🇮🇩", // Gorontalo – Indonesia
		"grn": "🇵🇾", // Guarani – Paraguay
		"guj": "🇮🇳", // Gujarati – India
		
		// H
		"hat": "🇭🇹", // Haitian – Haiti
		"hau": "🇳🇬", // Hausa – Nigeria
		"heb": "🇮🇱", // Hebrew – Israel
		"her": "🇳🇦", // Herero – Namibia
		"hin": "🇮🇳", // Hindi – India
		"hmo": "🇵🇬", // Hiri Motu – Papua New Guinea
		"hrv": "🇭🇷", // Croatian – Croatia
		"hun": "🇭🇺", // Hungarian – Hungary
		"hye": "🇦🇲", // Armenian – Armenia (modern code; old "arm")
		
		// I
		"ibo": "🇳🇬", // Igbo – Nigeria
		"ice": "🇮🇸", // Icelandic – Iceland
		"iii": "🇨🇳", // Sichuan Yi – China
		"iku": "🇨🇦", // Inuktitut – Canada (Indigenous language)
		"ilo": "🇵🇭", // Iloko – Philippines
		"ind": "🇮🇩", // Indonesian – Indonesia
		"isl": "🇮🇸", // Icelandic – Iceland (alternative code)
		"ita": "🇮🇹",  // Italian – Italy
		
		// J
		"jav": "🇮🇩", // Javanese – Indonesia
		"jpn": "🇯🇵", // Japanese – Japan
		"jv": "🇮🇩",  // Javanese – Indonesia (alternative code)
		
		// K
		"kab": "🇩🇿", // Kabyle – Algeria
		"kal": "🇩🇰", // Greenlandic – Greenland (Denmark)
		"kan": "🇮🇳", // Kannada – India
		"kat": "🇬🇪", // Georgian – Georgia (modern code; old code "geo")
		"kau": "🇳🇬", // Kanuri – Nigeria
		"kaz": "🇰🇿", // Kazakh – Kazakhstan
		"khm": "🇰🇭", // Khmer – Cambodia
		"kik": "🇰🇪", // Kikuyu – Kenya
		"kin": "🇷🇼", // Kinyarwanda – Rwanda
		"kir": "🇰🇬", // Kirghiz – Kyrgyzstan
		"kmb": "🇬🇶", // Kimbundu – Angola (Equatorial Guinea)
		"kni": "🇪🇸", // K'iche' – Guatemala
		"kon": "🇨🇩", // Kongo – Democratic Republic of the Congo
		"kor": "🇰🇷", // Korean – South Korea
		"kpe": "🇬🇮", // Kpelle – Guinea
		"kro": "🇨🇮", // Kroumen – Ivory Coast
		"kur": "🇮🇷", // Kurdish – Iran
		"kyr": "🇰🇬", // Kyrgyz – Kyrgyzstan
		
		// L
		"lao": "🇱🇦", // Lao – Laos
		"lav": "🇱🇻", // Latvian – Latvia
		"lez": "🇷🇺", // Lezgian – Russia (Dagestan region)
		"lim": "🇧🇪", // Limburgish – Belgium (Limburg region)
		"lin": "🇨🇩", // Lingala – Democratic Republic of the Congo
		"lit": "🇱🇹", // Lithuanian – Lithuania
		"ltz": "🇱🇺", // Luxembourgish – Luxembourg
		"lub": "🇨🇩", // Luba-Katanga – Democratic Republic of the Congo
		"lug": "🇺🇬", // Luganda – Uganda
		
		// M
		"mah": "🇲🇻", // Marshallese – Marshall Islands
		"mal": "🇮🇳", // Malayalam – India
		"man": "🇳🇬", // Mandinka – Gambia and other parts of West Africa
		"mao": "🇳🇿", // Māori – New Zealand
		"mar": "🇮🇳", // Marathi – India
		"mic": "🇨🇦", // Mi'kmaq – Canada
		"min": "🇮🇩", // Minangkabau – Indonesia
		"mon": "🇲🇳", // Mongolian – Mongolia
		"mri": "🇳🇿", // Māori – New Zealand (alternative code)
		"mad": "🇮🇩", // Madurese – Indonesia
		"mag": "🇮🇳", // Magahi – India
		"mai": "🇮🇳", // Maithili – India
		"mak": "🇮🇩", // Makasar – Indonesia
		"mkd": "🇲🇰", // Macedonian – North Macedonia
		"mlg": "🇲🇬", // Malagasy – Madagascar
		"mlt": "🇲🇹", // Maltese – Malta
		"mnc": "🇷🇺", // Manchu – Russia (historical language)
		"msn": "🇮🇩", // Minahasan – Indonesia
		"msa": "🇲🇾", // Malay – Malaysia (also spoken in Indonesia and Singapore)
		"myv": "🇷🇺", // Erzya – Russia (Mordovia region)
		"mya": "🇲🇲",  // Burmese – Myanmar,
		
		// N
		"nah": "🇲🇽", // Nahuatl – Mexico
		"nap": "🇮🇹", // Neapolitan – Italy
		"nau": "🇵🇬", // Nauru – Nauru
		"nav": "🇺🇸", // Navajo – United States
		"nbl": "🇿🇦", // Ndebele (South Africa) – South Africa
		"nci": "🏳️", // NCI (National Context Identifier) – no specific flag
		"nde": "🇿🇦", // Ndebele (Zimbabwe) – Zimbabwe
		"ndo": "🇨🇬", // Ndonga – Namibia
		"nep": "🇳🇵", // Nepali – Nepal
		"new": "🇳🇵", // Newari – Nepal
		"nia": "🇮🇩", // Nias – Indonesia
		"nno": "🇳🇴", // Nynorsk Norwegian – Norway
		"nor": "🇳🇴", // Norwegian – Norway
		"nso": "🇿🇦", // Northern Sotho – South Africa
		"nya": "🇿🇲", // Nyanja – Zambia
		
		// O
		"oci": "🇫🇷", // Occitan – France
		"ori": "🇮🇳", // Oriya – India (now called Odia)
		"orm": "🇪🇹", // Oromo – Ethiopia
		"oss": "🇷🇺", // Ossetian – Russia
		
		// P
		"pan": "🇮🇳", // Punjabi – India
		"pap": "🇧🇶", // Papiamento – Bonaire, Sint Eustatius, and Saba (Netherlands)
		"per": "🇮🇷", // Persian – Iran (alternative code)
		"phi": "🇵🇭", // Philippine languages
		"pol": "🇵🇱", // Polish – Poland
		"por": "🇵🇹", // Portuguese – Portugal (also spoken in Brazil, Brazil, and former colonies)
		"pus": "🇦🇫", // Pashto – Afghanistan
		
		// R
		"raj": "🇮🇳", // Rajasthani – India
		"rap": "🇹🇴", // Rapa Nui – Easter Island (Chile)
		"rar": "🇨🇰", // Rarotongan – Cook Islands
		"roh": "🇨🇭", // Romansh – Switzerland
		"rom": "🇪🇺", // Romani – no specific flag (widely spread across Europe)
		"rum": "🇷🇴", // Romanian – Romania
		"run": "🇷🇼", // Rundi – Burundi
		"rus": "🇷🇺", // Russian – Russia
		"ryu": "🇯🇵", // Ryukyuan languages – Japan
		
		// S
		"sah": "🇷🇺", // Sakha (Yakut) – Russia
		"sco": "🏴󠁧󠁢󠁳󠁣󠁴󠁿", // Scots – Scotland (part of the UK)
		"sel": "🇷🇺", // Selkup – Russia
		"ses": "🇸🇱", // Senufo – Sierra Leone
		"sga": "🇮🇪", // Old Irish – Ireland (historical language)
		"sgn": "✋", // Sign languages – no specific flag
		"shn": "🇲🇲", // Shan – Myanmar
		"sid": "🇪🇹", // Sidamo – Ethiopia
		"sin": "🇱🇰", // Sinhala – Sri Lanka
		"slk": "🇸🇰", // Slovak – Slovakia
		"slv": "🇸🇮", // Slovenian – Slovenia
		"sme": "🇳🇴", // Northern Sami – Norway
		"smi": "🇫🇮", // Sami languages – Finland
		"smj": "🇸🇪", // Lule Sami – Sweden
		"smn": "🇫🇮", // Inari Sami – Finland
		"smo": "🇼🇸", // Samoan – Samoa
		"sms": "🇸🇪", // Skolt Sami – Sweden
		"sna": "🇿🇼", // Shona – Zimbabwe
		"snd": "🇵🇰", // Sindhi – Pakistan
		"snk": "🇲🇱", // Soninke – Mali
		"som": "🇸🇴", // Somali – Somalia
		"sot": "🇿🇦", // Southern Sotho – South Africa
		"spa": "🇪🇸", // Spanish – Spain
		"sqi": "🇦🇱", // Albanian – Albania
		"srp": "🇷🇸", // Serbian – Serbia
		"srr": "🇸🇳", // Serer – Senegal
		"ssw": "🇿🇦", // Swati – South Africa
		"suk": "🇹🇿", // Sukuma – Tanzania
		"sun": "🇮🇩", // Sundanese – Indonesia
		"swa": "🇰🇪", // Swahili – Kenya (widely spoken in East Africa)
		"swe": "🇸🇪", // Swedish – Sweden
		"syc": "🇸🇾", // Classical Syriac – historical
		"syr": "🇸🇾", // Syriac – Syria
		
		// T
		"taj": "🇰🇿", // Tajik – Tajikistan
		"tam": "🇮🇳", // Tamil – India
		"tat": "🇷🇺", // Tatar – Russia
		"tel": "🇮🇳", // Telugu – India
		"tgk": "🇹🇯", // Tajik – Tajikistan
		"tha": "🇹🇭", // Thai – Thailand
		"tib": "🇨🇳", // Tibetan – China
		"tig": "🇸🇸", // Tigre – Eritrea
		"tir": "🇪🇹", // Tigrinya – Ethiopia
		"tiv": "🇳🇬", // Tiv – Nigeria
		"tkl": "🇹🇰", // Tokelauan – Tokelau
		"tmh": "🇲🇱", // Tamasheq – Mali
		"tog": "🇿🇦", // Tonga (Nyasa) – Malawi
		"ton": "🇹🇴", // Tongan – Tonga
		"tsn": "🇿🇦", // Tswana – South Africa
		"tso": "🇿🇦", // Tsonga – South Africa
		"tuk": "🇹🇲", // Turkmen – Turkmenistan
		"tur": "🇹🇷", // Turkish – Turkey
		"twi": "🇬🇭", // Twi – Ghana
		
		// U
		"uae": "🇺🇦", // Ukrainian – Ukraine
		"umb": "🇦🇴", // Umbundu – Angola
		"uig": "🇨🇳", // Uighur – China
		"ukr": "🇺🇦", // Ukrainian – Ukraine
		"uru": "🇮🇳", // Urdu – India (widely spoken in Pakistan and India)
		"uzb": "🇺🇿", // Uzbek – Uzbekistan
		
		// V
		"vie": "🇻🇳", // Vietnamese – Vietnam
		"vot": "🇫🇮", // Votic – Finland (Endangered language)
		
		// W
		"wal": "🇪🇹", // Walamo – Ethiopia
		"war": "🇵🇭", // Waray – Philippines
		"wel": "🏴󠁧󠁢󠁷󠁬󠁳󠁿", // Welsh – Wales
		"wen": "🇩🇪", // Sorbian languages – Germany
		"wln": "🇧🇪", // Walloon – Belgium
		"wol": "🇸🇳", // Wolof – Senegal
		"wuu": "🇨🇳", // Wu Chinese – China
		
		// X
		"xho": "🇿🇦", // Xhosa – South Africa
		
		// Y
		"yao": "🇲🇿", // Yao – Mozambique
		"yap": "🇫🇲", // Yapese – Federated States of Micronesia
		"yid": "🇮🇱", // Yiddish – Israel
		"yor": "🇳🇬", // Yoruba – Nigeria
		"yue": "🇭🇰", // Cantonese – Hong Kong (Chinese)
		
		// Z
		"zap": "🇲🇽", // Zapotec – Mexico
		"zha": "🇨🇳", // Zhuang – China
		"zho": "🇨🇳", // Chinese – China (Mandarin)
		"znd": "🇹🇿", // Zande – Tanzania
		"zul": "🇿🇦", // Zulu – South Africa
	]
	
	public static func genreSymbol(for genre: String) -> String {
		switch genre {
			case "Action": "burst"
			case "Adventure": "map"
			case "Animated", "Animation": "lamp.desk"
			case "Children": "figure.child"
			case "Comedy": "face.smiling"
			case "Crime": "person.fill.viewfinder"
			case "Drama": "theatermasks.fill"
			case "Documentary": "photo.artframe"
			case "Family": "figure.2.and.child.holdinghands"
			case "Fantasy": "wand.and.stars"
			case "History": "crown"
			case "Horror": "figure.run"
			case "Music": "music.note"
			case "Musical": "music.microphone"
			case "Mystery": "magnifyingglass"
			case "Nature": "leaf"
			case "Romance", "Love": "heart"
			case "Sci-Fi", "Science-Fiction", "Science Fiction": "atom"
			case "Sport", "Sports": "soccerball"
			case "Thriller": "waveform.path.ecg"
			case "Trash": "trash"
			case "War": "dot.scope"
			case "Western": "lasso"
			default: "person.crop.square.on.square.angled"
		}
	}
}
