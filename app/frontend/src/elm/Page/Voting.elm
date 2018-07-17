module Page.Voting exposing (..)

import Html exposing (Html, div, h1, input, text)
import Translation exposing (Language)
import Util.Flags exposing (Flags)


-- MODEL


type alias Model =
    { bp : String
    , account : String
    , flags : Flags
    }


initModel : Flags -> Model
initModel flags =
    { bp = ""
    , account = ""
    , flags = flags
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


view : Language -> Model -> Html Message
view _ { bp, account } =
    div []
        [ h1 [] [ text (bp ++ account) ]
        , input [] []
        ]
