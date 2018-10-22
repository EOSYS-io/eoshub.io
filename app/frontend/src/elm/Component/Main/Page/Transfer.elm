module Component.Main.Page.Transfer exposing
    ( Message(..)
    , Model
    , TransferMessageFormField(..)
    , accountWarningSpan
    , initModel
    , memoWarningSpan
    , quantityWarningSpan
    , setTransferMessageField
    , update
    , validateForm
    , validateMemoField
    , validateQuantityField
    , validateToField
    , view
    )

import Data.Account exposing (Account)
import Data.Action as Action exposing (TransferParameters, encodeAction)
import Html
    exposing
        ( Html
        , a
        , button
        , div
        , em
        , form
        , h2
        , img
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
import Html.Attributes exposing (attribute, autofocus, class, disabled, placeholder, step, type_)
import Html.Events exposing (onClick, onInput)
import Http
import Port
import Translation exposing (I18n(..), Language, translate)
import Util.Formatter exposing (numberWithinDigitLimit)
import Util.HttpRequest exposing (getAccount)
import Util.Validation as Validation
    exposing
        ( AccountStatus(..)
        , MemoStatus(..)
        , QuantityStatus(..)
        , VerificationRequestStatus(..)
        , validateAccount
        , validateMemo
        , validateQuantity
        )



-- MODEL


type alias Model =
    { transfer : TransferParameters
    , accountValidation : AccountStatus
    , quantityValidation : QuantityStatus
    , memoValidation : MemoStatus
    , isFormValid : Bool
    , modalOpened : Bool
    }


initModel : Model
initModel =
    { transfer = { from = "", to = "", quantity = "", memo = "" }
    , accountValidation = EmptyAccount
    , quantityValidation = EmptyQuantity
    , memoValidation = EmptyMemo
    , isFormValid = False
    , modalOpened = False
    }



-- MESSAGE


type TransferMessageFormField
    = To
    | Quantity
    | Memo


type Message
    = SetTransferMessageField TransferMessageFormField String
    | SubmitAction
    | OpenUnderConstruction
    | OnFetchAccountToVerify (Result Http.Error Account)
    | ToggleModal



-- VIEW


view : Language -> Model -> String -> Html Message
view language { transfer, accountValidation, quantityValidation, memoValidation, isFormValid, modalOpened } eosLiquidAmount =
    main_ [ class "transfer" ]
        [ h2 [] [ text (translate language Transfer) ]
        , p [] [ text (translate language TransferDesc ++ " :)") ]
        , div [ class "container" ]
            [ div [ class "wallet status" ]
                [ p []
                    [ text (translate language TransferableAmount)
                    , em [] [ text eosLiquidAmount ]
                    ]
                , a [ onClick ToggleModal ]
                    [ text "토큰 바꾸기" ]
                ]
            , let
                { to, quantity, memo } =
                    transfer

                accountWarning =
                    accountWarningSpan accountValidation language

                quantityWarning =
                    quantityWarningSpan quantityValidation language

                memoWarning =
                    memoWarningSpan memoValidation language
              in
              Html.form []
                [ ul []
                    [ li []
                        [ input
                            [ type_ "text"
                            , placeholder (translate language ReceiverAccountName)
                            , autofocus True
                            , onInput <| SetTransferMessageField To
                            , Html.Attributes.value to
                            , attribute "maxlength" "12"
                            ]
                            []
                        , accountWarning
                        ]
                    , li [ class "eos" ]
                        [ input
                            [ type_ "number"
                            , placeholder (translate language TransferAmount)
                            , step ".0001"
                            , onInput <| SetTransferMessageField Quantity
                            , Html.Attributes.value quantity
                            ]
                            []
                        , quantityWarning
                        ]
                    , li [ class "memo" ]
                        [ input
                            [ type_ "text"
                            , placeholder (translate language Translation.Memo)
                            , onInput <| SetTransferMessageField Memo
                            , Html.Attributes.value memo
                            ]
                            []
                        , memoWarning
                        ]
                    ]
                ]
            , div
                [ class "btn_area" ]
                [ button
                    [ type_ "button"
                    , class "ok button"
                    , onClick SubmitAction
                    , disabled (not isFormValid)
                    ]
                    [ text (translate language Send) ]
                ]
            ]
        , tokenListSection modalOpened
        ]



-- TODO(boseok): The accountWaringSpan can be separated to another view model.


accountWarningSpan : AccountStatus -> Language -> Html msg
accountWarningSpan accountStatus language =
    let
        ( classAddedValue, textValue ) =
            case accountStatus of
                EmptyAccount ->
                    ( "", translate language AccountExample )

                InvalidAccount ->
                    ( " false", translate language AccountIsInvalid )

                ValidAccount ->
                    ( " true", translate language AccountIsValid )

                InexistentAccount ->
                    ( " false", translate language AccountNotExist )

                AccountToBeVerified ->
                    ( "", "" )
    in
    span [ class ("validate description" ++ classAddedValue) ]
        [ text textValue ]


quantityWarningSpan : QuantityStatus -> Language -> Html Message
quantityWarningSpan quantityStatus language =
    let
        ( classAddedValue, textValue ) =
            case quantityStatus of
                InvalidQuantity ->
                    ( " false", translate language InvalidInputAmount )

                OverValidQuantity ->
                    ( " false", translate language OverTransferableAmount )

                ValidQuantity ->
                    ( " true", translate language Transferable )

                EmptyQuantity ->
                    ( "", translate language TransferableAmountDesc )
    in
    span [ class ("validate description" ++ classAddedValue) ]
        [ text textValue ]


memoWarningSpan : MemoStatus -> Language -> Html Message
memoWarningSpan memoStatus language =
    let
        ( classAddedValue, textValue ) =
            case memoStatus of
                Validation.MemoTooLong ->
                    ( " false", translate language Translation.MemoTooLong )

                EmptyMemo ->
                    ( "", translate language MemoNotMandatory )

                ValidMemo ->
                    ( " true", translate language MemoNotMandatory )
    in
    span [ class ("validate description" ++ classAddedValue) ]
        [ text textValue ]


tokenListSection : Bool -> Html Message
tokenListSection modalOpened =
    let
        addedClass =
            if modalOpened then
                " viewing"

            else
                ""
    in
    section [ class ("tokenlist modal popup" ++ addedClass) ]
        [ div [ class "wrapper" ]
            [ h2 []
                [ text "토큰 리스트" ]
            , form []
                [ input [ class "search_token", placeholder "토큰 검색하기", type_ "text" ]
                    []
                , button [ type_ "button" ]
                    [ text "검색" ]
                ]
            , div [ class "result list", attribute "role" "listbox" ]
                [ button [ attribute "role" "listitem", type_ "button" ]
                    [ img []
                        []
                    , span []
                        [ strong []
                            [ text "EOS" ]
                        , text "blockone"
                        ]
                    ]
                ]
            , button [ class "close", type_ "button", onClick ToggleModal ]
                [ text "닫기" ]
            ]
        ]



-- UPDATE


update : Message -> Model -> String -> Float -> ( Model, Cmd Message )
update message ({ transfer, modalOpened } as model) accountName eosLiquidAmount =
    case message of
        SubmitAction ->
            let
                cmd =
                    { transfer | from = accountName } |> Action.Transfer "eosio.token" |> encodeAction |> Port.pushAction
            in
            ( model, cmd )

        SetTransferMessageField field value ->
            setTransferMessageField field value model eosLiquidAmount

        OnFetchAccountToVerify (Ok _) ->
            validateToField model Succeed

        OnFetchAccountToVerify (Err _) ->
            validateToField model Fail

        ToggleModal ->
            ( { model | modalOpened = not modalOpened }, Cmd.none )

        _ ->
            ( model, Cmd.none )



-- Utility functions.


setTransferMessageField : TransferMessageFormField -> String -> Model -> Float -> ( Model, Cmd Message )
setTransferMessageField field value ({ transfer } as model) eosLiquidAmount =
    case field of
        To ->
            validateToField { model | transfer = { transfer | to = value } } NotSent

        Quantity ->
            if numberWithinDigitLimit 4 value then
                ( validateQuantityField { model | transfer = { transfer | quantity = value } } eosLiquidAmount
                , Cmd.none
                )

            else
                ( model, Cmd.none )

        Memo ->
            ( validateMemoField { model | transfer = { transfer | memo = value } }
            , Cmd.none
            )


validateForm : Model -> Model
validateForm ({ accountValidation, quantityValidation, memoValidation } as model) =
    let
        isFormValid =
            (accountValidation == ValidAccount)
                && (quantityValidation == ValidQuantity)
                && (memoValidation /= Validation.MemoTooLong)
    in
    { model
        | isFormValid = isFormValid
    }


validateToField : Model -> VerificationRequestStatus -> ( Model, Cmd Message )
validateToField ({ transfer } as model) requestStatus =
    let
        { to } =
            transfer

        accountValidation =
            validateAccount to requestStatus

        accountCmd =
            if accountValidation == AccountToBeVerified then
                to
                    |> getAccount
                    |> Http.send OnFetchAccountToVerify

            else
                Cmd.none
    in
    ( validateForm { model | accountValidation = accountValidation }, accountCmd )


validateQuantityField : Model -> Float -> Model
validateQuantityField ({ transfer } as model) eosLiquidAmount =
    validateForm
        { model
            | quantityValidation =
                validateQuantity transfer.quantity eosLiquidAmount
        }


validateMemoField : Model -> Model
validateMemoField ({ transfer } as model) =
    validateForm { model | memoValidation = validateMemo transfer.memo }
