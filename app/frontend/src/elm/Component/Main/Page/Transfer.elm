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
    , validate
    , view
    )

import Data.Action as Action exposing (TransferParameters, encodeAction)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Port
import Translation exposing (I18n(..), Language, translate)
import Util.Validation as Validation
    exposing
        ( AccountStatus(..)
        , MemoStatus(..)
        , QuantityStatus(..)
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
    }


initModel : Model
initModel =
    { transfer = { from = "", to = "", quantity = "", memo = "" }
    , accountValidation = EmptyAccount
    , quantityValidation = EmptyQuantity
    , memoValidation = EmptyMemo
    , isFormValid = False
    }



-- MESSAGE


type TransferMessageFormField
    = To
    | Quantity
    | Memo


type Message
    = SetTransferMessageField TransferMessageFormField String
    | SubmitAction
    | SetFormValidation Bool
    | OpenUnderConstruction



-- VIEW
-- Note(heejae): Current url change logic is so messy.
-- Refactor url change logic using Navigation.urlUpdate.
-- See details of this approach from https://github.com/sircharleswatson/elm-navigation-example
-- TODO(heejae): Consider making nav as a separate component.


view : Language -> Model -> String -> Html Message
view language { transfer, accountValidation, quantityValidation, memoValidation, isFormValid } eosLiquidAmount =
    main_ [ class "transfer" ]
        [ h2 [] [ text (translate language Transfer) ]
        , p [] [ text (translate language TransferDesc) ]
        , div [ class "container" ]
            [ div [ class "wallet status" ]
                [ p []
                    [ text (translate language TransferableAmount)
                    , em [] [ text eosLiquidAmount ]
                    ]
                , a [ title "전송가능한 토큰을 변경하시려면 클릭해주세요." ]
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
                            , value to
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
                            , value quantity
                            ]
                            []
                        , quantityWarning
                        ]
                    , li [ class "memo" ]
                        [ input
                            [ type_ "text"
                            , placeholder (translate language Translation.Memo)
                            , onInput <| SetTransferMessageField Memo
                            , value memo
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
                    , class "undo button"
                    , disabled True
                    ]
                    [ text "취소" ]
                , button
                    [ type_ "button"
                    , class "ok button"
                    , onClick SubmitAction
                    , disabled (not isFormValid)
                    ]
                    [ text (translate language Transfer) ]
                ]
            ]
        ]


accountWarningSpan : AccountStatus -> Language -> Html msg
accountWarningSpan accountStatus language =
    let
        ( classAddedValue, textValue ) =
            case accountStatus of
                EmptyAccount ->
                    ( "", translate language AccountExample )

                InvalidAccount ->
                    ( " false", translate language CheckAccountName )

                ValidAccount ->
                    ( " true", translate language AccountExample )
    in
    span [ class ("validate description" ++ classAddedValue) ]
        [ text textValue ]


quantityWarningSpan : QuantityStatus -> Language -> Html Message
quantityWarningSpan quantityStatus language =
    let
        ( classAddedValue, textValue ) =
            case quantityStatus of
                InvalidQuantity ->
                    ( " false", translate language InvalidAmount )

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



-- UPDATE


update : Message -> Model -> String -> Float -> ( Model, Cmd Message )
update message ({ transfer } as model) accountName eosLiquidAmount =
    case message of
        SubmitAction ->
            let
                cmd =
                    { transfer | from = accountName } |> Action.Transfer |> encodeAction |> Port.pushAction
            in
            ( model, cmd )

        SetTransferMessageField field value ->
            ( setTransferMessageField field value model eosLiquidAmount, Cmd.none )

        SetFormValidation validity ->
            ( { model | isFormValid = validity }, Cmd.none )

        _ ->
            ( model, Cmd.none )



-- Utility functions.


setTransferMessageField : TransferMessageFormField -> String -> Model -> Float -> Model
setTransferMessageField field value ({ transfer } as model) eosLiquidAmount =
    case field of
        To ->
            validate { model | transfer = { transfer | to = value } } eosLiquidAmount

        Quantity ->
            validate { model | transfer = { transfer | quantity = value } } eosLiquidAmount

        Memo ->
            validate { model | transfer = { transfer | memo = value } } eosLiquidAmount


validate : Model -> Float -> Model
validate ({ transfer } as model) eosLiquidAmount =
    let
        { to, quantity, memo } =
            transfer

        accountValidation =
            validateAccount to

        -- Change the limit to user's balance.
        quantityValidation =
            validateQuantity quantity eosLiquidAmount

        memoValidation =
            validateMemo memo

        isFormValid =
            (accountValidation == ValidAccount)
                && (quantityValidation == ValidQuantity)
                && (memoValidation == ValidMemo)
    in
    { model
        | accountValidation = accountValidation
        , quantityValidation = quantityValidation
        , memoValidation = memoValidation
        , isFormValid = isFormValid
    }
