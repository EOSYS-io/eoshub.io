module Component.Account.Page.EmailConfirmFailure exposing (Message(..), Model, initModel, update, view)

import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (class)
import Translation exposing (Language)


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


view : Model -> Language -> Html Message
view model language =
    div [ class "container join" ]
        [ h1 [] [ text "인증 실패" ] ]
