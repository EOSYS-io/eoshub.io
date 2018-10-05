module View.I18nViews exposing (textViewI18n)

import Html exposing (Html, text)
import Translation exposing (I18n, Language, translate)


textViewI18n : Language -> I18n -> Html msg
textViewI18n language i18n =
    text (translate language i18n)
