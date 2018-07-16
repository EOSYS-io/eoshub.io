module Page.Account.EmailConfirmed exposing (Message(..), Model, initModel, update, view)

import Html exposing (Html, button, div, input, li, p, text, ul)
import Html.Events exposing (onClick, onInput)
import Util.Flags exposing (Flags)


-- MODEL


type alias Model =
    { flags : Flags, confirm_token : String }


initModel : ( Flags, String ) -> Model
initModel ( flags, confirm_token ) =
    { flags = flags, confirm_token = confirm_token }



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
        [ button [ onClick Next ] [ text "다음" ] ]
