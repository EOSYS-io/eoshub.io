module Component.Main.Page.Search exposing (Message(..), Model, Pagination, SelectedActionCategory, actionHidden, getActions, initCmd, initModel, update, view, viewAction, viewActionList)

import Data.Account
    exposing
        ( Account
        , AccountPerm
        , KeyPerm
        , Permission
        , PermissionShortened
        , Refund
        , RequiredAuth
        , defaultAccount
        , getResource
        , getResourceColorClass
        , getTotalAmount
        , getUnstakingAmount
        )
import Data.Action exposing (Action, Message(..), actionsDecoder, refineAction, viewActionInfo)
import Html
    exposing
        ( Html
        , b
        , br
        , button
        , dd
        , div
        , dl
        , dt
        , h2
        , h3
        , h4
        , i
        , li
        , main_
        , option
        , p
        , s
        , section
        , select
        , span
        , strong
        , table
        , tbody
        , td
        , text
        , th
        , thead
        , tr
        , u
        , ul
        )
import Html.Attributes
    exposing
        ( attribute
        , class
        , hidden
        , id
        , name
        , scope
        , title
        , type_
        , value
        )
import Html.Events exposing (on, onClick, targetValue)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Translation exposing (I18n(..), Language, translate)
import Util.Formatter
    exposing
        ( floatToAsset
        , larimerToEos
        , timeFormatter
        )
import Util.HttpRequest exposing (getAccount, getFullPath, post)



-- MODEL


type alias Model =
    { query : String
    , account : Account
    , actions : List Action
    , pagination : Pagination
    , selectedActionCategory : SelectedActionCategory
    , openedActionSeq : Int
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
    , openedActionSeq = -1
    }


initCmd : String -> Model -> Cmd Message
initCmd query { pagination } =
    let
        accountCmd =
            query
                |> getAccount
                |> Http.send OnFetchAccount

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
        |> Http.send OnFetchActions



-- UPDATE


type Message
    = OnFetchAccount (Result Http.Error Account)
    | OnFetchActions (Result Http.Error (List Action))
    | SelectActionCategory SelectedActionCategory
    | ShowMore
    | ActionMessage Data.Action.Message


update : Message -> Model -> ( Model, Cmd Message )
update message ({ query, pagination, openedActionSeq } as model) =
    case message of
        OnFetchAccount (Ok data) ->
            ( { model | account = data }, Cmd.none )

        OnFetchAccount (Err _) ->
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

        OnFetchActions (Err _) ->
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

        ActionMessage (ShowMemo clickedActionSeq) ->
            let
                newOpenedActionSeq =
                    if openedActionSeq == clickedActionSeq then
                        -1

                    else
                        clickedActionSeq
            in
            ( { model | openedActionSeq = newOpenedActionSeq }, Cmd.none )



-- VIEW


