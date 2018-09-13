module Component.Main.Page.Rammarket exposing (Message, Model, initCmd, initModel, subscriptions, update, view)

import Data.Action exposing (Action, actionsDecoder)
import Data.Table exposing (GlobalFields, RammarketFields, Row, initGlobalFields, initRammarketFields, rowsDecoder)
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
        , id
        , placeholder
        , scope
        , style
        , title
        , type_
        )
import Html.Events exposing (onClick)
import Http
import Json.Encode as Encode
import Port
import Time
import Translation exposing (I18n(..), Language, translate)
import Util.Formatter exposing (timeFormatter)
import Util.HttpRequest exposing (getFullPath, post)



-- MODEL


type alias Model =
    { actions : List Action
    , rammarketTable : RammarketFields
    , globalTable : GlobalFields
    , expandActions : Bool
    }


initModel : Model
initModel =
    { actions = []
    , rammarketTable = initRammarketFields
    , globalTable = initGlobalFields
    , expandActions = False
    }



-- MESSAGE


type Message
    = OnFetchActions (Result Http.Error (List Action))
    | OnFetchRammarketRows (Result Http.Error (List Row))
    | OnFetchGlobalRows (Result Http.Error (List Row))
    | ExpandActions
    | UpdateChainData Time.Time


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
    let
        requestBody =
            [ ( "scope", "eosio" |> Encode.string )
            , ( "code", "eosio" |> Encode.string )
            , ( "table", "rammarket" |> Encode.string )
            , ( "json", True |> Encode.bool )
            ]
                |> Encode.object
                |> Http.jsonBody
    in
    post ("/v1/chain/get_table_rows" |> getFullPath) requestBody rowsDecoder
        |> Http.send OnFetchRammarketRows


getGlobalTable : Cmd Message
getGlobalTable =
    let
        requestBody =
            [ ( "scope", "eosio" |> Encode.string )
            , ( "code", "eosio" |> Encode.string )
            , ( "table", "global" |> Encode.string )
            , ( "json", True |> Encode.bool )
            ]
                |> Encode.object
                |> Http.jsonBody
    in
    post ("/v1/chain/get_table_rows" |> getFullPath) requestBody rowsDecoder
        |> Http.send OnFetchGlobalRows


initCmd : Cmd Message
initCmd =
    Cmd.batch [ Port.loadChart (), getActions, getRammarketTable, getGlobalTable ]



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        OnFetchActions (Ok actions) ->
            ( { model | actions = actions }, Cmd.none )

        OnFetchActions (Err error) ->
            ( model, Cmd.none )

        OnFetchRammarketRows (Ok rows) ->
            case rows of
                (Data.Table.Rammarket fields) :: [] ->
                    ( { model | rammarketTable = fields }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        OnFetchRammarketRows (Err error) ->
            ( model, Cmd.none )

        OnFetchGlobalRows (Ok rows) ->
            case rows of
                (Data.Table.Global fields) :: [] ->
                    ( { model | globalTable = fields }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        OnFetchGlobalRows (Err error) ->
            ( model, Cmd.none )

        ExpandActions ->
            ( { model | expandActions = True }, Cmd.none )

        UpdateChainData _ ->
            ( model, Cmd.batch [ getActions, getRammarketTable, getGlobalTable ] )



-- VIEW


view : Language -> Model -> Html Message
view language { actions, expandActions } =
    main_ [ class "ram_market" ]
        [ h2 [] [ text (translate language RamMarket) ]
        , p [] [ text (translate language RamMarketDesc) ]
        , div [ class "container" ]
            [ section [ class "dashboard" ]
                [ div [ class "ram status" ]
                    [ div [ class "wrapper" ]
                        [ h3 [] [ text "이오스 램 가격" ]
                        , p [] [ text "0.15793210 EOS/kb" ]
                        ]
                    , div [ class "wrapper" ]
                        [ h3 [] [ text "램 점유율" ]
                        , p [] [ text "46.44/66.36GB (69.97%)" ]
                        ]
                    , div [ class "graph", id "tv-chart-container" ] []
                    ]
                , div [ class "my status" ]
                    [ div [ class "summary" ]
                        [ h3 [] [ text "나의 램" ]
                        , p [] [ text "사용가능한 용량이 53% 남았어요" ]
                        , div [ class "status" ]
                            [ span [ class "hell", style [ ( "height", "10%" ) ] ] []
                            , text "10%"
                            ]
                        ]
                    , div [ class "sell_buy" ]
                        [ div [ class "tab" ]
                            [ button [ type_ "button", class "buy ing tab button" ] [ text "구매하기" ]
                            , button [ type_ "button", class "sell ing tab button" ] [ text "판매하기" ]
                            ]
                        , div [ class "unit" ]
                            [ div [ class "select period" ]
                                [ i [ attribute "data-value" "0" ] [ text "EOS" ]
                                , button [ type_ "button", class "prev button" ] [ text "이전 단위 고르기" ]
                                , button [ type_ "button", class "next button" ] [ text "다음 단위 고르기" ]
                                ]
                            , a [] [ text "타계정 구매" ]
                            ]
                        , form [ class "input panel" ]
                            [ div []
                                [ input [ type_ "number", placeholder "구매하실 수량을 입력하세요" ] []
                                , span [ class "unit" ] [ text "EOS" ]
                                ]
                            , div []
                                [ button [ type_ "button" ] [ text "10%" ]
                                , button [ type_ "button" ] [ text "50%" ]
                                , button [ type_ "button" ] [ text "70%" ]
                                , button [ type_ "button" ] [ text "최대" ]
                                ]
                            ]
                        , div [ class "btn_area" ]
                            [ button [ type_ "button", class "ok button", disabled True ] [ text "구매하기" ]
                            ]
                        ]
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
        ]


actionToTableRow : Language -> Action -> Html Message
actionToTableRow language { blockTime, data, trxId } =
    case data of
        Ok (Data.Action.Transfer { from, to, quantity }) ->
            let
                ( actionClass, actionType, account ) =
                    if from == "eosio.ram" then
                        ( "log buy", "판매", to )

                    else
                        ( "log sell", "구매", from )

                formattedDateTime =
                    blockTime |> timeFormatter language
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



-- SUBSCRIPTIONS
-- The interval needs to be adjusted. Now, it follows eosio block interval.


subscriptions : Sub Message
subscriptions =
    Time.every (2 * Time.second) UpdateChainData
