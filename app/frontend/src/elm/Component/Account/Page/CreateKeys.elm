module Component.Account.Page.CreateKeys exposing (Message(..), Model, initModel, subscriptions, update, view)

import Html exposing (Html, article, button, dd, div, dl, dt, h2, img, li, main_, node, ol, p, span, text, textarea)
import Html.Attributes exposing (alt, attribute, class, id, src, type_)
import Html.Events exposing (onClick)
import Navigation
import Port exposing (KeyPair)
import Translation
    exposing
        ( I18n
            ( AccountCreationKeypairCaution
            , AccountCreationKeypairGenerated
            , AccountCreationProgressCreateNew
            , AccountCreationProgressEmail
            , AccountCreationProgressKeypair
            , CopyAll
            , PrivateKey
            , PublicKey
            )
        , Language
        )
import View.I18nViews exposing (textViewI18n)



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
    main_ [ class "join" ]
        [ article [ attribute "data-step" "copy-key-pair" ]
            [ span [ class "progress", attribute "data-progress" "02" ]
                [ text "02" ]
            , h2 []
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
            , div [ class "btn_area" ]
                [ button [ class "button undo", id "copy", type_ "button", onClick Copy ]
                    [ textViewI18n language CopyAll ]
                , button
                    [ class "ok button"
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
            , textarea [ class "hidden_copy_field", id "key", attribute "wai-aria" "hidden" ]
                [ text ("PublicKey:" ++ model.keys.publicKey ++ "\nPrivateKey:" ++ model.keys.privateKey) ]
            ]
        ]



-- SUBSCRIPTIONS


subscriptions : Sub Message
subscriptions =
    Port.receiveKeys UpdateKeys
