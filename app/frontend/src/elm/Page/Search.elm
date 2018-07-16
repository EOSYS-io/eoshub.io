module Page.Search exposing (Message(..), Model, initModel, update, view)

import Html exposing (Html, button, div, input, p, text)
import Html.Attributes exposing (placeholder)
import Html.Events exposing (onClick)
import Util.Flags exposing (Flags)


-- MODEL


type alias Model =
    { result : String, flags : Flags }


initModel : Flags -> Model
initModel flags =
    { result = "", flags = flags }



-- UPDATE


type Message
    = Search


update : Message -> Model -> Model
update message model =
    case message of
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
