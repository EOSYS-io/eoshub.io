module Page.Transfer exposing (..)

import Action exposing (TransferParameters, encodeAction)
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
    | InvalidQuantity
    | ValidQuantity


type MemoStatus
    = MemoTooLong
    | ValidMemo


initModel : Model
initModel =
    { transfer = { from = "", to = "", quantity = "", memo = "" }
    , accountValidation = EmptyAccount
    , quantityValidation = EmptyQuantity
    , memoValidation = ValidMemo
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
    | ChangeUrl String
    | SetFormValidation Bool



-- VIEW
-- Note(heejae): Current url change logic is so messy.
-- Refactor url change logic using Navigation.urlUpdate.
-- See details of this approach from https://github.com/sircharleswatson/elm-navigation-example


view : Language -> Model -> Html Message
view language { transfer, accountValidation, quantityValidation, memoValidation, isFormValid } =
    section [ class "action view panel transfer" ]
        [ nav []
            [ a
                [ style [ ( "cursor", "pointer" ) ]
                , onClick (ChangeUrl "/transfer")
                , class "viewing"
                ]
                [ text (translate language Translation.Transfer) ]
            , a
                [ style [ ( "cursor", "pointer" ) ] ]
                [ text (translate language RamMarket) ]
            , a
                [ style [ ( "cursor", "pointer" ) ] ]
                [ text (translate language Application) ]
            , a
                [ style [ ( "cursor", "pointer" ) ]
                , onClick (ChangeUrl "/voting")
                ]
                [ text (translate language Vote) ]
            , a
                [ style [ ( "cursor", "pointer" ) ] ]
                [ text (translate language ProxyVote) ]
            , a
                [ style [ ( "cursor", "pointer" ) ] ]
                [ text (translate language Faq) ]
            ]
        , h3 [] [ text (translate language Transfer) ]
        , p []
            [ text (translate language TransferInfo1)
            , br [] []
            , text (translate language TransferInfo2)
            ]
        , p [ class "help info" ]
            [ a [ style [ ( "cursor", "pointer" ) ] ] [ text (translate language TransferHelp) ]
            ]
        , let
            { to, quantity, memo } =
                transfer

            accountWarning =
                if accountValidation == InvalidAccount then
                    span [] [ text (translate language CheckAccountName) ]
                else
                    span [] []

            quantityWarning =
                if quantityValidation == InvalidQuantity then
                    span [ class "warning" ]
                        [ text (translate language OverTransferableAmount) ]
                else
                    span [] []

            memoWarning =
                if memoValidation == MemoTooLong then
                    span [] [ text (translate language Translation.MemoTooLong) ]
                else
                    span [] [ text (translate language MemoNotMandatory) ]
          in
            div
                [ class "card" ]
                [ h4 []
                    [ text (translate language TransferableAmount)
                    , br [] []
                    , strong [] [ text "120 EOS" ]
                    ]
                , Html.form
                    []
                    [ ul []
                        [ li [ class "account" ]
                            [ input
                                [ id "rcvAccount"
                                , type_ "text"
                                , style [ ( "color", "white" ) ]
                                , placeholder (translate language ReceiverAccountName)
                                , onInput <| SetTransferMessageField To
                                , value to
                                ]
                                []
                            , accountWarning
                            ]
                        , li [ class "eos" ]
                            [ input
                                [ id "eos"
                                , type_ "number"
                                , style [ ( "color", "white" ) ]
                                , placeholder "0.0000"
                                , onInput <| SetTransferMessageField Quantity
                                , value quantity
                                ]
                                []
                            , quantityWarning
                            ]
                        , li [ class "memo" ]
                            [ input
                                [ id "memo"
                                , type_ "text"
                                , style [ ( "color", "white" ) ]
                                , placeholder (translate language Translation.Memo)
                                , onInput <| SetTransferMessageField Memo
                                , value memo
                                ]
                                []
                            , memoWarning
                            ]
                        ]
                    , div
                        [ class "btn_area" ]
                        [ button
                            [ type_ "button"
                            , id "send"
                            , class "middle blue_white"
                            , onClick SubmitAction
                            , disabled (not isFormValid)
                            ]
                            [ text (translate language Transfer) ]
                        ]
                    ]
                ]
        ]



-- UPDATE


update : Message -> Model -> String -> ( Model, Cmd Message )
update message ({ transfer } as model) account =
    case message of
        SubmitAction ->
            let
                cmd =
                    { transfer | from = account } |> Action.Transfer |> encodeAction |> Port.pushAction
            in
                ( model, cmd )

        SetTransferMessageField field value ->
            ( setTransferMessageField field value model, Cmd.none )

        ChangeUrl url ->
            ( model, Navigation.newUrl url )

        SetFormValidation validity ->
            ( { model | isFormValid = validity }, Cmd.none )



-- Utility functions.


setTransferMessageField : TransferMessageFormField -> String -> Model -> Model
setTransferMessageField field value ({ transfer } as model) =
    case field of
        To ->
            validate { model | transfer = { transfer | to = value } }

        Quantity ->
            validate { model | transfer = { transfer | quantity = value } }

        Memo ->
            validate { model | transfer = { transfer | memo = value } }



-- TODO(heejae): Add tests.


validate : Model -> Model
validate ({ transfer } as model) =
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
                            if quantity == 0 then
                                EmptyQuantity
                            else if quantity > 1000000000 || quantity < 0 then
                                InvalidQuantity
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
