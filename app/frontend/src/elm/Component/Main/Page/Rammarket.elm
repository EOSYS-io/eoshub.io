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

import Array
import Data.Account exposing (Account, getResource)
import Data.Action
    exposing
        ( Action
        , BuyramParameters
        , SellramParameters
        , actionsDecoder
        , encodeAction
        , initBuyramParameters
        , initSellramParameters
        )
import Data.Table exposing (GlobalFields, RammarketFields, Row, initGlobalFields, initRammarketFields)
import Html
    exposing
        ( Html
        , a
        , button
        , caption
        , div
        , form
        , h2
        , h3
        , i
        , input
        , main_
        , p
        , section
        , span
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
        , style
        , title
        , type_
        , value
        )
import Html.Events exposing (onClick, onInput)
import Http
import Json.Encode as Encode
import Port
import Round
import Time
import Translation exposing (I18n(..), Language, translate)
import Util.Constant exposing (giga, kilo, mega)
import Util.Formatter exposing (assetToFloat, deleteFromBack, resourceUnitConverter, timeFormatter)
import Util.HttpRequest exposing (getAccount, getFullPath, getTableRows, post)
import Util.Validation as Validation
    exposing
        ( AccountStatus(..)
        , QuantityStatus(..)
        , VerificationRequestStatus(..)
        , validateAccount
        , validateQuantity
        )



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


type ByteUnit
    = KB
    | MB
    | Byte


type alias SellModel =
    { params : SellramParameters
    , distribution : Distribution
    , byteUnits : Array.Array ByteUnit
    , byteUnitIndex : Int
    , quantityValidation : QuantityStatus
    , isValid : Bool
    , byteUnitIndex : Int
    }


initSellModel : SellModel
initSellModel =
    { params = initSellramParameters
    , distribution = Manual
    , byteUnits = Array.fromList [ Byte, KB, MB ]
    , byteUnitIndex = 0
    , quantityValidation = EmptyQuantity
    , isValid = False
    }


