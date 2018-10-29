module View.Common exposing (addSearchLink)

import Html exposing (Html, a)
import Html.Events exposing (onClick)


addSearchLink : message -> Html message -> Html message
addSearchLink newUrlMsg contentHtml =
    a [ onClick newUrlMsg ] [ contentHtml ]
