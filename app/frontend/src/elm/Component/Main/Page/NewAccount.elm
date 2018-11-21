module Component.Main.Page.NewAccount exposing
    ( Message
    , Model
    , initModel
    , update
    , validateAccountName
    , validateKey
    , view
    )

import Data.Account exposing (Account)
import Data.Action as Action exposing (encodeActions)
import Data.Common exposing (Setting)
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
        ( attribute
        , autofocus
        , class
        , disabled
        , id
        , placeholder
        , type_
        )
import Html.Events exposing (onClick, onInput)
import Http
import Port
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
    | ToggleModal
    | SetIsTransfer Bool
    | PushAction


type alias Model =
    { activeKey : String
    , activeKeyValidation : PublicKeyStatus
    , ownerKey : String
    , ownerKeyValidation : PublicKeyStatus
    , account : String
    , accountValidation : AccountStatus
    , isValid : Bool
    , modalOpened : Bool
    , isTransfer : Bool
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
    , modalOpened = False
    , isTransfer = False
    }


update : Message -> Model -> Account -> Setting -> ( Model, Cmd Message )
update message ({ account, activeKey, ownerKey, modalOpened, isTransfer } as model) { accountName } { newAccountCpu, newAccountNet, newAccountRam } =
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

        ToggleModal ->
            ( { model | modalOpened = not modalOpened }, Cmd.none )

        SetIsTransfer newIsTransfer ->
            ( { model | isTransfer = newIsTransfer }, Cmd.none )

        PushAction ->
            let
                getAuth key =
                    { threshold = 1
                    , keys = [ { key = key, weight = 1 } ]
                    , accounts = []
                    , waits = []
                    }

                newaccountParams =
                    { creator = accountName
                    , name = account
                    , active = getAuth activeKey
                    , owner = getAuth ownerKey
                    }

                buyrambytesParams =
                    { payer = accountName
                    , receiver = account
                    , bytes = newAccountRam
                    }

                delegatebwParams =
                    { from = accountName
                    , receiver = account
                    , stakeNetQuantity = newAccountNet
                    , stakeCpuQuantity = newAccountCpu
                    , transfer =
                        if isTransfer then
                            1

                        else
                            0
                    }

                actions =
                    [ newaccountParams |> Action.Newaccount
                    , buyrambytesParams |> Action.Buyrambytes
                    , delegatebwParams |> Action.Delegatebw
                    ]

                cmd =
                    actions |> encodeActions "newaccount" |> Port.pushAction
            in
            ( { model | modalOpened = not modalOpened }, cmd )


view : Language -> Model -> Account -> Setting -> Html Message
view language { account, accountValidation, activeKey, activeKeyValidation, ownerKey, ownerKeyValidation, isValid, modalOpened, isTransfer } { accountName } { newAccountCpu, newAccountNet, newAccountRam } =
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
                            ( if isActive then
                                TypeActiveKeyDesc

                              else
                                TypeOwnerKeyDesc
                            , ""
                            )

                        ValidPublicKey ->
                            ( ValidKey, " true" )

                        InvalidPublicKey ->
                            ( InvalidKey, " false" )

                ( activeKeyI18n, activeKeyAddedClass ) =
                    getPublicKeyAttrs activeKeyValidation True

                ( ownerKeyI18n, ownerKeyAddedClass ) =
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
                            , attribute "maxlength" "12"
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
                            , attribute "maxlength" "53"
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
                            , attribute "maxlength" "53"
                            ]
                            []
                        , span [ class ("validate description" ++ ownerKeyAddedClass) ]
                            [ text (translate language ownerKeyI18n) ]
                        ]
                    ]
                ]
            , div [ class "btn_area align right" ]
                [ button
                    [ class "ok button"
                    , disabled (accountName == "" || not isValid)
                    , type_ "button"
                    , onClick ToggleModal
                    ]
                    [ text (translate language Confirm) ]
                ]
            ]
        , section
            [ class
                ("create_account modal popup"
                    ++ (if modalOpened then
                            " viewing"

                        else
                            ""
                       )
                )
            ]
            [ div [ class "wrapper" ]
                [ h2 []
                    [ text (translate language CreateAccount) ]
                , p []
                    [ text (translate language (CreateAccountDesc isTransfer)) ]
                , dl []
                    [ dt []
                        [ text "CPU" ]
                    , dd []
                        [ text newAccountCpu ]
                    , dt []
                        [ text "NET" ]
                    , dd []
                        [ text newAccountNet ]
                    , dt []
                        [ text "RAM" ]
                    , dd []
                        [ text (toString newAccountRam ++ " bytes") ]
                    ]
                , let
                    ( delegateButtonClass, transferButtonClass ) =
                        if isTransfer then
                            ( "rent choice button", "send choice button ing" )

                        else
                            ( "rent choice button ing", "send choice button" )
                  in
                  div [ class "btn_area choice" ]
                    [ button
                        [ class delegateButtonClass
                        , type_ "button"
                        , onClick (SetIsTransfer False)
                        ]
                        [ text (translate language Delegate) ]
                    , button
                        [ class transferButtonClass
                        , type_ "button"
                        , onClick (SetIsTransfer True)
                        ]
                        [ text (translate language Transfer) ]
                    ]
                , div [ class "btn_area" ]
                    [ button
                        [ class "ok button"
                        , type_ "button"
                        , onClick PushAction
                        ]
                        [ text (translate language Confirm) ]
                    ]
                , button
                    [ class "close"
                    , id "closePopup"
                    , type_ "button"
                    , onClick ToggleModal
                    ]
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
    validateForm
        { model
            | activeKeyValidation = activeKeyValidation
            , ownerKeyValidation = ownerKeyValidation
        }


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
