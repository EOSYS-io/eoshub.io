module Component.Main.Page.Transfer exposing (..)

import Data.Action as Action exposing (TransferParameters, encodeAction)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Navigation
import Port
import Regex exposing (regex, contains)
import String.UTF8 as UTF8
import Translation exposing (Language, translate, I18n(..))


-- MODEL


type alias Model =
    { transfer : TransferParameters
    , accountValidation : AccountStatus
    , quantityValidation : QuantityStatus
    , memoValidation : MemoStatus
    , isFormValid : Bool
    }


type AccountStatus
    = EmptyAccount
    | ValidAccount
    | InvalidAccount


type QuantityStatus
    = EmptyQuantity
    | OverTransferableQuantity
    | InvalidQuantity
    | ValidQuantity


type MemoStatus
    = MemoTooLong
    | EmptyMemo
    | ValidMemo


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
        , p [] [ text "원하시는 수량만큼 토큰을 전송하세요 :)" ]
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
                                , placeholder "전송하실 수량을 입력하세요."
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


accountWarningSpan : AccountStatus -> Language -> Html Message
accountWarningSpan accountStatus language =
    let
        ( classAddedValue, textValue ) =
            case accountStatus of
                EmptyAccount ->
                    ( "", "계정이름 예시: eoshubby" )

                InvalidAccount ->
                    ( " false", translate language CheckAccountName )

                ValidAccount ->
                    ( " true", "계정이름 예시: eoshubby" )
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

                OverTransferableQuantity ->
                    ( " false", translate language OverTransferableAmount )

                ValidQuantity ->
                    ( " true", "전송가능한 수량만큼 전송가능합니다." )

                EmptyQuantity ->
                    ( "", "전송가능한 수량만큼 전송가능합니다." )
    in
        span [ class ("validate description" ++ classAddedValue) ]
            [ text textValue ]


memoWarningSpan : MemoStatus -> Language -> Html Message
memoWarningSpan memoStatus language =
    let
        ( classAddedValue, textValue ) =
            case memoStatus of
                MemoTooLong ->
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
            if to == "" then
                EmptyAccount
            else if contains (regex "^[a-z\\.1-5]{1,12}$") to then
                ValidAccount
            else
                InvalidAccount

        -- Change the limit to user's balance.
        quantityValidation =
            if quantity == "" then
                EmptyQuantity
            else
                let
                    maybeQuantity =
                        String.toFloat quantity
                in
                    case maybeQuantity of
                        Ok quantity ->
                            if quantity <= 0 then
                                InvalidQuantity
                            else if quantity > eosLiquidAmount then
                                OverTransferableQuantity
                            else
                                ValidQuantity

                        _ ->
                            InvalidQuantity

        memoValidation =
            if UTF8.length memo > 256 then
                MemoTooLong
            else
                ValidMemo

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
