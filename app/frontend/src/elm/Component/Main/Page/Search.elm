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
        )
import Html.Events exposing (onClick)
import Translation exposing (I18n(..), Language, translate)
import Http
import Util.HttpRequest exposing (getFullPath, post)
import Json.Encode as Encode
import Data.Action exposing (Action, actionsDecoder, refineAction)
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
        )


-- MODEL


type alias Model =
    { account : Account
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


initModel : Model
initModel =
    { account = defaultAccount
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
update message ({ account, actions, pagination } as model) =
    case message of
        OnFetchAccount (Ok data) ->
            ( { model | account = data }, Cmd.none )

        OnFetchAccount (Err error) ->
            ( model, Cmd.none )

        OnFetchActions (Ok actions) ->
            let
                refinedAction =
                    List.map (refineAction account.account_name) actions

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
                    getActions account.account_name pagination.nextPos pagination.offset
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

        ( cpuTotal, cpuPercent, cpuColor ) =
            getResource "cpu" account.cpu_limit.used account.cpu_limit.available account.cpu_limit.max

        ( netTotal, netPercent, netColor ) =
            getResource "net" account.net_limit.used account.net_limit.available account.net_limit.max

        ( ramTotal, ramPercent, ramColor ) =
            getResource "ram" account.ram_usage (account.ram_quota - account.ram_usage) account.ram_quota
    in
        section [ class "action view panel search_result" ]
            [ div [ class "account summary" ]
                [ ul [ class "summary" ]
                    [ li []
                        [ text "계정이름                "
                        , strong [ title account.account_name ]
                            [ text account.account_name ]
                        ]
                    , li []
                        [ text (translate language TotalAmount)
                        , strong []
                            [ text totalAmount ]
                        ]
                    ]
                , ul [ class "details" ]
                    [ li []
                        [ text "보관 안한 토큰"
                        , strong []
                            [ text account.core_liquid_balance ]
                        ]
                    , li []
                        [ text "보관 취소 토큰                "
                        , strong []
                            [ text unstakingAmount ]
                        ]
                    , li []
                        [ text "보관한 토큰                "
                        , strong []
                            [ text stakedAmount ]
                        ]
                    ]
                ]
            , h3 []
                [ text "리소스" ]
            , div [ class "resource" ]
                [ div [ class "cpu" ]
                    [ h4 []
                        [ text "CPU                "
                        , strong []
                            [ text (cpuTotal ++ " Total") ]
                        ]
                    , div [ class "graph" ]
                        [ span
                            [ attribute "data-status" cpuColor
                            , attribute "style"
                                ("width:" ++ cpuPercent)
                            , title
                                ("CPU :" ++ cpuPercent)
                            ]
                            []
                        ]
                    , p []
                        [ text
                            ("사용 가능한 용량이 " ++ cpuPercent ++ " 남았어요")
                        ]
                    ]
                , div [ class "net" ]
                    [ h4 []
                        [ text "NET                "
                        , strong []
                            [ text (netTotal ++ " Total") ]
                        ]
                    , div [ class "graph" ]
                        [ span
                            [ attribute "data-status" netColor
                            , attribute "style" ("width:" ++ netPercent)
                            , title ("NET :" ++ netPercent)
                            ]
                            []
                        ]
                    , p []
                        [ text ("사용 가능한 용량이 " ++ netPercent ++ " 남았어요") ]
                    ]
                , div [ class "ram" ]
                    [ h4 []
                        [ text "RAM                "
                        , strong []
                            [ text (ramTotal ++ " Total") ]
                        ]
                    , div [ class "graph" ]
                        [ span [ attribute "data-status" ramColor, attribute "style" ("width: " ++ ramPercent), title ("RAM : " ++ ramPercent) ]
                            []
                        ]
                    , p []
                        [ text ("사용 가능한 용량이 " ++ ramPercent ++ " 남았어요") ]
                    ]
                ]
            , div [ class "transaction_history" ]
                [ h3 []
                    [ text "트랜잭션" ]
                , div [ class "custom dropdown_list area", attribute "role" "list" ]
                    [ button [ attribute "aria-level" "1", attribute "role" "listitem", type_ "button" ]
                        [ text "트랜잭션 타입" ]
                    , div [ class "wrapper" ]
                        [ button [ attribute "role" "listitem", type_ "button", onClick (SelectActionCategory "all") ]
                            [ text "All" ]
                        , button [ attribute "role" "listitem", type_ "button", onClick (SelectActionCategory "transfer") ]
                            [ text "transfer" ]
                        ]
                    ]
                , node "script"
                    []
                    [ text "(function () {            var target = document.querySelector('div.dropdown_list'),                handler = document.querySelector('div.dropdown_list.area > button[aria-level]');            handler.addEventListener('click',function () {                target.classList.toggle('expand');            });        })();        " ]
                , table []
                    [ thead []
                        [ tr []
                            [ th [ scope "col" ]
                                [ text "#" ]
                            , th [ scope "col" ]
                                [ text "type" ]
                            , th [ scope "col" ]
                                [ text "time" ]
                            , th [ scope "col" ]
                                [ text "info" ]
                            ]
                        ]
                    , tbody []
                        (viewActionList selectedActionCategory actions)
                    ]
                , div [ class "btn_area center" ]
                    [ button [ class "bg_icon add blue_white load button", type_ "button", onClick ShowMore ]
                        [ text "더 보기" ]
                    ]
                ]
            ]


viewActionList : SelectedActionCategory -> List Action -> List (Html Message)
viewActionList selectedActionCategory actions =
    List.map (viewAction selectedActionCategory) actions
        |> List.reverse


viewAction : SelectedActionCategory -> Action -> Html Message
viewAction selectedActionCategory { accountActionSeq, blockTime, actionName, actionTag, info } =
    tr [ hidden (actionHidden selectedActionCategory actionName) ]
        [ td []
            [ text (toString accountActionSeq) ]
        , td []
            [ text actionTag ]
        , td []
            [ text blockTime ]
        , td []
            [ text info ]
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
