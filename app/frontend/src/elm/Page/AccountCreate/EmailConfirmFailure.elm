module Page.AccountCreate.EmailConfirmFailure exposing (Message(..), Model, initModel, update, view)

import Html exposing (Html, div, h1, text)
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
        [ h1 [] [ text "인증 실패" ] ]
