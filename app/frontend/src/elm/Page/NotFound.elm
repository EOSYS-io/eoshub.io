module Page.NotFound exposing (view)

import Html exposing (Html, div, h1, text)


-- VIEW


view : Html message
view =
    div []
        [ h1 [] [ text "Not Found" ] ]
