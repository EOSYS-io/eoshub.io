module Page.AccountCreate.CreateKeys exposing (Message(..), Model, initModel, update, view)

import Html exposing (Html, button, div, h1, text)
import Html.Events exposing (onClick)
import Util.Flags exposing (Flags)


-- MODEL


type alias Model =
    { flags : Flags }


initModel : Flags -> Model
initModel flags =
    { flags = flags }



-- UPDATES


type Message
    = Next


update : Message -> Model -> Model
update msg model =
    case msg of
        Next ->
            model



-- VIEW


view : Model -> Html Message
view model =
    div []
        [ h1 [] [ text "키 쌍을 만들었어요." ]
        , button [ onClick Next ] [ text "다음" ]
        ]
