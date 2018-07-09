module Page.Voting exposing (..)

import Html exposing (Html, div, h1, text, input)


-- Model


type alias Model =
    { bp : String
    , account : String
    }


initModel : Model
initModel =
    { bp = ""
    , account = ""
    }



-- Update


type Message
    = BpInput String
    | AccountInput String


update : Message -> Model -> Model
update msg model =
    case msg of
        BpInput val ->
            { model | bp = val }

        AccountInput val ->
            { model | account = val }



-- View


view : model -> Html Message
view model =
    div []
        [ h1 [] [ text "voting page" ]
        , input [] []
        ]
