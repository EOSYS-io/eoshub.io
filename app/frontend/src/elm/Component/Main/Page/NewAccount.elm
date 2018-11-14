module Component.Main.Page.NewAccount exposing (Message, Model, initModel, update, view)

import Data.Account exposing (Account)
import Html
    exposing
        ( Html
        , button
        , dd
        , div
        , dl
        , dt
        , form
        , h2
        , h3
        , input
        , li
        , main_
        , p
        , section
        , span
        , strong
        , text
        , ul
        )
import Html.Attributes
    exposing
        ( autofocus
        , class
        , disabled
        , id
        , placeholder
        , type_
        )
import Html.Events exposing (onInput)
import Http
import Translation exposing (I18n(..), Language, translate)
import Util.HttpRequest exposing (getAccount)
import Util.Validation
    exposing
        ( AccountStatus(..)
        , PublicKeyStatus(..)
        , VerificationRequestStatus(..)
        , validateAccountForCreation
        , validatePublicKey
        )


type Message
    = InputActiveKey String
    | InputOwnerKey String
    | InputAccountName String
    | OnFetchAccountToVerify (Result Http.Error Account)


type alias Model =
    { activeKey : String
    , activeKeyValidation : PublicKeyStatus
    , ownerKey : String
    , ownerKeyValidation : PublicKeyStatus
    , account : String
    , accountValidation : AccountStatus
    , isValid : Bool
    }


initModel : Model
initModel =
    { activeKey = ""
    , activeKeyValidation = EmptyPublicKey
    , ownerKey = ""
    , ownerKeyValidation = EmptyPublicKey
    , account = ""
    , accountValidation = EmptyAccount
    , isValid = False
    }


update : Message -> Model -> Account -> ( Model, Cmd Message )
update message model _ =
    case message of
        InputActiveKey inputKey ->
            ( validateKey { model | activeKey = inputKey }, Cmd.none )

        InputOwnerKey inputKey ->
            ( validateKey { model | ownerKey = inputKey }, Cmd.none )

        InputAccountName inputAccountName ->
            validateAccountName { model | account = inputAccountName } NotSent

        OnFetchAccountToVerify (Ok _) ->
            validateAccountName model Succeed

        OnFetchAccountToVerify (Err _) ->
            validateAccountName model Fail


view : Language -> Model -> Account -> Html Message
view language { account, accountValidation, activeKey, activeKeyValidation, ownerKey, ownerKeyValidation, isValid } { accountName } =
    main_ [ class "create account" ]
        [ h2 []
            [ text (translate language CreateAccount) ]
        , p []
            [ text (translate language CreateAccountDetail) ]
        , div [ class "container" ]
            [ div [ class "account summary" ]
                [ h3 []
                    [ text (translate language MyAccountDefault)
                    , strong []
                        [ text accountName ]
                    ]
                ]
            , let
                ( accountSpanI18n, addedClass ) =
                    case accountValidation of
                        ValidAccount ->
                            ( AccountCreationNameAlreadyExist, " false" )

                        InexistentAccount ->
                            ( AccountCreationNameValid, " true" )

                        EmptyAccount ->
                            ( AccountExample, "" )

                        AccountToBeVerified ->
                            ( EmptyMessage, "" )

                        InvalidAccount ->
                            ( AccountCreationNameInvalid, " false" )

                getPublicKeyAttrs pubKeyValidation isActive =
                    case pubKeyValidation of
                        EmptyPublicKey ->
                            ( ""
                            , if isActive then
                                TypeActiveKeyDesc

                              else
                                TypeOwnerKeyDesc
                            )

                        ValidPublicKey ->
                            ( " true", ValidKey )

                        InvalidPublicKey ->
                            ( " false", InvalidKey )

                ( activeKeyAddedClass, activeKeyI18n ) =
                    getPublicKeyAttrs activeKeyValidation True

                ( ownerKeyAddedClass, ownerKeyI18n ) =
                    getPublicKeyAttrs ownerKeyValidation False
              in
              form []
                [ ul []
                    [ li []
                        [ input
                            [ autofocus True
                            , placeholder (translate language AccountPlaceholder)
                            , type_ "text"
                            , Html.Attributes.value account
                            , onInput <| InputAccountName
                            ]
                            []
                        , span [ class ("validate description" ++ addedClass) ]
                            [ text (translate language accountSpanI18n) ]
                        ]
                    , li []
                        [ input
                            [ placeholder (translate language TypeActiveKey)
                            , type_ "text"
                            , Html.Attributes.value activeKey
                            , onInput <| InputActiveKey
                            ]
                            []
                        , span [ class ("validate description" ++ activeKeyAddedClass) ]
                            [ text (translate language activeKeyI18n) ]
                        ]
                    , li []
                        [ input
                            [ placeholder (translate language TypeOwnerKey)
                            , type_ "text"
                            , Html.Attributes.value ownerKey
                            , onInput <| InputOwnerKey
                            ]
                            []
                        , span [ class ("validate description" ++ ownerKeyAddedClass) ]
                            [ text (translate language ownerKeyI18n) ]
                        ]
                    ]
                ]
            , div [ class "btn_area align right" ]
                [ button [ class "ok button", disabled (not isValid), type_ "button" ]
                    [ text (translate language Confirm) ]
                ]
            ]
        , section [ class "create_account modal popup", id "popup" ]
            [ div [ class "wrapper" ]
                [ h2 []
                    [ text (translate language CreateAccount) ]
                , p []
                    [ text "현재 계정에서 보유한 토큰 수량중 아래에 명시된 수량만큼 새롭게 생성되는 계정으로 전송됩니다. " ]
                , dl []
                    [ dt []
                        [ text "CPU" ]
                    , dd []
                        [ text "0.1 EOS" ]
                    , dt []
                        [ text "NET" ]
                    , dd []
                        [ text "0.1 EOS" ]
                    , dt []
                        [ text "RAM" ]
                    , dd []
                        [ text "4 KB (4096 bytes)" ]
                    ]
                , div [ class "btn_area choice" ]
                    [ button [ class "rent choice button", type_ "button" ]
                        [ text "임대해주기" ]
                    , button [ class "send choice button", type_ "button" ]
                        [ text "전송하기" ]
                    ]
                , div [ class "btn_area" ]
                    [ button [ class "ok button", disabled True, type_ "button" ]
                        [ text (translate language Confirm) ]
                    ]
                , button [ class "close", id "closePopup", type_ "button" ]
                    [ text (translate language Close) ]
                ]
            ]
        ]


validateKey : Model -> Model
validateKey ({ activeKey, ownerKey } as model) =
    let
        ownerKeyValidation =
            validatePublicKey ownerKey

        activeKeyValidation =
            validatePublicKey activeKey
    in
    validateForm { model | activeKeyValidation = activeKeyValidation, ownerKeyValidation = ownerKeyValidation }


validateAccountName : Model -> VerificationRequestStatus -> ( Model, Cmd Message )
validateAccountName ({ account } as model) requestStatus =
    let
        accountValidation =
            validateAccountForCreation account requestStatus

        accountCmd =
            if accountValidation == AccountToBeVerified then
                account
                    |> getAccount
                    |> Http.send OnFetchAccountToVerify

            else
                Cmd.none
    in
    ( validateForm { model | accountValidation = accountValidation }, accountCmd )


validateForm : Model -> Model
validateForm ({ accountValidation, ownerKeyValidation, activeKeyValidation } as model) =
    let
        isValid =
            (accountValidation == InexistentAccount)
                && (ownerKeyValidation == ValidPublicKey)
                && (activeKeyValidation == ValidPublicKey)
    in
    { model | isValid = isValid }
