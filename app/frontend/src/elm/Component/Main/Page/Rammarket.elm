module Component.Main.Page.Rammarket exposing (Message, Model, initCmd, initModel, update, view)

import Data.Action exposing (Action, actionsDecoder)
import Date.Extra as Date
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
import Http
import Json.Encode as Encode
import Port
import Translation exposing (I18n(..), Language, translate)
import Util.HttpRequest exposing (getFullPath, post)



-- MODEL


type alias Model =
    { actions : List Action
    }


initModel : Model
initModel =
    { actions = []
    }



-- MESSAGE


type Message
    = OnFetchActions (Result Http.Error (List Action))


initCmd : Cmd Message
initCmd =
    let
        requestBody =
            [ ( "account_name", "eosio.ram" |> Encode.string )
            , ( "pos", -1 |> Encode.int )
            , ( "offset", -100 |> Encode.int )
            ]
                |> Encode.object
                |> Http.jsonBody

        getActionsCmd =
            post ("/v1/history/get_actions" |> getFullPath) requestBody actionsDecoder
                |> Http.send OnFetchActions
    in
    Cmd.batch [ Port.loadChart (), getActionsCmd ]



-- UPDATE


update : Message -> Model -> Model
update message model =
    case message of
        OnFetchActions (Ok actions) ->
            { model | actions = actions }

        OnFetchActions (Err error) ->
            Debug.log "" model



-- VIEW


view : Language -> Model -> Html Message
view language { actions } =
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
            , section [ class "history list" ]
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
                    , tbody [] (List.map actionToTableRow actions)
                    ]
                , div [ class "btn_area" ]
                    [ button [ class "view_more button", type_ "button" ]
                        [ text "더 보기" ]
                    ]
                ]
            ]
        ]


actionToTableRow : Action -> Html Message
actionToTableRow { blockTime, data, trxId } =
    case data of
        Ok (Data.Action.Transfer { from, to, quantity }) ->
            let
                ( class_, type_, account ) =
                    if from == "eosio.ram" then
                        ( "log buy", "판매", to )

                    else
                        ( "log sell", "구매", from )

                formattedDateTime =
                    case blockTime |> Date.fromIsoString of
                        -- TODO(heejae): use locale-specified pattern.
                        Ok str ->
                            str |> Date.toFormattedString "EEEE, MMMM d, y 'at' h:mm a"

                        _ ->
                            blockTime
            in
            tr [ class class_ ]
                [ td [] [ text type_ ]
                , td [] [ text quantity ]
                , td [] [ text account ]
                , td [] [ text formattedDateTime ]
                , td [] [ text trxId ]
                ]

        _ ->
            tr [] []