view : Language -> Model -> Html Message
view language { account, actions, selectedActionCategory, openedActionSeq } =
    let
        totalAmount =
            getTotalAmount
                account.coreLiquidBalance
                account.voterInfo.staked
                account.refundRequest.netAmount
                account.refundRequest.cpuAmount

        unstakingAmount =
            getUnstakingAmount account.refundRequest.netAmount account.refundRequest.cpuAmount

        stakedAmount =
            floatToAsset (larimerToEos account.voterInfo.staked)

        ( cpuUsed, cpuAvailable, cpuTotal, cpuPercent, cpuColorCode ) =
            getResource "cpu" account.cpuLimit.used account.cpuLimit.available account.cpuLimit.max

        ( netUsed, netAvailable, netTotal, netPercent, netColorCode ) =
            getResource "net" account.netLimit.used account.netLimit.available account.netLimit.max

        ( ramUsed, ramAvailable, ramTotal, ramPercent, ramColorCode ) =
            getResource "ram" account.ramUsage (account.ramQuota - account.ramUsage) account.ramQuota
    in
    main_ [ class "search" ]
        [ h2 []
            [ text (translate language SearchAccount) ]
        , p []
            [ text (translate language SearchResultAccount) ]
        , div [ class "container" ]
            -- TODO(boseok): Separate sections into functions which return Html Message
            [ section [ class "summary" ]
                [ dl []
                    [ dt [ class "id" ]
                        [ text (translate language Translation.Account) ]
                    , dd []
                        [ text account.accountName ]
                    , dt [ class "total" ]
                        [ text (translate language TotalAmount) ]
                    , dd []
                        [ text totalAmount ]
                    ]
                , ul []
                    [ li []
                        [ span [] [ text "Staked" ]
                        , strong [ title stakedAmount ]
                            [ text stakedAmount ]
                        , i [] [ text "more infomation" ]
                        , b []
                            -- TODO(boseok): Get the real data with new request
                            [ u []
                                [ text "스테이크함:a1234567890" ]
                            , u []
                                [ text "스테이크 받음:a1234567890" ]
                            , u []
                                [ text "스테이크 해줌:a1234567890" ]
                            , s []
                                [ text "eosyskoreabp : 0.005 EOS" ]
                            , s []
                                [ text "eosyskoreabp : 0.005 EOS" ]
                            , s []
                                [ text "eosyskoreabp : 0.005 EOS" ]
                            , s []
                                [ text "eosyskoreabp : 0.005 EOS" ]
                            , s []
                                [ text "eosyskoreabp : 0.005 EOS" ]
                            ]
                        ]
                    , li []
                        [ span [] [ text "Unstaked" ]
                        , strong [ title account.coreLiquidBalance ]
                            [ text account.coreLiquidBalance ]
                        ]
                    , li []
                        [ span [] [ text "Refunding" ]
                        , strong [ title unstakingAmount ]
                            [ text unstakingAmount ]
                        ]
                    ]
                ]
            , section [ class "resource" ]
                [ h3 []
                    [ text (translate language Translation.Resource) ]
                , div [ class "wrapper" ]
                    [ div []
                        [ h4 []
                            [ text "CPU"
                            ]
                        , p []
                            [ text "Available"
                            , br []
                                []
                            , text cpuAvailable
                            ]
                        , p []
                            [ text ("Total: " ++ cpuTotal) ]
                        , p []
                            [ text ("Used: " ++ cpuUsed) ]
                        , div [ class "status" ]
                            [ span [ class (getResourceColorClass cpuColorCode), attribute "style" ("height:" ++ cpuPercent) ]
                                []
                            , text cpuPercent
                            ]
                        ]
                    , div []
                        [ h4 []
                            [ text "NET"
                            ]
                        , p []
                            [ text "Available"
                            , br []
                                []
                            , text netAvailable
                            ]
                        , p []
                            [ text ("Total: " ++ netTotal) ]
                        , p []
                            [ text ("Used: " ++ netUsed) ]
                        , div [ class "status" ]
                            [ span [ class (getResourceColorClass netColorCode), attribute "style" ("height:" ++ netPercent) ]
                                []
                            , text netPercent
                            ]
                        ]
                    , div []
                        [ h4 []
                            [ text "RAM"
                            ]
                        , p []
                            [ text "Available"
                            , br []
                                []
                            , text ramAvailable
                            ]
                        , p []
                            [ text ("Total: " ++ ramTotal) ]
                        , p []
                            [ text ("Used: " ++ ramUsed) ]
                        , div [ class "status" ]
                            [ span [ class (getResourceColorClass ramColorCode), attribute "style" ("height:" ++ ramPercent) ]
                                []
                            , text ramPercent
                            ]
                        ]
                    ]
                ]
            , viewPermissionSection language account
            , section [ class "transaction history" ]
                [ h3 []
                    [ text (translate language Transactions) ]
                , select [ id "", name "", on "change" (Decode.map SelectActionCategory targetValue) ]
                    [ option [ value "all" ]
                        [ text (translate language All) ]
                    , option [ value "transfer" ]
                        [ text (translate language Transfer) ]
                    ]
                , table []
                    [ thead []
                        [ tr []
                            [ th [ scope "col" ]
                                [ text (translate language Number) ]
                            , th [ scope "col" ]
                                [ text (translate language Type) ]
                            , th [ scope "col" ]
                                [ text (translate language Time) ]
                            , th [ scope "col" ]
                                [ text (translate language Info) ]
                            ]
                        ]
                    , tbody []
                        (viewActionList language selectedActionCategory account.accountName openedActionSeq actions)
                    ]
                , div [ class "btn_area" ]
                    [ button [ type_ "button", class "view_more button", onClick ShowMore ]
                        [ text (translate language Translation.ShowMore) ]
                    ]
                ]
            ]
        ]


viewPermissionSection : Language -> Account -> Html Message
viewPermissionSection language account =
    section [ class "permission" ]
        [ h3 []
            [ text "퍼미션" ]
        , table []
            [ thead []
                [ tr []
                    [ th [ scope "col" ]
                        [ text "Permission" ]
                    , th [ scope "col" ]
                        [ text "Threshold" ]
                    , th [ scope "col" ]
                        [ text "Keys" ]
                    ]
                ]
            , tbody []
                (viewPermissionList account.accountName account.permissions)
            ]
        ]


viewPermissionList : String -> List Permission -> List (Html Message)
viewPermissionList accountName permissions =
    List.map (viewPermission accountName) permissions


viewPermission : String -> Permission -> Html Message
viewPermission accountName { permName, requiredAuth } =
    tr []
        [ td []
            [ text (accountName ++ "@" ++ permName) ]
        , td []
            [ text (requiredAuth.threshold |> toString) ]

        -- TODO(boseok): Several perms
        , td []
            (viewKeyAccountPermList requiredAuth)
        ]


viewKeyAccountPermList : RequiredAuth -> List (Html Message)
viewKeyAccountPermList requiredAuth =
    let
        keyList =
            List.map viewKeyPermSpan requiredAuth.keys

        accountList =
            List.map viewAccountSpan requiredAuth.accounts
    in
    List.append keyList accountList


viewKeyPermSpan : KeyPerm -> Html Message
viewKeyPermSpan value =
    span []
        [ text ("+" ++ (value.weight |> toString) ++ " " ++ value.key)
        , br [] []
        ]


viewAccountSpan : AccountPerm -> Html Message
viewAccountSpan value =
    span []
        [ text
            ("+"
                ++ (value.weight |> toString)
                ++ " "
                ++ value.permission.actor
                ++ "@"
                ++ value.permission.permission
            )
        , br [] []
        ]


viewActionList : Language -> SelectedActionCategory -> String -> Int -> List Action -> List (Html Message)
viewActionList language selectedActionCategory accountName openedActionSeq actions =
    List.map (viewAction language selectedActionCategory accountName openedActionSeq) actions
        |> List.reverse


viewAction : Language -> SelectedActionCategory -> String -> Int -> Action -> Html Message
viewAction _ selectedActionCategory accountName openedActionSeq ({ accountActionSeq, blockTime, actionName, actionTag } as action) =
    tr [ hidden (actionHidden selectedActionCategory actionName) ]
        [ td []
            [ text (toString accountActionSeq) ]
        , td []
            [ text actionTag ]
        , td []
            [ text (timeFormatter blockTime) ]
        , Html.map ActionMessage (viewActionInfo accountName action openedActionSeq)
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
