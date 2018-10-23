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
import Data.Table exposing (AccountsFields, Row)
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
import Util.Formatter exposing (getDefaultAsset, getSymbolFromAsset, numberWithinDigitLimit)
import Util.HttpRequest exposing (getAccount, getTableRows)
import Util.Token exposing (Token, tokens)
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
    , token : Token
    , tokenBalance : String
    , tokenSearchInput : String
    }


initModel : Model
initModel =
    { transfer = { from = "", to = "", quantity = "", memo = "" }
    , accountValidation = EmptyAccount
    , quantityValidation = EmptyQuantity
    , memoValidation = EmptyMemo
    , isFormValid = False
    , modalOpened = False
    , token =
        { name = "EOS"
        , symbol = "EOS"
        , contractAccount = "eosio.token"
        , precision = 4
        }
    , tokenBalance = ""
    , tokenSearchInput = ""
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
    | SwitchToken Token
    | ToggleModal
    | SearchToken String
    | OnFetchTableRows (Result Http.Error (List Row))



-- VIEW


view : Language -> Model -> String -> Html Message
view language ({ transfer, accountValidation, quantityValidation, memoValidation, isFormValid, modalOpened, token, tokenBalance } as model) eosLiquidAmount =
    main_ [ class "transfer" ]
        [ h2 [] [ text (translate language Transfer) ]
        , p [] [ text (translate language TransferDesc ++ " :)") ]
        , let
            { to, quantity, memo } =
                transfer

            accountWarning =
                accountWarningSpan accountValidation language

            quantityWarning =
                quantityWarningSpan quantityValidation language

            memoWarning =
                memoWarningSpan memoValidation language

            tokenAmount =
                case token.symbol of
                    "EOS" ->
                        eosLiquidAmount

                    _ ->
                        tokenBalance
          in
          div [ class "container" ]
            [ div [ class "wallet status" ]
                [ p []
                    [ text (translate language TransferableAmount)
                    , em [] [ text tokenAmount ]
                    ]
                , a [ onClick ToggleModal ]
                    [ text (translate language SwitchTokens) ]
                ]
            , Html.form []
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
        , tokenListSection language model
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


generateTokenButton : Token -> Html Message
generateTokenButton ({ name, symbol } as token) =
    button
        [ type_ "button"
        , class ("token bi " ++ symbol)
        , onClick (SwitchToken token)
        ]
        [ span []
            [ strong []
                [ text symbol ]
            , text name
            ]
        ]


tokenListSection : Language -> Model -> Html Message
tokenListSection language { modalOpened, tokenSearchInput } =
    let
        addedClass =
            if modalOpened then
                " viewing"

            else
                ""

        filterWithSearchInput =
            List.filter (\tkn -> String.startsWith (tokenSearchInput |> String.toUpper) tkn.symbol)
    in
    section [ class ("tokenlist modal popup" ++ addedClass) ]
        [ div [ class "wrapper" ]
            [ h2 []
                [ text "토큰 리스트" ]
            , form []
                [ input
                    [ class "search_token"
                    , placeholder "토큰 검색하기"
                    , type_ "text"
                    , onInput <| SearchToken
                    ]
                    []
                , button [ type_ "button" ]
                    [ text (translate language Search) ]
                ]
            , div [ class "result list" ]
                (List.map generateTokenButton (filterWithSearchInput tokens))
            , button [ class "close", type_ "button", onClick ToggleModal ]
                [ text (translate language Close) ]
            ]
        ]



-- UPDATE


update : Message -> Model -> String -> Float -> ( Model, Cmd Message )
update message ({ transfer, modalOpened, token } as model) accountName eosLiquidAmount =
    let
        defaultLiquidValue =
            token |> getDefaultAsset
    in
    case message of
        SubmitAction ->
            let
                cmd =
                    { transfer | from = accountName } |> Action.Transfer token.contractAccount |> encodeAction |> Port.pushAction
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

        SwitchToken ({ symbol, contractAccount } as newToken) ->
            let
                newCmd =
                    if symbol == "EOS" then
                        Cmd.none

                    else
                        getTableRows contractAccount accountName "accounts" -1
                            |> Http.send OnFetchTableRows
            in
            ( { model | token = newToken, modalOpened = not modalOpened }, newCmd )

        SearchToken input ->
            ( { model | tokenSearchInput = input }, Cmd.none )

        OnFetchTableRows (Ok rows) ->
            case rows of
                -- Account not found on the table.
                [] ->
                    ( { model | tokenBalance = defaultLiquidValue }, Cmd.none )

                (Data.Table.Accounts { balance }) :: tail ->
                    let
                        symbol =
                            balance |> getSymbolFromAsset |> Maybe.withDefault ""
                    in
                    if symbol == token.symbol then
                        ( { model | tokenBalance = balance }, Cmd.none )

                    else
                        update (OnFetchTableRows (Ok tail)) model accountName eosLiquidAmount

                _ ->
                    ( model, Cmd.none )

        OnFetchTableRows (Err _) ->
            ( { model | tokenBalance = defaultLiquidValue }, Cmd.none )

        _ ->
            ( model, Cmd.none )



-- Utility functions.


setTransferMessageField : TransferMessageFormField -> String -> Model -> Float -> ( Model, Cmd Message )
setTransferMessageField field value ({ transfer, token } as model) eosLiquidAmount =
    case field of
        To ->
            validateToField { model | transfer = { transfer | to = value } } NotSent

        Quantity ->
            if numberWithinDigitLimit token.precision value then
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
