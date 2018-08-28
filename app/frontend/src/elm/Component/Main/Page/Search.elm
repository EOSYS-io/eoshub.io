module Component.Main.Page.Search exposing (..)

import Html
    exposing
        ( Html
        , section
        , div
        , input
        , button
        , text
        , p
        , ul
        , li
        , text
        , strong
        , h3
        , h4
        , span
        , table
        , thead
        , tr
        , th
        , tbody
        , td
        , node
        , main_
        , h2
        , dl
        , dt
        , dd
        , br
        , select
        , option
        , em
        , caption
        )
import Html.Attributes
    exposing
        ( placeholder
        , class
        , title
        , attribute
        , type_
        , scope
        , hidden
        , name
        , value
        , id
        )
import Html.Events exposing (on, onClick, targetValue)
import Translation exposing (I18n(..), Language, translate)
import Http
import Util.HttpRequest exposing (getFullPath, post)
import Json.Decode as Decode
import Json.Encode as Encode
import Data.Action exposing (Action, actionsDecoder, refineAction, viewActionInfo)
import Data.Account
    exposing
        ( Account
        , ResourceInEos
        , Resource
        , Refund
        , accountDecoder
        , defaultAccount
        , keyAccountsDecoder
        , getTotalAmount
        , getUnstakingAmount
        , getResource
        )
import Util.Formatter
    exposing
        ( larimerToEos
        , eosFloatToString
        , timeFormatter
        )


-- MODEL


type alias Model =
    { query : String
    , account : Account
    , actions : List Action
    , pagination : Pagination
    , selectedActionCategory : SelectedActionCategory
    }


type alias Pagination =
    { latestActionSeq : Int
    , nextPos : Int
    , offset : Int
    , isEnd : Bool
    }


type alias SelectedActionCategory =
    String



-- Note(boseok): (EOSIO bug) when only pos = -1, it gets the 'offset' number of actions (intended),
-- otherwise it gets the 'offset+1' number of actions (not intended)
-- it's different from get_actions --help


initModel : String -> Model
initModel accountName =
    { query = accountName
    , account = defaultAccount
    , actions = []
    , pagination =
        { latestActionSeq = 0
        , nextPos = -1
        , offset = -30
        , isEnd = False
        }
    , selectedActionCategory = "all"
    }


initCmd : String -> Model -> Cmd Message
initCmd query { pagination } =
    let
        accountCmd =
            let
                body =
                    Encode.object
                        [ ( "account_name", Encode.string query ) ]
                        |> Http.jsonBody
            in
                post (getFullPath "/v1/chain/get_account") body accountDecoder
                    |> (Http.send OnFetchAccount)

        actionsCmd =
            getActions query pagination.nextPos pagination.offset
    in
        Cmd.batch [ accountCmd, actionsCmd ]


getActions : String -> Int -> Int -> Cmd Message
getActions query nextPos offset =
    let
        body =
            Encode.object
                [ ( "account_name", Encode.string query )
                , ( "pos", Encode.int nextPos )
                , ( "offset", Encode.int offset )
                ]
                |> Http.jsonBody
    in
        post (getFullPath "/v1/history/get_actions") body actionsDecoder
            |> (Http.send OnFetchActions)



-- UPDATE


type Message
    = OnFetchAccount (Result Http.Error Account)
    | OnFetchActions (Result Http.Error (List Action))
    | SelectActionCategory SelectedActionCategory
    | ShowMore


update : Message -> Model -> ( Model, Cmd Message )
update message ({ query, account, actions, pagination } as model) =
    case message of
        OnFetchAccount (Ok data) ->
            ( { model | account = data }, Cmd.none )

        OnFetchAccount (Err error) ->
            ( model, Cmd.none )

        OnFetchActions (Ok actions) ->
            let
                refinedAction =
                    List.map (refineAction query) actions

                smallestActionSeq =
                    case List.head actions of
                        Just action ->
                            action.accountActionSeq

                        Nothing ->
                            -1
            in
                if smallestActionSeq > 0 then
                    ( { model | actions = refinedAction ++ model.actions, pagination = { pagination | nextPos = smallestActionSeq - 1, offset = -29 } }, Cmd.none )
                else
                    -- no more action to load
                    ( { model | actions = refinedAction ++ model.actions, pagination = { pagination | isEnd = True } }, Cmd.none )

        OnFetchActions (Err error) ->
            ( model, Cmd.none )

        SelectActionCategory selectedActionCategory ->
            ( { model | selectedActionCategory = selectedActionCategory }, Cmd.none )

        ShowMore ->
            let
                actionsCmd =
                    getActions query pagination.nextPos pagination.offset
            in
                if not pagination.isEnd then
                    ( model, actionsCmd )
                else
                    -- TODO(boseok): alert it is the end of records
                    ( model, Cmd.none )



-- VIEW


