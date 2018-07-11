module Page.AccountCreate exposing (Message(..), Model, initModel, update, view)

import Html exposing (Html, button, div, input, p, text)
import Html.Attributes exposing (placeholder)
import Html.Events exposing (onClick)


-- MODEL


type alias Model =
    { result : String }


initModel : Model
initModel =
    { result = "" }



-- UPDATES


type Message
    = AccountCreate


update : Message -> Model -> Model
update msg model =
    case msg of
        AccountCreate ->
            { model | result = "result" }



-- VIEW


view : Model -> Html Message
view { result } =
    div []
        [ input [ placeholder "email@example.com" ] []
        , button [ onClick AccountCreate ] [ text "인증 메일 전송" ]
        , p [] [ text result ]
        ]
