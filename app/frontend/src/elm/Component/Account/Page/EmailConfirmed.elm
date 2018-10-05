module Component.Account.Page.EmailConfirmed exposing (Message(..), Model, initModel, update, view)

import Html exposing (Html, article, button, div, h2, main_, p)
import Html.Attributes exposing (attribute, class, type_)
import Html.Events exposing (onClick)
import Navigation
import Translation
    exposing
        ( I18n
            ( AccountCreationEmailConfirmed
            , ClickNext
            )
        , Language
        )
import View.I18nViews exposing (textViewI18n)



-- MODEL


type alias Model =
    { email : String }


initModel : Maybe String -> Model
initModel maybeEmail =
    let
        email =
            case maybeEmail of
                Nothing ->
                    ""

                Just emailAddr ->
                    emailAddr
    in
    { email = email }



-- UPDATES


type Message
    = Next


update : Message -> Model -> String -> ( Model, Cmd Message )
update msg model _ =
    case msg of
        Next ->
            ( model, Navigation.newUrl "/account/create_keys" )



-- VIEW


view : Model -> Language -> Html Message
view _ language =
    main_ [ class "join" ]
        [ article [ attribute "data-step" "validate-email-ok" ]
            [ h2 []
                [ textViewI18n language AccountCreationEmailConfirmed ]
            , p []
                [ textViewI18n language ClickNext ]
            , div [ class "btn_area" ]
                [ button [ class "ok button", type_ "button", onClick Next ]
                    [ textViewI18n language Translation.Next ]
                ]
            ]
        ]
