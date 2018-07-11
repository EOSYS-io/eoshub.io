module Page.Search exposing (Message(..), Model, initModel, update, view)

import Html exposing (Html, div, input, button, text, p)
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
    = Search


update : Message -> Model -> Model
update msg model =
    case msg of
        Search ->
            { model | result = "result" }



-- VIEW


view : Model -> Html Message
view { result } =
    div []
        [ input [ placeholder "account / public key" ] []
        , button [ onClick Search ] [ text "검색" ]
        , p [] [ text result ]
        ]
