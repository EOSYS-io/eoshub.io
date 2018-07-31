module Component.Account.Page.CreateKeys exposing (Message(..), Model, initModel, subscriptions, update, view)

import Html exposing (Html, button, div, h1, p, text, ol, li, article, img, dl, dt, dd, textarea, node)
import Html.Attributes exposing (class, attribute, alt, src, id, type_)
import Html.Events exposing (onClick)
import Navigation
import Port exposing (KeyPair)
import View.I18nViews exposing (textViewI18n)
import Translation
    exposing
        ( Language
        , I18n
            ( AccountCreationProgressEmail
            , AccountCreationProgressKeypair
            , AccountCreationProgressCreateNew
            , AccountCreationKeypairGenerated
            , AccountCreationKeypairCaution
            , PublicKey
            , PrivateKey
            , CopyAll
            )
        )


-- MODEL


type alias Model =
    { keys : KeyPair
    , nextEnabled : Bool
    }


initModel : Model
initModel =
    { keys = { privateKey = "", publicKey = "" }
    , nextEnabled = False
    }



-- UPDATES


type Message
    = Next
    | GenerateKeys
    | UpdateKeys KeyPair
    | Copy


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case msg of
        Next ->
            ( model, Navigation.newUrl ("/account/create/" ++ model.keys.publicKey) )

        GenerateKeys ->
            ( model, Port.generateKeys () )

        UpdateKeys keyPair ->
            ( { model | keys = keyPair }, Cmd.none )

        Copy ->
            ( { model | nextEnabled = True }, Port.copy () )



-- VIEW


view : Model -> Language -> Html Message
view model language =
    div [ class "container join" ]
        [ ol [ class "progress bar" ]
            [ li [ class "done" ]
                [ textViewI18n language AccountCreationProgressEmail ]
            , li [ class "ing" ]
                [ textViewI18n language AccountCreationProgressKeypair ]
            , li []
                [ textViewI18n language AccountCreationProgressCreateNew ]
            ]
        , article [ attribute "data-step" "3" ]
            [ h1 []
                [ textViewI18n language AccountCreationKeypairGenerated ]
            , p []
                [ textViewI18n language AccountCreationKeypairCaution ]
            , dl [ class "keybox" ]
                [ dt []
                    [ textViewI18n language PublicKey ]
                , dd []
                    [ text model.keys.publicKey ]
                , dt []
                    [ textViewI18n language PrivateKey ]
                , dd []
                    [ text model.keys.privateKey ]
                ]
            , textarea [ class "hidden_copy_field", id "key", attribute "wai-aria" "hidden" ]
                [ text ("PublicKey:" ++ model.keys.publicKey ++ "\nPrivateKey:" ++ model.keys.privateKey) ]
            , button [ class "button middle copy blue_white", id "copy", type_ "button", onClick Copy ]
                [ textViewI18n language CopyAll ]
            ]
        , div [ class "btn_area" ]
            [ button
                [ class "middle white_blue button"
                , attribute
                    (if model.nextEnabled then
                        "enabled"
                     else
                        "disabled"
                    )
                    ""
                , id "next"
                , type_ "button"
                , onClick Next
                ]
                [ textViewI18n language Translation.Next ]
            ]
        ]



-- SUBSCRIPTIONS


subscriptions : Sub Message
subscriptions =
    Port.receiveKeys UpdateKeys
