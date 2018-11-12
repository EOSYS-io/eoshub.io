module Component.Account.Page.Created exposing (Message(..), Model, initModel, update, view)

import Html exposing (Html, a, article, br, dd, div, dl, dt, h2, main_, p, text)
import Html.Attributes exposing (attribute, class, href, target)
import Html.Events exposing (onClick)
import Navigation
import Translation
    exposing
        ( I18n(..)
        , Language
        )
import View.I18nViews exposing (textViewI18n)



-- MODEL


type alias Model =
    { eosAccount : String
    , publicKey : String
    }


initModel : Maybe String -> Maybe String -> Model
initModel maybeEosAccount maybePublicKey =
    let
        eosAccount =
            case maybeEosAccount of
                Just string ->
                    string

                Nothing ->
                    ""

        publicKey =
            case maybePublicKey of
                Just string ->
                    string

                Nothing ->
                    ""
    in
    { eosAccount = eosAccount
    , publicKey = publicKey
    }



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
view { eosAccount, publicKey } language =
    main_ [ class "join" ]
        [ article [ attribute "data-step" "done" ]
            [ h2 []
                [ textViewI18n language AccountCreationCongratulation
                , br []
                    []
                , textViewI18n language AccountCreationWelcome
                ]
            , p []
                [ textViewI18n language AccountCreationYouCanSignIn ]
            , dl [ class "keybox" ]
                [ dt []
                    [ textViewI18n language Account ]
                , dd []
                    [ text eosAccount ]
                , dt []
                    [ textViewI18n language PublicKey ]
                , dd []
                    [ text publicKey ]
                ]
            , div [ class "btn_area" ]
                [ a [ class "go main button", onClick Home ]
                    [ textViewI18n language AccountCreationGoHome ]
                ]
            , div [ class "event disposable banner" ]
                [ p []
                    [ textViewI18n language CoSponsoredByEosdaq ]
                , p []
                    [ a [ href "https://eosdaq.com/", target "_blank" ]
                        [ textViewI18n language GotoEosdaq ]
                    ]
                ]
            ]
        ]