view : Language -> Model -> Html Message
view language { account, actions, selectedActionCategory } =
    let
        totalAmount =
            getTotalAmount
                account.core_liquid_balance
                account.voter_info.staked
                account.refund_request.net_amount
                account.refund_request.cpu_amount

        unstakingAmount =
            getUnstakingAmount account.refund_request.net_amount account.refund_request.cpu_amount

        stakedAmount =
            eosFloatToString (larimerToEos account.voter_info.staked)

        ( cpuUsed, cpuAvailable, cpuTotal, cpuPercent, cpuColor ) =
            getResource "cpu" account.cpu_limit.used account.cpu_limit.available account.cpu_limit.max

        ( netUsed, netAvailable, netTotal, netPercent, netColor ) =
            getResource "net" account.net_limit.used account.net_limit.available account.net_limit.max

        ( ramUsed, ramAvailable, ramTotal, ramPercent, ramColor ) =
            getResource "ram" account.ram_usage (account.ram_quota - account.ram_usage) account.ram_quota
    in
        main_ [ class "search" ]
            [ h2 []
                [ text "계정 검색" ]
            , p []
                [ text "검색하신 계정에 대한 정보입니다." ]
            , div [ class "container" ]
                [ section [ class "summary" ]
                    [ h3 []
                        [ text "계정 요약" ]
                    , dl []
                        [ dt []
                            [ text "계정이름" ]
                        , dd []
                            [ text account.account_name ]
                        , dt []
                            [ text (translate language TotalAmount) ]
                        , dd []
                            [ text totalAmount ]
                        ]
                    ]
                , section [ class "account status" ]
                    [ h3 []
                        [ text "계정 정보" ]
                    , div [ class "wrapper" ]
                        [ div []
                            [ text "Unstaked"
                            , strong [ title account.core_liquid_balance ]
                                [ text account.core_liquid_balance ]
                            ]
                        , div []
                            [ text "refunding"
                            , strong [ title unstakingAmount ]
                                [ text unstakingAmount ]
                            ]
                        , div []
                            [ text "staked"
                            , strong [ title stakedAmount ]
                                [ text stakedAmount ]
                            ]
                        ]
                    ]
                , section [ class "resource" ]
                    [ h3 []
                        [ text "리소스" ]
                    , div [ class "wrapper" ]
                        [ div []
                            [ h4 []
                                [ text "CPU"
                                ]
                            , p []
                                [ text ("Total: " ++ cpuTotal)
                                , br []
                                    []
                                , text ("Used: " ++ cpuUsed)
                                , br []
                                    []
                                , text ("Available: " ++ cpuAvailable)
                                ]
                            , div [ class "status" ]
                                [ span [ class cpuColor, attribute "style" ("height:" ++ cpuPercent) ]
                                    []
                                , text cpuPercent
                                ]
                            ]
                        , div []
                            [ h4 []
                                [ text "NET"
                                ]
                            , p []
                                [ text ("Total: " ++ netTotal)
                                , br []
                                    []
                                , text ("Used: " ++ netUsed)
                                , br []
                                    []
                                , text ("Available: " ++ netAvailable)
                                ]
                            , div [ class "status" ]
                                [ span [ class netColor, attribute "style" ("height:" ++ netPercent) ]
                                    []
                                , text netPercent
                                ]
                            ]
                        , div []
                            [ h4 []
                                [ text "RAM"
                                ]
                            , p []
                                [ text ("Total: " ++ ramTotal)
                                , br []
                                    []
                                , text ("Used: " ++ ramUsed)
                                , br []
                                    []
                                , text ("Available: " ++ ramAvailable)
                                ]
                            , div [ class "status" ]
                                [ span [ class ramColor, attribute "style" ("height:" ++ ramPercent) ]
                                    []
                                , text ramPercent
                                ]
                            ]
                        ]
                    ]
                , section [ class "transaction history" ]
                    [ h3 []
                        [ text "트랜잭션" ]
                    , select [ id "", name "", on "change" (Decode.map SelectActionCategory targetValue) ]
                        [ option [ attribute "disabled" "", attribute "selected" "", value "-1" ]
                            [ text "트랜잭션 타입" ]
                        , option [ value "all" ]
                            [ text "All" ]
                        , option [ value "transfer" ]
                            [ text "전송하기" ]
                        ]
                    , table []
                        [ caption []
                            [ text "트랜잭션 타입 :: All" ]
                        , thead []
                            [ tr []
                                [ th [ scope "col" ]
                                    [ text "번호" ]
                                , th [ scope "col" ]
                                    [ text "타입" ]
                                , th [ scope "col" ]
                                    [ text "시간" ]
                                , th [ scope "col" ]
                                    [ text "정보" ]
                                ]
                            ]
                        , tbody []
                            (viewActionList language selectedActionCategory account.account_name actions)
                        ]
                    , node "script"
                        []
                        [ text "(function () {var handler = document.querySelectorAll('span.memo.popup button.view');var opened_handler = '';for(var i=0; i < handler.length; i++) {handler[i].addEventListener('click',function () {if (!!opened_handler) {opened_handler.parentNode.parentNode.classList.remove('viewing');}if (opened_handler !== this) {this.parentNode.parentNode.classList.add('viewing');opened_handler = this;} else {this.parentNode.parentNode.classList.remove('viewing');opened_handler = '';}});}})();" ]
                    , div [ class "btn_area" ]
                        [ button [ type_ "button", class "view_more button", onClick ShowMore ]
                            [ text "더 보기" ]
                        ]
                    ]
                ]
            ]


viewActionList : Language -> SelectedActionCategory -> String -> List Action -> List (Html Message)
viewActionList language selectedActionCategory accountName actions =
    List.map (viewAction language selectedActionCategory accountName) actions
        |> List.reverse


viewAction : Language -> SelectedActionCategory -> String -> Action -> Html Message
viewAction language selectedActionCategory accountName ({ accountActionSeq, blockTime, actionName, actionTag } as action) =
    tr [ hidden (actionHidden selectedActionCategory actionName) ]
        [ td []
            [ text (toString accountActionSeq) ]
        , td []
            [ text actionTag ]
        , td []
            [ text (timeFormatter language blockTime) ]
        , (viewActionInfo accountName action)
        ]


actionHidden : SelectedActionCategory -> String -> Bool
actionHidden selectedActionCategory currentAction =
    case selectedActionCategory of
        "all" ->
            False

        _ ->
            if currentAction == selectedActionCategory then
                False
            else
                True
