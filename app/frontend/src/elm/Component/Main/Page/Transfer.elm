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

import Data.Account exposing (Account)
import Data.Action as Action exposing (TransferParameters, encodeAction)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Port
import Translation exposing (I18n(..), Language, translate)
import Util.HttpRequest exposing (getAccount)
import Util.Validation as Validation
    exposing
        ( AccountStatus(..)
        , MemoStatus(..)
        , QuantityStatus(..)
        , VerificaitonRequestStatus(..)
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
    | OpenUnderConstruction
    | OnFetchAccountToVerify (Result Http.Error Account)



-- VIEW
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



-- TODO(boseok): be separated to another view model


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

                InexistentAccount ->
                    ( " false", "존재하지 않는 계정입니다." )

                AccountToBeVerified ->
                    ( " false", "존재 여부를 확인하는 중입니다." )
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
            setTransferMessageField field value model eosLiquidAmount

        OnFetchAccountToVerify (Ok _) ->
            validate model eosLiquidAmount Succeed

        OnFetchAccountToVerify (Err _) ->
            validate model eosLiquidAmount Fail

        _ ->
            ( model, Cmd.none )



-- Utility functions.


setTransferMessageField : TransferMessageFormField -> String -> Model -> Float -> ( Model, Cmd Message )
setTransferMessageField field value ({ transfer } as model) eosLiquidAmount =
    case field of
        To ->
            validate { model | transfer = { transfer | to = value } } eosLiquidAmount NotSent

        Quantity ->
            validate { model | transfer = { transfer | quantity = value } } eosLiquidAmount NotSent

        Memo ->
            validate { model | transfer = { transfer | memo = value } } eosLiquidAmount NotSent


validate : Model -> Float -> VerificaitonRequestStatus -> ( Model, Cmd Message )
validate ({ transfer } as model) eosLiquidAmount requestStatus =
    let
        { to, quantity, memo } =
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
    ( { model
        | accountValidation = accountValidation
        , quantityValidation = quantityValidation
        , memoValidation = memoValidation
        , isFormValid = isFormValid
      }
    , accountCmd
    )
