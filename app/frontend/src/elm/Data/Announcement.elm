module Data.Announcement exposing (Announcement, announcementDecoder, initAnnouncement)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required)


type alias Announcement =
    { id : Int
    , titleKo : String
    , titleEn : String
    , titleCn : String
    , active : Bool
    , bodyKo : String
    , bodyEn : String
    , bodyCn : String
    , publishedAt : String
    , endedAt : String
    }


initAnnouncement : Announcement
initAnnouncement =
    { id = 0
    , titleKo = ""
    , titleEn = ""
    , titleCn = ""
    , active = False
    , bodyKo = ""
    , bodyEn = ""
    , bodyCn = ""
    , publishedAt = ""
    , endedAt = ""
    }


announcementDecoder : Decoder Announcement
announcementDecoder =
    decode Announcement
        |> required "id" Decode.int
        |> required "title_ko" Decode.string
        |> required "title_en" Decode.string
        |> required "title_cn" Decode.string
        |> required "active" Decode.bool
        |> required "body_ko" Decode.string
        |> required "body_en" Decode.string
        |> required "body_cn" Decode.string
        |> required "published_at" (Decode.oneOf [ Decode.string, Decode.null "" ])
        |> required "ended_at" (Decode.oneOf [ Decode.string, Decode.null "" ])
