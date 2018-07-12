module Translation exposing (Language(Korean, English), I18n(Success), translate, getMessages)


type Language
    = English
    | Korean


type alias Messages =
    { korean : String
    , english : String
    }


type I18n
    = Success


translate : Language -> I18n -> String
translate language i18n =
    let
        { english, korean } =
            getMessages i18n
    in
        case language of
            English ->
                english

            Korean ->
                korean



-- Internal helper function.
-- Note(heejae): Please write i18n messages in this function.


getMessages : I18n -> Messages
getMessages i18n =
    case i18n of
        Success ->
            { korean = "성공!"
            , english = "Success!"
            }
