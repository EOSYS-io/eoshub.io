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

import Data.Account exposing (Account, defaultAccount)
import Data.Action as Action exposing (TransferParameters, encodeActions)
import Data.Table exposing (Row)
import Dict exposing (Dict)
import Html
    exposing
        ( Html
        , a
        , button
        , div
        , em
        , form
        , h2
        , i
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
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Port
import Translation exposing (I18n(..), Language, translate)
import Util.Formatter
    exposing
        ( assetToFloat
        , floatToAsset
        , getSymbolFromAsset
        , numberWithinDigitLimit
        )
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
    , tokensLoaded : Bool
    , possessingTokens : Dict String ( Token, String )
    , currentSymbol : String
    , tokenSearchInput : String
    }


eosToken : Token
eosToken =
    { name = "EOS"
    , symbol = "EOS"
    , contractAccount = "eosio.token"
    , precision = 4
    }


initModel : Model
initModel =
    { transfer = { from = "", to = "", quantity = "", memo = "" }
    , accountValidation = EmptyAccount
    , quantityValidation = EmptyQuantity
    , memoValidation = EmptyMemo
    , isFormValid = False
    , modalOpened = False
    , tokensLoaded = False
    , possessingTokens = Dict.fromList [ ( "EOS", ( eosToken, "" ) ) ]
    , currentSymbol = "EOS"
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
    | SwitchToken String
    | ToggleModal
    | SearchToken String
    | OnFetchTableRows (Result Http.Error (List Row))
    | UpdateToken



-- VIEW


view : Language -> Model -> String -> Html Message
view language ({ transfer, accountValidation, quantityValidation, memoValidation, isFormValid, currentSymbol, possessingTokens } as model) eosLiquidAmount =
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
                case currentSymbol of
                    "EOS" ->
                        eosLiquidAmount

                    _ ->
                        case possessingTokens |> Dict.get currentSymbol of
                            Just ( _, balance ) ->
                                balance

                            Nothing ->
                                -- This case should not happen!
                                ""
          in
          div [ class "container" ]
            [ div [ class "wallet status" ]
                [ p []
                    [ text (translate language TransferableAmount)
                    , em [] [ text tokenAmount ]
                    ]
                , a [ onClick ToggleModal ]
                    [ text (translate language OtherTokens) ]
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
        , tokenListSection language model eosLiquidAmount
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


generateTokenButton : String -> ( Token, String ) -> Html Message
generateTokenButton eosLiquidAmount ( { name, symbol }, balance ) =
    button
        [ type_ "button"
        , class ("token bi " ++ symbol)
        , onClick (SwitchToken symbol)
        ]
        [ span []
            [ strong []
                [ text symbol ]
            , text name
            ]
        , i []
            [ text
                (if symbol == "EOS" then
                    eosLiquidAmount

                 else
                    balance
                )
            ]
        ]


tokenListSection : Language -> Model -> String -> Html Message
tokenListSection language { modalOpened, tokenSearchInput, possessingTokens } eosLiquidAmount =
    let
        addedClass =
            if modalOpened then
                " viewing"

            else
                ""

        filterWithSearchInput =
            List.filter (\( { symbol }, _ ) -> String.startsWith (tokenSearchInput |> String.toUpper) symbol)
    in
    section [ class ("tokenlist modal popup" ++ addedClass) ]
        [ div [ class "wrapper" ]
            [ h2 []
                [ text (translate language TokenList) ]
            , form [ onSubmit (SearchToken tokenSearchInput) ]
                [ input
                    [ class "search_token"
                    , placeholder (translate language TokenName)
                    , type_ "text"
                    , onInput <| SearchToken
                    ]
                    []
                , button [ type_ "button" ]
                    [ text (translate language Search) ]
                ]
            , div [ class "result list" ]
                (List.map (generateTokenButton eosLiquidAmount)
                    (possessingTokens |> Dict.toList |> List.map Tuple.second |> filterWithSearchInput)
                )
            , button [ class "close", type_ "button", onClick ToggleModal ]
                [ text (translate language Close) ]
            ]
        ]



-- UPDATE


update : Message -> Model -> String -> Float -> ( Model, Cmd Message )
update message ({ transfer, modalOpened, tokensLoaded, possessingTokens, currentSymbol } as model) accountName eosLiquidAmount =
    let
        token =
            case possessingTokens |> Dict.get currentSymbol of
                Just ( foundToken, _ ) ->
                    foundToken

                Nothing ->
                    eosToken
    in
    case message of
        SubmitAction ->
            let
                cmd =
                    { transfer
                        | from = accountName
                        , quantity =
                            transfer.quantity
                                |> assetToFloat
                                |> floatToAsset token.precision token.symbol
                    }
                        |> Action.Transfer token.contractAccount
                        |> List.singleton
                        |> encodeActions "transfer"
                        |> Port.pushAction
            in
            ( model, cmd )

        SetTransferMessageField field value ->
            setTransferMessageField field value model eosLiquidAmount

        OnFetchAccountToVerify (Ok _) ->
            validateToField model Succeed

        OnFetchAccountToVerify (Err _) ->
            validateToField model Fail

        ToggleModal ->
            let
                ( loaded, newCmd ) =
                    if accountName == "" || accountName == defaultAccount.accountName then
                        ( False, Cmd.none )

                    else if tokensLoaded then
                        ( True, Cmd.none )

                    else
                        ( True
                        , Cmd.batch
                            (List.map
                                (\{ contractAccount } ->
                                    getTableRows contractAccount accountName "accounts" -1
                                        |> Http.send OnFetchTableRows
                                )
                                (List.map Tuple.second (tokens |> Dict.remove "EOS" |> Dict.toList))
                            )
                        )
            in
            ( { model | modalOpened = not modalOpened, tokensLoaded = loaded }, newCmd )

        SwitchToken newSymbol ->
            -- Clear form.
            ( { model
                | currentSymbol = newSymbol
                , modalOpened = not modalOpened
                , transfer = { from = "", to = "", quantity = "", memo = "" }
                , accountValidation = EmptyAccount
                , quantityValidation = EmptyQuantity
                , memoValidation = EmptyMemo
              }
            , Cmd.none
            )

        SearchToken searchInput ->
            ( { model | tokenSearchInput = searchInput }, Cmd.none )

        OnFetchTableRows (Ok rows) ->
            case rows of
                (Data.Table.Accounts { balance }) :: tail ->
                    let
                        symbol =
                            balance |> getSymbolFromAsset |> Maybe.withDefault ""

                        newModel =
                            case Dict.get symbol tokens of
                                Just matchedToken ->
                                    { model
                                        | possessingTokens = Dict.insert symbol ( matchedToken, balance ) model.possessingTokens
                                    }

                                Nothing ->
                                    model
                    in
                    update (OnFetchTableRows (Ok tail)) newModel accountName eosLiquidAmount

                _ ->
                    ( model, Cmd.none )

        OnFetchTableRows (Err _) ->
            ( model, Cmd.none )

        UpdateToken ->
            let
                newCmd =
                    case possessingTokens |> Dict.get currentSymbol of
                        Just ( { contractAccount }, _ ) ->
                            getTableRows contractAccount accountName "accounts" -1
                                |> Http.send OnFetchTableRows

                        Nothing ->
                            Cmd.none
            in
            ( model, newCmd )

        _ ->
            ( model, Cmd.none )



-- Utility functions.


setTransferMessageField : TransferMessageFormField -> String -> Model -> Float -> ( Model, Cmd Message )
setTransferMessageField field value ({ transfer, possessingTokens, currentSymbol } as model) eosLiquidAmount =
    let
        ( token, tokenBalance ) =
            case possessingTokens |> Dict.get currentSymbol of
                Just ( foundToken, balance ) ->
                    ( foundToken, balance )

                Nothing ->
                    ( eosToken, "" )
    in
    case field of
        To ->
            validateToField { model | transfer = { transfer | to = value } } NotSent

        Quantity ->
            if numberWithinDigitLimit token.precision value then
                let
                    liquidAmount =
                        if token.symbol == "EOS" then
                            eosLiquidAmount

                        else
                            tokenBalance
                                |> assetToFloat
                in
                ( validateQuantityField { model | transfer = { transfer | quantity = value } } liquidAmount
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
