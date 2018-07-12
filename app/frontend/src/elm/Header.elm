module Header exposing (..)

import Html exposing (Html, div, input, button, text)
import Html.Attributes exposing (placeholder)
import Html.Events exposing (onInput)


-- MODEL


type alias Model =
    { searchInput : String
    , eosPrice : Int
    , ramPrice : Int
    }


initModel : Model
initModel =
    { searchInput = ""
    , eosPrice = 0
    , ramPrice = 0
    }



-- UPDATE


type Message
    = InputSearch String


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        InputSearch value ->
            ( { model | searchInput = value }, Cmd.none )



-- VIEW


view : Model -> Html Message
view model =
    div []
        [ input [ placeholder "계정명, 퍼블릭키 검색하기", onInput InputSearch ] []
        , button [] [ text "검색하기" ]
        ]
