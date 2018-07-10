module Page.NotFound exposing (..)

import Html exposing (Html, div, h1, text)


-- VIEW


view : Html msg
view =
    div []
        [ h1 [] [ text "Not Found" ] ]
