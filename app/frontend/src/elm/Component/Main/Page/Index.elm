module Component.Main.Page.Index exposing (Message(ChangeUrl), view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Translation exposing (I18n(..), Language, translate)


-- MESSAGE --


type Message
    = ChangeUrl String



-- VIEW --


view : Language -> Html Message
view language =
    section [ class "action view panel" ]
        [ a
            [ style [ ( "cursor", "pointer" ) ]
            , onClick (ChangeUrl "/transfer")
            ]
            [ div [ class "card transfer" ]
                [ h3 [] [ text (translate language Transfer) ]
                , p [] [ text (translate language TransferDesc) ]
                ]
            ]
        ]
