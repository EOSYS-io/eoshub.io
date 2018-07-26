module Component.Main.Page.NotFound exposing (view)

import Html exposing (Html, div, h1, text)
import Translation exposing (Language)


-- VIEW


view : Language -> Html message
view _ =
    div []
        [ h1 [] [ text "Not Found" ] ]
