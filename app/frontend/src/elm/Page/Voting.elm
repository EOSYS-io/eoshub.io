module Page.Voting exposing (..)

import Html exposing (Html, div, h1, text, input)


-- MODEL


type alias Model =
    { bp : String
    , account : String
    }


initModel : Model
initModel =
    { bp = ""
    , account = ""
    }



-- UPDATE


type Message
    = BpInput String
    | AccountInput String


update : Message -> Model -> Model
update message model =
    case message of
        BpInput val ->
            { model | bp = val }

        AccountInput val ->
            { model | account = val }



-- VIEW


view : Model -> Html Message
view { bp, account } =
    div []
        [ h1 [] [ text (bp ++ account) ]
        , input [] []
        ]
