module Component.Account.Page.Created exposing (Message(..), Model, initModel, update, view)

import Html exposing (Html, a, article, br, dd, div, dl, dt, h2, main_, p, text)
import Html.Attributes exposing (attribute, class)
import Html.Events exposing (onClick)
import Navigation
import Translation
    exposing
        ( I18n
            ( AccountCreationCongratulation
            , AccountCreationGoHome
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
view _ language =
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
                    [ text "계정" ]
                , dd []
                    [ text "eosyskoreabp" ]
                , dt []
                    [ text "공개키" ]
                , dd []
                    [ text "EOS55bzfeUCMvJuDZM4hxZbApSMsrdavAR18VuodiyYN5ARVVJBLy" ]
                ]
            , div [ class "btn_area" ]
                [ a [ class "go main button", onClick Home ]
                    [ textViewI18n language AccountCreationGoHome ]
                ]
            ]
        ]
