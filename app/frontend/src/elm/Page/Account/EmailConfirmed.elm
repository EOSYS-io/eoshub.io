module Page.Account.EmailConfirmed exposing (Message(..), Model, initModel, update, view)

import Html exposing (Html, button, div, input, li, p, text, ul)
import Html.Events exposing (onClick, onInput)
import Navigation


-- MODEL


type alias Model =
    { confirmToken : String }


initModel : String -> Model
initModel confirmToken =
    { confirmToken = confirmToken }



-- UPDATES


type Message
    = Next


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case msg of
        Next ->
            ( model, Navigation.newUrl "/account/create_keys/" )



-- VIEW


view : Model -> Html Message
view model =
    div []
        [ button [ onClick Next ] [ text "다음" ] ]
