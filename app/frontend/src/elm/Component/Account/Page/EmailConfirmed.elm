module Component.Account.Page.EmailConfirmed exposing (Message(..), Model, initModel, update, view)

import Html exposing (Html, button, div, input, li, p, text, ul, ol, article, h1, img, h2)
import Html.Attributes exposing (class, attribute, alt, src, type_)
import Html.Events exposing (onClick, onInput)
import Navigation
import Translation
    exposing
        ( Language
        , I18n
            ( AccountCreationProgressEmail
            , AccountCreationProgressKeypair
            , AccountCreationProgressCreateNew
            , AccountCreationEmailConfirmed
            , ClickNext
            )
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
update msg model confirmToken =
    case msg of
        Next ->
            ( model, Navigation.newUrl ("/account/create_keys") )



-- VIEW


view : Model -> Language -> Html Message
view model language =
    div [ class "container join" ]
        [ ol [ class "progress bar" ]
            [ li [ class "done" ]
                [ textViewI18n language AccountCreationProgressEmail ]
            , li []
                [ textViewI18n language AccountCreationProgressKeypair ]
            , li []
                [ textViewI18n language AccountCreationProgressCreateNew ]
            ]
        , article [ attribute "data-step" "2" ]
            [ h1 []
                [ textViewI18n language AccountCreationEmailConfirmed ]
            , p []
                [ textViewI18n language ClickNext ]
            , h2 []
                [ text model.email ]
            ]
        , div [ class "btn_area" ]
            [ button [ class "middle white_blue next button", type_ "button", onClick Next ]
                [ textViewI18n language Translation.Next ]
            ]
        ]
