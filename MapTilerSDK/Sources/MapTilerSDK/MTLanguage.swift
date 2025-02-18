//
//  MTLanguage.swift
//  MapTilerSDK
//

public enum MTLanguage: @unchecked Sendable, Codable {
    case special(MTSpecialLanguage)
    case country(MTCountryLanguage)

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .special(let language):
            try container.encode("maptilersdk.Language.\(language.rawValue.uppercased())")
        case .country(let country):
            try container.encode(country.rawValue)
        }
    }
}

public enum MTSpecialLanguage: String, Codable {
    /// The default language of the device.
    case auto

    /// The international name. This option is equivalent to OSM's name int_name.
    case international

    /// The default fallback language in the Latin charset.
    case latin

    /// The local language for each country.
    case local

    /// The default fallback language in the non-Latin charset.
    case nonLatin

    /// The language defined by the style.
    case style

    /// Preferred language from the user settings and "default name"
    ///
    /// This mode is useful when a user needs to access both local names and English names,
    /// for example, when traveling abroad where signs are likely to be available only in the local language
    case visitor

    /// English and "default name"
    ///
    /// This mode is useful when a user needs to access both local names and English names,
    /// for example, when traveling abroad where signs are likely to be available only in the local language
    case visitorEnglish
}

/// Languages available for MTMapView object.
public enum MTCountryLanguage: String, Codable {
    /// Albanian language.
    case albanian = "sq"

    /// Amharic language.
    case amharic = "am"

    /// Arabic language.
    case arabic = "ar"

    /// Armenian language.
    case armenian = "hy"

    /// Azerbaijani language.
    case azerbaijani = "az"

    /// Basque language.
    case basque = "eu"

    /// Belarusian language.
    case belarusian = "be"

    /// Bengali language.
    case bengali = "bn"

    /// Bosnian language.
    case bosnian = "bs"

    /// Breton language.
    case breton = "br"

    /// Bulgarian language.
    case bulgarian = "bg"

    /// Catalan language.
    case catalan = "ca"

    /// Chinese  language.
    case chinese = "zh"

    /// Traditional Chinese language.
    case traditionalChinese = "zh-Hant"

    /// Simplified Chinese language.
    case simplifiedChinese = "zh-Hans"

    /// Corsican language.
    case corsican = "co"

    /// Croatian language.
    case croatian = "hr"

    /// Czech language.
    case czech = "cs"

    /// Danish language.
    case danish = "da"

    /// Dutch language.
    case dutch = "nl"

    /// English language.
    case english = "en"

    /// Esperanto language.
    case esperanto = "eo"

    /// Estonian language.
    case estonian = "et"

    /// Finnish language.
    case finnish = "fi"

    /// French language.
    case french = "fr"

    /// Frisian language.
    case frisian = "fy"

    /// Galician language.
    case galician = "gl"

    /// Georgian language.
    case georgian = "ka"

    /// German language.
    case german = "de"

    /// Greek language.
    case greek = "el"

    /// Hebrew language.
    case hebrew = "he"

    /// Hindi language.
    case hindi = "hi"

    /// Hungarian language.
    case hungarian = "hu"

    /// Icelandic language.
    case icelandic = "is"

    /// Indonesian language.
    case indonesian = "id"

    /// Irish language.
    case irish = "ga"

    /// Italian language.
    case italian = "it"

    /// Japanese language.
    case japanese = "ja"

    /// Japanese language in Hiragana form.
    case japaneseHiragana = "ja-Hira"

    /// Japanese language (latin script).
    case japaneseLatin = "ja-Latn"

    /// Japanese language in Kana form (non-latin script).
    case japaneseKana = "ja_kana"

    /// Kannada language
    case kannada = "kn"

    /// Kazakh language.
    case kazakh = "kk"

    /// Korean language.
    case korean = "ko"

    /// Korean language (latin script).
    case koreanlatin = "ko-Latn"

    /// Kurdish language.
    case kurdish = "ku"

    /// Classical latin language.
    case classicalLatin = "la"

    /// Latvian language.
    case latvian = "lv"

    /// Lithuanian language.
    case lithuanian = "lt"

    /// Luxembourgish language.
    case luxembourgish = "lb"

    /// Macedonian language.
    case macedonian = "mk"

    /// Malay language.
    case malay = "ml"

    /// Maltese language.
    case maltese = "mt"

    /// Marathi language.
    case marathi = "mr"

    /// Mongolian language.
    case mongolian = "mn"

    /// Nepali language.
    case nepali = "ne"

    /// Norwegian language.
    case norwegian = "no"

    /// Occitan language.
    case occitan = "oc"

    /// Persian language.
    case persian = "fa"

    /// Polish language.
    case polish = "pl"

    /// Portuguese language.
    case portuguese = "pt"

    /// Punjabi language.
    case punjabi = "pa"

    /// Western Punjabi language.
    case westernPunjabi = "pnb"

    /// Romanian language.
    case romanian = "ro"

    /// Romansh language.
    case romansh = "rm"

    /// Russian language.
    case russian = "ru"

    /// Sardinian language.
    case sardinian = "sc"

    /// Scottish Gaelic language.
    case scottishGaelic = "gd"

    /// Serbian language.
    case serbianCyrillic = "sr"

    /// Serbian language.
    case serbianLatin = "sr-Latn"

    /// Slovak language.
    case slovak = "sk"

    /// Slovenian language.
    case slovene = "sl"

    /// Spanish language.
    case spanish = "es"

    /// Swahili language.
    case swahili = "sw"

    /// Swedish language.
    case swedish = "sv"

    /// Tagalog language.
    case tagalog = "tl"

    /// Tamil language.
    case tamil = "ta"

    /// Telugu language.
    case telugu = "te"

    /// Thai language.
    case thai = "th"

    /// Turkish language.
    case turkish = "tr"

    /// Ukrainian language.
    case ukrainian = "uk"

    /// Urdu language.
    case urdu = "ur"

    /// Vietnamese language.
    case vietnamese = "vi"

    /// Welsh language.
    case welsh = "cy"
}
