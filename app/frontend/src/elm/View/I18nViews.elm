module View.I18nViews exposing (..)

import Translation exposing (Language, toLocale, translate, I18n)
import Html exposing (Html, text)


textViewI18n : Language -> I18n -> Html msg
textViewI18n language i18n =
    text (translate language i18n)
