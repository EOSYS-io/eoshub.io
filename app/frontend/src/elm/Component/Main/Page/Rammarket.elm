module Component.Main.Page.Rammarket exposing
    ( Message
    , Model
    , calculateEosRamPrice
    , calculateEosRamYield
    , initCmd
    , initModel
    , subscriptions
    , update
    , view
    )

import Data.Account exposing (Account)
import Data.Action
    exposing
        ( Action
        , BuyramParameters
        , actionsDecoder
        , encodeAction
        , initBuyramParameters
        , removeDuplicated
        )
import Data.Table exposing (GlobalFields, RammarketFields, Row, initGlobalFields, initRammarketFields)
import Html
    exposing
        ( Html
        , a
        , button
        , div
        , em
        , form
        , h2
        , h3
        , input
        , main_
        , p
        , section
        , span
        , strong
        , table
        , tbody
        , td
        , text
        , th
        , thead
        , tr
        )
import Html.Attributes
    exposing
        ( attribute
        , class
        , disabled
        , hidden
        , id
        , placeholder
        , scope
        , type_
        , value
        )
import Html.Events exposing (onClick, onInput)
import Http
import Json.Encode as Encode
import Navigation
import Port
import Round
import Time
import Translation exposing (I18n(..), Language, translate)
import Util.Constant exposing (giga, kilo)
import Util.Formatter exposing (assetToFloat, deleteFromBack, numberWithinDigitLimit, timeFormatter)
import Util.HttpRequest exposing (getAccount, getFullPath, getTableRows, post)
import Util.Urls exposing (getAccountUrl)
import Util.Validation as Validation
    exposing
        ( AccountStatus(..)
        , QuantityStatus(..)
        , VerificationRequestStatus(..)
        , validateAccount
        , validateQuantity
        )
import View.Common exposing (addSearchLink)



-- MODEL


type Distribution
    = Manual
    | Percentage10
    | Percentage50
    | Percentage70
    | Percentage100


type alias BuyModel =
    { params : BuyramParameters
    , proxyBuy : Bool
    , distribution : Distribution
    , accountValidation : AccountStatus
    , quantityValidation : QuantityStatus
    , isValid : Bool
    }


initBuyModel : BuyModel
initBuyModel =
    { params = initBuyramParameters
    , proxyBuy = False
    , distribution = Manual
    , accountValidation = EmptyAccount
    , quantityValidation = EmptyQuantity
    , isValid = False
    }



-- Redefine sellram parameters to make default unit as kilo bytes.


type alias SellramParameters =
    { kiloBytes : String
    }


initSellramParameters : SellramParameters
initSellramParameters =
    { kiloBytes = ""
    }


type alias SellModel =
    { params : SellramParameters
    , distribution : Distribution
    , quantityValidation : QuantityStatus
    , isValid : Bool
    }


initSellModel : SellModel
initSellModel =
    { params = initSellramParameters
    , distribution = Manual
    , quantityValidation = EmptyQuantity
    , isValid = False
    }


type alias Model =
    { actions : List Action
    , rammarketTable : RammarketFields
    , globalTable : GlobalFields
    , buyModel : BuyModel
    , sellModel : SellModel
    , modalOpen : Bool
    , isBuyTab : Bool
    }


initModel : Model
initModel =
    { actions = []
    , rammarketTable = initRammarketFields
    , globalTable = initGlobalFields
    , modalOpen = False
    , buyModel = initBuyModel
    , sellModel = initSellModel
    , isBuyTab = True
    }



-- MESSAGE


type BuyFormField
    = BuyQuantity
    | ProxyAccount


type Message
    = OnFetchActions (Result Http.Error (List Action))
    | OnFetchTableRows (Result Http.Error (List Row))
    | OnFetchAccountToVerify (Result Http.Error Account)
    | UpdateChainData Time.Time
    | SwitchTab
    | ToggleModal
    | SetBuyFormField BuyFormField String
    | SetSellFormField String
    | SetProxyBuy
    | CancelProxy
    | TypeEosAmount String
    | TypeBytesAmount String
    | ClickDistribution Distribution
    | SubmitAction String
    | ChangeUrl String


