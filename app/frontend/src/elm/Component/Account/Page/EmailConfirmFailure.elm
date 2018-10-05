module Component.Account.Page.EmailConfirmFailure exposing (Message(..), Model, initModel, update, view)

import Html exposing (Html, div, h2)
import Html.Attributes exposing (class)
import Translation exposing (I18n(AccountCreationEmailConfirmFailure), Language)
import View.I18nViews exposing (textViewI18n)



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
view _ language =
    div [ class "join" ]
        [ h2 [] [ textViewI18n language AccountCreationEmailConfirmFailure ] ]