type alias Model =
    { actions : List Action
    , rammarketTable : RammarketFields
    , globalTable : GlobalFields
    , expandActions : Bool
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
    , expandActions = False
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
    | ExpandActions
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
    | ChangeByteUnit Bool


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
    getTableRows "eosio" "eosio" "rammarket"
        |> Http.send OnFetchTableRows


getGlobalTable : Cmd Message
getGlobalTable =
    getTableRows "eosio" "eosio" "global"
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
            ( { model | actions = actions |> List.reverse }, Cmd.none )

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
                    validateBuy
                        buyModel
                        availableEos
                        Validation.Succeed
            in
            ( { model | buyModel = newBuyModel }, Cmd.none )

        OnFetchAccountToVerify (Err _) ->
            let
                ( newBuyModel, _ ) =
                    validateBuy
                        buyModel
                        availableEos
                        Validation.Fail
            in
            ( { model | buyModel = newBuyModel }, Cmd.none )

        ExpandActions ->
            ( { model | expandActions = True }, Cmd.none )

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
                                case Array.get sellModel.byteUnitIndex sellModel.byteUnits |> Maybe.withDefault KB of
                                    Byte ->
                                        1.0

                                    KB ->
                                        kilo |> toFloat

                                    MB ->
                                        mega |> toFloat
                        in
                        ( SetSellFormField ((newQuantity / denominator) |> Round.round 8)
                        , { model
                            | sellModel = { sellModel | distribution = distribution }
                          }
                        )
            in
            update msg newModel account

        ChangeByteUnit isForward ->
            let
                length =
                    Array.length sellModel.byteUnits

                newIndex =
                    if isForward then
                        (sellModel.byteUnitIndex + 1) % length

                    else
                        (sellModel.byteUnitIndex - 1 + length) % length
            in
            ( { model | sellModel = { sellModel | byteUnitIndex = newIndex } }, Cmd.none )

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
                    { params } =
                        sellModel

                    newParams =
                        { params | account = accountName }
                in
                ( model, newParams |> Data.Action.Sellram |> encodeAction |> Port.pushAction )



-- VIEW


view : Language -> Model -> Account -> Html Message
view language ({ actions, expandActions, rammarketTable, globalTable, modalOpen, buyModel } as model) { ramQuota, ramUsage, accountName } =
    main_ [ class "ram_market" ]
        [ h2 [] [ text (translate language RamMarket) ]
        , p [] [ text (translate language RamMarketDesc) ]
        , div [ class "container" ]
            [ let
                ( _, _, _, ramPercent, ramColor ) =
                    getResource "ram" ramUsage (ramQuota - ramUsage) ramQuota
              in
              section [ class "dashboard" ]
                [ div [ class "ram status" ]
                    [ div [ class "wrapper" ]
                        [ h3 [] [ text "이오스 램 가격" ]
                        , p [] [ text (rammarketTable |> calculateEosRamPrice) ]
                        ]
                    , div [ class "wrapper" ]
                        [ h3 [] [ text "램 점유율" ]
                        , p [] [ text (globalTable |> calculateEosRamYield) ]
                        ]
                    , div [ class "graph", id "tv-chart-container" ] []
                    ]
                , div [ class "my status" ]
                    [ div [ class "summary" ]
                        [ h3 []
                            [ text "나의 램"
                            , span []
                                [ text (resourceUnitConverter "ram" ramQuota) ]
                            ]
                        , p []
                            [ text
                                ("사용가능한 용량이 "
                                    ++ ramPercent
                                    ++ " 남았어요"
                                )
                            ]
                        , div [ class "status" ]
                            [ span [ class ramColor, style [ ( "height", ramPercent ) ] ]
                                []
                            , text ramPercent
                            ]
                        ]
                    , buySellTab model accountName
                    ]
                ]
            , let
                ( actionTableRows, viewMoreButton ) =
                    if expandActions then
                        ( actions |> List.map (actionToTableRow language)
                        , div [] []
                        )

                    else
                        ( actions |> List.take 2 |> List.map (actionToTableRow language)
                        , div [ class "btn_area" ]
                            [ button [ type_ "button", class "view_more button", onClick ExpandActions ]
                                [ text "더 보기" ]
                            ]
                        )
              in
              section [ class "history list" ]
                [ table []
                    [ caption []
                        [ text "구매/판매 거래내역" ]
                    , thead []
                        [ tr []
                            [ th [ scope "col" ]
                                [ text "타입" ]
                            , th [ scope "col" ]
                                [ text "거래량" ]
                            , th [ scope "col" ]
                                [ text "계정" ]
                            , th [ scope "col" ]
                                [ text "시간" ]
                            , th [ scope "col" ]
                                [ text "Tx ID" ]
                            ]
                        ]
                    , tbody [] actionTableRows
                    ]
                , viewMoreButton
                ]
            ]
        , let
            ( spanClass, message ) =
                let
                    ( validationClass, msg ) =
                        case buyModel.accountValidation of
                            ValidAccount ->
                                ( "false", "올바른 계정입니다." )

                            InvalidAccount ->
                                ( "true", "올바르지 않은 계정입니다." )

                            InexistentAccount ->
                                ( "true", "존재하지 않는 계정입니다." )

                            AccountToBeVerified ->
                                ( "true", "존재 여부를 확인하는 중입니다." )

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
                    [ text "타계정 구매" ]
                , p []
                    [ text "램을 구매해 줄 타계정을 입력하세요." ]
                , form []
                    [ input
                        [ class "user"
                        , placeholder "ex) eosio"
                        , type_ "text"
                        , onInput <| SetBuyFormField ProxyAccount
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


buySellTab : Model -> String -> Html Message
buySellTab ({ isBuyTab, buyModel, sellModel } as model) accountName =
    let
        ( byteText, byteQuant ) =
            case Array.get sellModel.byteUnitIndex sellModel.byteUnits |> Maybe.withDefault KB of
                Byte ->
                    ( "Bytes", sellModel.params.bytes |> toString )

                KB ->
                    ( "KB", (toFloat sellModel.params.bytes / toFloat kilo) |> Round.floor 4 )

                MB ->
                    ( "MB", (toFloat sellModel.params.bytes / toFloat mega) |> Round.floor 8 )

        ( buyClass, sellClass, buyOthersRamTab, buttonText, inputText, inputMsg, inputQuant, inputPlaceholder, buttonDisabled ) =
            if isBuyTab then
                ( " ing"
                , ""
                , a
                    (if not buyModel.proxyBuy then
                        [ onClick ToggleModal ]

                     else
                        []
                    )
                    [ text "타계정 구매" ]
                , "구매하기"
                , "EOS"
                , TypeEosAmount
                , buyModel.params.quant
                , "구매하실 수량을 입력하세요"
                , not buyModel.isValid
                )

            else
                -- Produce empty html node with text tag.
                ( ""
                , " ing"
                , text ""
                , "판매하기"
                , byteText
                , TypeBytesAmount
                , byteQuant
                , "판매하실 수량을 입력하세요"
                , not sellModel.isValid
                )

        selectChilds =
            if isBuyTab then
                [ i [ attribute "data-value" "0" ] [ text inputText ] ]

            else
                [ i [ attribute "data-value" "0" ] [ text inputText ]
                , button [ type_ "button", class "prev button", onClick (ChangeByteUnit False) ] [ text "이전 단위 고르기" ]
                , button [ type_ "button", class "next button", onClick (ChangeByteUnit True) ] [ text "다음 단위 고르기" ]
                ]

        selectDiv =
            div [ class "select period" ]
                selectChilds
    in
    div [ class "sell_buy" ]
        [ div [ class "tab" ]
            [ button
                [ type_ "button"
                , class ("buy tab button" ++ buyClass)
                , onClick SwitchTab
                ]
                [ text "구매하기"
                ]
            , button
                [ type_ "button"
                , class ("sell tab button" ++ sellClass)
                , onClick SwitchTab
                ]
                [ text "판매하기"
                ]
            ]
        , div [ class "unit" ]
            [ selectDiv
            , buyOthersRamTab
            ]
        , div [ class "target", hidden (not (buyModel.proxyBuy && isBuyTab)) ]
            [ text (buyModel.params.receiver ++ " 에게")
            , button
                [ type_ "button"
                , title "타 계정의 구매를 하지 않습니다."
                , onClick CancelProxy
                , class "close button"
                ]
                [ text "타 계정의 구매를 하지 않습니다." ]
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
            , div []
                [ distributionButton model Percentage10
                , distributionButton model Percentage50
                , distributionButton model Percentage70
                , distributionButton model Percentage100
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
            ]
        ]


distributionButton : Model -> Distribution -> Html Message
distributionButton model dist =
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
                    "최대"

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
        Ok (Data.Action.Transfer { from, to, quantity }) ->
            let
                ( actionClass, actionType, account ) =
                    if from == "eosio.ram" then
                        ( "log sell", "판매", to )

                    else
                        ( "log buy", "구매", from )

                formattedDateTime =
                    blockTime |> timeFormatter
            in
            tr [ class actionClass ]
                [ td [] [ text actionType ]
                , td [] [ text quantity ]
                , td [] [ text account ]
                , td [] [ text formattedDateTime ]
                , td [] [ text trxId ]
                ]

        _ ->
            tr [] []


calculateEosRamPrice : RammarketFields -> String
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
        "Loading..."

    else
        ((numerator / denominator) * toFloat kilo |> Round.round 8) ++ " EOS/KB"


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


setBuyFormField : BuyFormField -> BuyModel -> Float -> String -> VerificationRequestStatus -> ( BuyModel, Cmd Message )
setBuyFormField field ({ params } as buyModel) availableQuantity val requestStatus =
    case field of
        BuyQuantity ->
            validateBuy
                { buyModel | params = { params | quant = val } }
                availableQuantity
                requestStatus

        ProxyAccount ->
            validateBuy
                { buyModel | params = { params | receiver = val } }
                availableQuantity
                requestStatus


setSellFormField : SellModel -> Int -> String -> SellModel
setSellFormField ({ params, byteUnitIndex, byteUnits } as sellModel) availableRam val =
    let
        multiplier =
            (case Array.get byteUnitIndex byteUnits |> Maybe.withDefault KB of
                KB ->
                    kilo

                MB ->
                    mega

                Byte ->
                    1
            )
                |> toFloat

        intValue =
            val |> String.toFloat |> Result.withDefault 0 |> (*) multiplier |> floor
    in
    validateSell
        { sellModel | params = { params | bytes = intValue } }
        availableRam


validateBuy : BuyModel -> Float -> VerificationRequestStatus -> ( BuyModel, Cmd Message )
validateBuy ({ params, proxyBuy } as buyModel) availableQuantity requestStatus =
    let
        { receiver, quant } =
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

        quantityValidation =
            validateQuantity quant availableQuantity

        isValid =
            (if proxyBuy then
                accountValidation == ValidAccount

             else
                True
            )
                && (quantityValidation == ValidQuantity)
    in
    ( { buyModel
        | accountValidation = accountValidation
        , quantityValidation = quantityValidation
        , isValid = isValid
      }
    , accountCmd
    )



-- TODO(heejae): Replace hardcoded validation after refactoring validQuantity function
-- by dividing it into validFloatQuantity and validIntQuantity.


validateSell : SellModel -> Int -> SellModel
validateSell ({ params } as sellModel) availableRam =
    let
        { bytes } =
            params

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
