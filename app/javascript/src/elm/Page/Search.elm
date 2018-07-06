module Page.Search exposing (..)

import Html exposing (Html, div, input, button, text, p)
import Html.Attributes exposing (placeholder)
import Html.Events exposing (onClick)


-- Model


type alias Model =
    { result : String }


initModel : Model
initModel =
    { result = "" }



-- Updates


type Message
    = Search


update : Message -> Model -> Model
update msg model =
    case msg of
        Search ->
            { model | result = "result" }



-- View


view : Model -> Html Message
view model =
    div []
        [ input [ placeholder "account / public key" ] []
        , button [ onClick Search ] [ text "검색" ]
        , p [] [ text model.result ]
        ]
