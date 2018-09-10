module Component.Account.Page.Created exposing (Message(..), Model, initModel, update, view)

import Html exposing (Html, a, article, br, button, div, h1, img, li, ol, p, text)
import Html.Attributes exposing (alt, attribute, class, href, src)
import Html.Events exposing (onClick)
import Navigation
import Translation
    exposing
        ( I18n
            ( AccountCreationCongratulation
            , AccountCreationGoHome
            , AccountCreationProgressCreateNew
            , AccountCreationProgressEmail
            , AccountCreationProgressKeypair
            , AccountCreationWelcome
            , AccountCreationYouCanSignIn
            )
        , Language
        )
import View.I18nViews exposing (textViewI18n)



-- MODEL


type alias Model =
    {}


initModel : Model
initModel =
    {}



-- UPDATES


type Message
    = Home


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case msg of
        Home ->
            ( model, Navigation.newUrl "/" )



-- VIEW


view : Model -> Language -> Html Message
view model language =
    div [ class "container join" ]
        [ ol [ class "progress bar" ]
            [ li [ class "done" ]
                [ textViewI18n language AccountCreationProgressEmail ]
            , li [ class "done" ]
                [ textViewI18n language AccountCreationProgressKeypair ]
            , li [ class "done" ]
                [ textViewI18n language AccountCreationProgressCreateNew ]
            ]
        , article [ attribute "data-step" "5" ]
            [ h1 [ class "finished" ]
                [ textViewI18n language AccountCreationCongratulation
                , br []
                    []
                , textViewI18n language AccountCreationWelcome
                ]
            , p []
                [ textViewI18n language AccountCreationYouCanSignIn ]
            ]
        , div [ class "btn_area" ]
            [ a [ class "middle button blue_white", onClick Home ]
                [ textViewI18n language AccountCreationGoHome ]
            ]
        ]
