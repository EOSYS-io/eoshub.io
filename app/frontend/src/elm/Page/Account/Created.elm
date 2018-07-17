module Page.Account.Created exposing (Message(..), Model, initModel, update, view)

import Html exposing (Html, button, div, h1, text)
import Html.Events exposing (onClick)


-- MODEL


type alias Model =
    {}


initModel : Model
initModel =
    {}



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
        [ h1 [] [ text "이오스 계정을 만들었어요." ]
        , button [ onClick Next ] [ text "다음" ]
        ]