getActions : Cmd Message
getActions =
    let
        requestBody =
            [ ( "account_name", "eosio.ram" |> Encode.string )
            , ( "pos", -1 |> Encode.int )
            , ( "offset", -80 |> Encode.int )
            ]
                |> Encode.object
                |> Http.jsonBody
    in
    post ("/v1/history/get_actions" |> getFullPath) requestBody actionsDecoder
        |> Http.send OnFetchActions


getRammarketTable : Cmd Message
getRammarketTable =
    getTableRows "eosio" "eosio" "rammarket" 1
        |> Http.send OnFetchTableRows


getGlobalTable : Cmd Message
getGlobalTable =
    getTableRows "eosio" "eosio" "global" 1
        |> Http.send OnFetchTableRows


initCmd : Cmd Message
initCmd =
    Cmd.batch [ Port.loadChart (), getActions, getRammarketTable, getGlobalTable ]



-- UPDATE


update : Message -> Model -> Account -> ( Model, Cmd Message )
update message ({ modalOpen, buyModel, sellModel, isBuyTab } as model) ({ ramQuota, ramUsage, coreLiquidBalance } as account) =
    let
        availableRam =
            ramQuota - ramUsage

        availableEos =
            coreLiquidBalance |> assetToFloat
    in
    case message of
        OnFetchActions (Ok actions) ->
            ( { model | actions = actions |> removeDuplicated |> List.reverse }, Cmd.none )

        OnFetchActions (Err _) ->
            ( model, Cmd.none )

        OnFetchTableRows (Ok rows) ->
            case rows of
                (Data.Table.Rammarket fields) :: [] ->
                    ( { model | rammarketTable = fields }, Cmd.none )

                (Data.Table.Global fields) :: [] ->
                    ( { model | globalTable = fields }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        OnFetchTableRows (Err _) ->
            ( model, Cmd.none )

        OnFetchAccountToVerify (Ok _) ->
            let
                ( newBuyModel, _ ) =
                    validateReceiverField
                        buyModel
                        Validation.Succeed
            in
            ( { model | buyModel = newBuyModel }, Cmd.none )

        OnFetchAccountToVerify (Err _) ->
            let
                ( newBuyModel, _ ) =
                    validateReceiverField
                        buyModel
                        Validation.Fail
            in
            ( { model | buyModel = newBuyModel }, Cmd.none )

        UpdateChainData _ ->
            ( model, Cmd.batch [ getActions, getRammarketTable, getGlobalTable ] )

        SwitchTab ->
            ( { model | isBuyTab = not isBuyTab }, Cmd.none )

        ToggleModal ->
            ( { model | modalOpen = not modalOpen }, Cmd.none )

        SetBuyFormField field val ->
            let
                ( newBuyModel, newCmd ) =
                    setBuyFormField field buyModel availableEos val Validation.NotSent
            in
            ( { model | buyModel = newBuyModel }
            , newCmd
            )

        SetSellFormField val ->
            ( { model | sellModel = setSellFormField sellModel availableRam val }
            , Cmd.none
            )

        TypeEosAmount val ->
            update (SetBuyFormField BuyQuantity val)
                { model
                    | buyModel = { buyModel | distribution = Manual }
                }
                account

        TypeBytesAmount val ->
            update (SetSellFormField val)
                { model
                    | sellModel = { sellModel | distribution = Manual }
                }
                account

        ClickDistribution distribution ->
            let
                ( msg, newModel ) =
                    if isBuyTab then
                        let
                            newQuantity =
                                case distribution of
                                    Percentage10 ->
                                        availableEos * 0.1

                                    Percentage50 ->
                                        availableEos * 0.5

                                    Percentage70 ->
                                        availableEos * 0.7

                                    _ ->
                                        availableEos
                        in
                        ( SetBuyFormField BuyQuantity (newQuantity |> Round.round 4)
                        , { model
                            | buyModel = { buyModel | distribution = distribution }
                          }
                        )

                    else
                        let
                            floatAvailableRam =
                                availableRam |> toFloat

                            newQuantity =
                                case distribution of
                                    Percentage10 ->
                                        floatAvailableRam * 0.1

                                    Percentage50 ->
                                        floatAvailableRam * 0.5

                                    Percentage70 ->
                                        floatAvailableRam * 0.7

                                    _ ->
                                        floatAvailableRam

                            denominator =
                                kilo |> toFloat
                        in
                        ( SetSellFormField ((newQuantity / denominator) |> Round.floor 3)
                        , { model
                            | sellModel = { sellModel | distribution = distribution }
                          }
                        )
            in
            update msg newModel account

        SetProxyBuy ->
            let
                newModel =
                    { model | buyModel = { buyModel | proxyBuy = True } }
            in
            update ToggleModal newModel account

        CancelProxy ->
            let
                { params } =
                    buyModel
            in
            ( { model
                | buyModel =
                    { buyModel
                        | proxyBuy = False
                        , params = { params | receiver = "" }
                        , accountValidation = EmptyAccount
                    }
              }
            , Cmd.none
            )

        SubmitAction accountName ->
            if isBuyTab then
                let
                    { params, proxyBuy } =
                        buyModel

                    newParams =
                        if proxyBuy then
                            { params | payer = accountName }

                        else
                            { params | payer = accountName, receiver = accountName }
                in
                ( model, newParams |> Data.Action.Buyram |> encodeAction |> Port.pushAction )

            else
                let
                    bytes =
                        ((sellModel.params.kiloBytes |> String.toFloat |> Result.withDefault 0) * (kilo |> toFloat)) |> floor

                    newParams =
                        Data.Action.SellramParameters accountName bytes
                in
                ( model, newParams |> Data.Action.Sellram |> encodeAction |> Port.pushAction )

        ChangeUrl url ->
            ( model, Navigation.newUrl url )



-- VIEW


view : Language -> Model -> Account -> Html Message
view language ({ actions, rammarketTable, globalTable, modalOpen, buyModel } as model) ({ ramQuota } as account) =
    main_ [ class "ram_market" ]
        [ h2 [] [ text (translate language RamMarket) ]
        , p [] [ text (translate language RamMarketDesc ++ " :)") ]
        , div [ class "container" ]
            [ section [ class "dashboard" ]
                [ div [ class "ram status" ]
                    [ div [ class "wrapper" ]
                        [ h3 [] [ text (translate language RamPrice) ]
                        , p [] [ text (rammarketTable |> calculateEosRamPrice |> formatEosPrice) ]
                        ]
                    , div [ class "wrapper" ]
                        [ h3 [] [ text (translate language RamYield) ]
                        , p [] [ text (globalTable |> calculateEosRamYield) ]
                        ]
                    , div [ class "graph", id "tv-chart-container" ] []
                    ]
                , div [ class "my status" ]
                    [ div [ class "summary" ]
                        [ h3 []
                            [ text (translate language MyRam)
                            , span []
                                [ text ((((ramQuota |> toFloat) / (kilo |> toFloat)) |> Round.floor 3) ++ " KB") ]
                            ]
                        ]
                    , buySellTab language model account
                    ]
                ]
            , section [ class "history list" ]
                [ table []
                    [ thead []
                        [ tr []
                            [ th [ scope "col" ]
                                [ text (translate language Type) ]
                            , th [ scope "col" ]
                                [ text (translate language Volume) ]
                            , th [ scope "col" ]
                                [ text (translate language AccountField) ]
                            , th [ scope "col" ]
                                [ text (translate language Time) ]
                            , th [ scope "col" ]
                                [ text "Tx ID" ]
                            ]
                        ]
                    , tbody [] (actions |> List.map (actionToTableRow language))
                    ]
                ]
            ]
        , let
            ( spanClass, message ) =
                let
                    ( validationClass, msg ) =
                        case buyModel.accountValidation of
                            ValidAccount ->
                                ( "false", translate language AccountIsValid )

                            InvalidAccount ->
                                ( "true", translate language AccountIsInvalid )

                            InexistentAccount ->
                                ( "true", translate language AccountNotExist )

                            _ ->
                                ( "", "" )
                in
                ( "validate description " ++ validationClass, msg )

            modalViewClass =
                if modalOpen then
                    " viewing"

                else
                    ""
          in
          section
            [ attribute "aria-live" "true"
            , class ("buy_ram modal popup" ++ modalViewClass)
            ]
            [ div [ class "wrapper" ]
                [ h2 []
                    [ text (translate language BuyForOtherAccount) ]
                , p []
                    [ text (translate language EnterReceiverAccountName) ]
                , form []
                    [ input
                        [ class "user"
                        , placeholder "ex) eosio"
                        , type_ "text"
                        , onInput <| SetBuyFormField ProxyAccount
                        , attribute "maxlength" "12"
                        ]
                        []
                    ]
                , div [ class "container" ]
                    [ span [ class spanClass ] [ text message ] ]
                , div [ class "btn_area" ]
                    [ button
                        [ class "ok button"
                        , disabled (not (buyModel.accountValidation == ValidAccount))
                        , type_ "button"
                        , onClick SetProxyBuy
                        ]
                        [ text "확인" ]
                    ]
                , button [ class "close button", type_ "button", onClick ToggleModal ]
                    [ text "닫기" ]
                ]
            ]
        ]


buySellTab : Language -> Model -> Account -> Html Message
buySellTab language ({ isBuyTab, buyModel, sellModel, rammarketTable } as model) { ramQuota, ramUsage, accountName, coreLiquidBalance } =
    let
        availableRam =
            ramQuota - ramUsage

        availableEos =
            coreLiquidBalance |> assetToFloat

        ( byteText, byteQuant ) =
            ( "KB", sellModel.params.kiloBytes )

        ( buyClass, sellClass, buyOthersRamTab, buttonText, inputText, inputMsg, inputQuant, inputPlaceholder, buttonDisabled ) =
            if isBuyTab then
                ( " ing"
                , ""
                , a
                    [ onClick ToggleModal, hidden buyModel.proxyBuy ]
                    [ text (translate language BuyForOtherAccount) ]
                , translate language DoBuy
                , "EOS"
                , TypeEosAmount
                , buyModel.params.quant
                , translate language TypeBuyAmount
                , not buyModel.isValid
                )

            else
                -- Produce empty html node with text tag.
                ( ""
                , " ing"
                , text ""
                , translate language DoSell
                , byteText
                , TypeBytesAmount
                , byteQuant
                , translate language TypeSellAmount
                , not sellModel.isValid
                )

        ramPrice =
            rammarketTable |> calculateEosRamPrice

        ( availableText, availableAmount, descText, approximateValue ) =
            if isBuyTab then
                ( translate language BuyableAmount
                , (availableEos |> toString) ++ " EOS"
                , translate language BuyFeeCharged
                , translate language
                    (ApproximateQuantity
                        (((1 / ramPrice)
                            * (buyModel.params.quant |> String.toFloat |> Result.withDefault 0)
                         )
                            |> Round.floor 3
                        )
                        "KB"
                    )
                )

            else
                ( translate language SellableAmount
                , (((availableRam |> toFloat) / (kilo |> toFloat)) |> Round.floor 3) ++ " KB"
                , translate language SellFeeCharged
                , translate language
                    (ApproximateQuantity
                        ((ramPrice
                            * (sellModel.params.kiloBytes |> String.toFloat |> Result.withDefault 0)
                         )
                            |> Round.round 4
                        )
                        "EOS"
                    )
                )

        selectDiv =
            div [ class "available" ]
                [ span [] [ text availableText ]
                , strong [] [ text availableAmount ]
                ]
    in
    div [ class "sell_buy" ]
        [ div [ class "tab" ]
            [ button
                [ type_ "button"
                , class ("buy tab button" ++ buyClass)
                , onClick SwitchTab
                ]
                [ text (translate language Buy)
                ]
            , button
                [ type_ "button"
                , class ("sell tab button" ++ sellClass)
                , onClick SwitchTab
                ]
                [ text (translate language Sell)
                ]
            ]
        , div [ class "unit" ]
            [ selectDiv
            , buyOthersRamTab
            ]
        , div [ class "target", hidden (not (buyModel.proxyBuy && isBuyTab)) ]
            [ text (translate language (To buyModel.params.receiver))
            , button
                [ type_ "button"
                , onClick CancelProxy
                , class "close button"
                ]
                []
            ]
        , form [ class "input panel" ]
            [ div []
                [ input
                    [ type_ "number"
                    , placeholder inputPlaceholder
                    , onInput <| inputMsg
                    , value inputQuant
                    ]
                    []
                , span [ class "unit" ] [ text inputText ]
                ]
            , div [ class "amount" ] [ text approximateValue ]
            , div []
                [ distributionButton language model Percentage10
                , distributionButton language model Percentage50
                , distributionButton language model Percentage70
                , distributionButton language model Percentage100
                ]
            ]
        , div [ class "btn_area" ]
            [ button
                [ type_ "button"
                , class "ok button"
                , disabled buttonDisabled
                , onClick (SubmitAction accountName)
                ]
                [ text buttonText ]
            , p [ class "description" ] [ text descText ]
            ]
        ]


distributionButton : Language -> Model -> Distribution -> Html Message
distributionButton language model dist =
    let
        { buyModel, sellModel, isBuyTab } =
            model

        modelDist =
            if isBuyTab then
                buyModel.distribution

            else
                sellModel.distribution

        classContent =
            if modelDist == dist then
                "clicked"

            else
                ""

        textContent =
            case dist of
                Percentage10 ->
                    "10%"

                Percentage50 ->
                    "50%"

                Percentage70 ->
                    "70%"

                Percentage100 ->
                    translate language Max

                _ ->
                    ""
    in
    button
        [ type_ "button"
        , onClick (ClickDistribution dist)
        , class classContent
        ]
        [ text textContent ]



-- SUBSCRIPTIONS
-- The interval needs to be adjusted. Now, it is set to 2 secs.


subscriptions : Sub Message
subscriptions =
    Time.every (2 * Time.second) UpdateChainData



-- Utility Functions


actionToTableRow : Language -> Action -> Html Message
actionToTableRow language { blockTime, data, trxId } =
    case data of
        Ok (Data.Action.Transfer _ { from, to, quantity }) ->
            let
                ( actionClass, actionType, account ) =
                    if from == "eosio.ram" then
                        ( "log sell", translate language Sell, to )

                    else
                        ( "log buy", translate language Buy, from )

                formattedDateTime =
                    blockTime |> timeFormatter
            in
            tr [ class actionClass ]
                [ td [] [ text actionType ]
                , td [] [ text quantity ]
                , td []
                    [ addSearchLink
                        (account |> getAccountUrl |> ChangeUrl)
                        (em [] [ text account ])
                    ]
                , td [] [ text formattedDateTime ]
                , td [] [ text trxId ]
                ]

        _ ->
            tr [] []


formatEosPrice : Float -> String
formatEosPrice price =
    (price |> Round.round 8) ++ " EOS/KB"


calculateEosRamPrice : RammarketFields -> Float
calculateEosRamPrice { base, quote } =
    let
        denominator =
            case base.balance |> deleteFromBack 4 |> String.toFloat of
                Ok baseFloat ->
                    baseFloat

                _ ->
                    -1.0

        numerator =
            case quote.balance |> deleteFromBack 4 |> String.toFloat of
                Ok quoteFloat ->
                    quoteFloat

                _ ->
                    -1.0
    in
    -- This case means no data loaded yet.
    if denominator < 0 || numerator < 0 then
        0.0

    else
        (numerator / denominator) * toFloat kilo


calculateEosRamYield : GlobalFields -> String
calculateEosRamYield { maxRamSize, totalRamBytesReserved } =
    let
        denominator =
            case maxRamSize |> String.toFloat of
                Ok baseFloat ->
                    baseFloat

                _ ->
                    -1.0

        numerator =
            case totalRamBytesReserved |> String.toFloat of
                Ok quoteFloat ->
                    quoteFloat

                _ ->
                    -1.0
    in
    -- This case means no data loaded yet.
    if denominator < 0 || numerator < 0 then
        "Loading..."

    else
        Round.round 2 (numerator / (giga |> toFloat))
            ++ "/"
            ++ Round.round 2 (denominator / (giga |> toFloat))
            ++ "GB ("
            ++ Round.round 2 ((numerator * 100) / denominator)
            ++ "%)"



-- TODO(heejae): Add tests for validation functions.


setBuyFormField : BuyFormField -> BuyModel -> Float -> String -> VerificationRequestStatus -> ( BuyModel, Cmd Message )
setBuyFormField field ({ params } as buyModel) availableQuantity val requestStatus =
    case field of
        BuyQuantity ->
            if numberWithinDigitLimit 4 val then
                ( validateQuantityField
                    { buyModel | params = { params | quant = val } }
                    availableQuantity
                , Cmd.none
                )

            else
                ( buyModel, Cmd.none )

        ProxyAccount ->
            validateReceiverField
                { buyModel | params = { params | receiver = val } }
                requestStatus


setSellFormField : SellModel -> Int -> String -> SellModel
setSellFormField ({ params } as sellModel) availableRam val =
    if numberWithinDigitLimit 3 val then
        validateSell
            { sellModel | params = { params | kiloBytes = val } }
            availableRam

    else
        sellModel


validateBuyForm : BuyModel -> BuyModel
validateBuyForm ({ proxyBuy, accountValidation, quantityValidation } as buyModel) =
    let
        isValid =
            (if proxyBuy then
                accountValidation == ValidAccount

             else
                True
            )
                && (quantityValidation == ValidQuantity)
    in
    { buyModel
        | accountValidation = accountValidation
        , quantityValidation = quantityValidation
        , isValid = isValid
    }


validateReceiverField : BuyModel -> VerificationRequestStatus -> ( BuyModel, Cmd Message )
validateReceiverField ({ params } as buyModel) requestStatus =
    let
        { receiver } =
            params

        accountValidation =
            validateAccount receiver requestStatus

        accountCmd =
            if accountValidation == AccountToBeVerified then
                receiver
                    |> getAccount
                    |> Http.send OnFetchAccountToVerify

            else
                Cmd.none
    in
    ( validateBuyForm { buyModel | accountValidation = accountValidation }, accountCmd )


validateQuantityField : BuyModel -> Float -> BuyModel
validateQuantityField ({ params } as buyModel) availableQuantity =
    validateBuyForm
        { buyModel | quantityValidation = validateQuantity params.quant availableQuantity }



-- TODO(heejae): Replace hardcoded validation after refactoring validQuantity function
-- by dividing it into validFloatQuantity and validIntQuantity.


validateSell : SellModel -> Int -> SellModel
validateSell ({ params } as sellModel) availableRam =
    let
        { kiloBytes } =
            params

        bytes =
            ((kiloBytes |> String.toFloat |> Result.withDefault 0) * (kilo |> toFloat)) |> floor

        quantityValidation =
            if bytes <= 0 then
                InvalidQuantity

            else if bytes > availableRam then
                OverValidQuantity

            else
                ValidQuantity

        isValid =
            quantityValidation == ValidQuantity
    in
    { sellModel
        | quantityValidation = quantityValidation
        , isValid = isValid
    }
