module Component.Main.Page.ChangeKey exposing (Message, Model, initModel, update, view)

import Data.Account exposing (Account)
import Html
    exposing
        ( Html
        , button
        , div
        , form
        , h2
        , h3
        , input
        , li
        , main_
        , p
        , span
        , strong
        , text
        , ul
        )
import Html.Attributes exposing (attribute, class, disabled, placeholder, type_)
import Html.Events exposing (onInput)
import Translation exposing (I18n(..), Language(..), translate)
import Util.Validation exposing (PublicKeyStatus(..), validatePublicKey)
import Util.WalletDecoder exposing (Wallet)


type Message
    = InputActiveKey String
    | InputOwnerKey String


type alias Model =
    { activeKey : String
    , activeKeyValidation : PublicKeyStatus
    , ownerKey : String
    , ownerKeyValidation : PublicKeyStatus
    , isValid : Bool
    }


initModel : Model
initModel =
    { activeKey = ""
    , activeKeyValidation = EmptyPublicKey
    , ownerKey = ""
    , ownerKeyValidation = EmptyPublicKey
    , isValid = False
    }


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        InputActiveKey inputKey ->
            ( validate { model | activeKey = inputKey }, Cmd.none )

        InputOwnerKey inputKey ->
            ( validate { model | ownerKey = inputKey }, Cmd.none )


view : Language -> Model -> Wallet -> Html Message
view language { activeKey, activeKeyValidation, ownerKey, ownerKeyValidation, isValid } { account, authority } =
    main_ [ class "change account key" ]
        [ h2 []
            [ text (translate language ChangeKey) ]
        , p []
            [ text (translate language ChangeKeyDetail) ]
        , div [ class "container" ]
            [ div [ class "account summary" ]
                [ h3 []
                    [ text (translate language MyAccountDefault)
                    , strong []
                        [ text account ]
                    ]
                ]
            , div [ class "alert notice" ]
                [ h3 []
                    [ text (translate language Caution) ]
                , p []
                    [ text (translate language CautionDetail) ]
                ]
            , let
                baseSpanClass =
                    "validate description"

                getSpanAttributes validation =
                    case validation of
                        EmptyPublicKey ->
                            ( baseSpanClass, "" )

                        ValidPublicKey ->
                            ( baseSpanClass ++ " true", translate language ValidKey )

                        InvalidPublicKey ->
                            ( baseSpanClass ++ " false", translate language InvalidKey )

                ( ownerClass, ownerText ) =
                    getSpanAttributes ownerKeyValidation

                ( activeClass, activeText ) =
                    getSpanAttributes activeKeyValidation
              in
              form []
                [ ul []
                    [ li []
                        [ input
                            [ placeholder (translate language TypeOwnerKey)
                            , type_ "text"
                            , onInput <| InputOwnerKey
                            , attribute "maxlength" "53"
                            , Html.Attributes.value ownerKey
                            , disabled (authority /= "owner")
                            ]
                            []
                        , span [ class ownerClass ]
                            [ text ownerText ]
                        ]
                    , li []
                        [ input
                            [ placeholder (translate language TypeActiveKey)
                            , type_ "text"
                            , onInput <| InputActiveKey
                            , attribute "maxlength" "53"
                            , Html.Attributes.value activeKey
                            , disabled (authority /= "owner" && authority /= "active")
                            ]
                            []
                        , span [ class activeClass ]
                            [ text activeText ]
                        ]
                    ]
                ]
            , div [ class "btn_area align right" ]
                [ button [ class "ok button", disabled (not isValid), type_ "button" ]
                    [ text (translate language Confirm) ]
                ]
            ]
        ]


validate : Model -> Model
validate ({ activeKey, ownerKey } as model) =
    let
        activeValidation =
            activeKey |> validatePublicKey

        ownerValidation =
            ownerKey |> validatePublicKey

        isValid =
            ((activeValidation == ValidPublicKey)
                && (ownerValidation == ValidPublicKey)
            )
                || ((activeValidation == ValidPublicKey)
                        && (ownerValidation == EmptyPublicKey)
                   )
                || ((activeValidation == EmptyPublicKey)
                        && (ownerValidation == ValidPublicKey)
                   )
    in
    { model
        | activeKeyValidation = activeValidation
        , ownerKeyValidation = ownerValidation
        , isValid = isValid
    }
