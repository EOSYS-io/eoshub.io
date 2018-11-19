module Component.Main.Page.Search exposing
    ( Message(..)
    , Model
    , Pagination
    , SelectedActionCategory
    , actionCategory
    , actionHidden
    , filterDelbandWithAccountName
    , initCmd
    , initModel
    , removeQuatation
    , sumStakedToList
    , update
    , view
    , viewAccountSpan
    , viewAction
    , viewActionList
    , viewKeyPermissionLevelWeightList
    , viewKeyWeightSpan
    , viewPermission
    , viewPermissionSection
    , viewStakedDetail
    )

import Data.Account
    exposing
        ( Account
        , Permission
        , defaultAccount
        , getResource
        , getResourceColorClass
        , getTotalAmount
        , getUnstakingAmount
        )
import Data.Action as Action
    exposing
        ( Action
        , refineAction
        , removeDuplicated
        )
import Data.Common exposing (Authority, KeyWeight, PermissionLevelWeight)
import Data.Table exposing (Row(..))
import Date
import Date.Extra as Date exposing (Interval(..))
import Dict exposing (Dict)
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
        , em
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
        )
import Html.Events exposing (on, onClick, targetValue)
import Http
import Json.Decode as Decode
import Navigation
import Regex exposing (HowMany(..), regex, replace)
import Time exposing (Time)
import Translation exposing (I18n(..), Language, translate)
import Util.Constant exposing (historyApiLimit)
import Util.Formatter
    exposing
        ( eosAdd
        , eosSubtract
        , floatToAsset
        , getNow
        , larimerToEos
        , timeFormatter
        )
import Util.HttpRequest exposing (getAccount, getActions, getTableRows)
import Util.Urls exposing (getAccountUrl, getPubKeyUrl)
import View.Common exposing (addSearchLink)



-- MODEL


type alias Model =
    { query : String
    , account : Account
    , delbandTable : List Row
    , actions : List Action
    , pagination : Pagination
    , selectedActionCategory : SelectedActionCategory
    , openedActionSeq : Int
    , now : Time
    }


type alias Pagination =
    { base : Int
    , isLoading : Bool
    , isEnd : Bool
    }


type alias SelectedActionCategory =
    String


type alias OpenedActionSeq =
    Int


initModel : String -> Model
initModel accountName =
    { query = accountName
    , account = defaultAccount
    , delbandTable = []
    , actions = []
    , pagination =
        { base = 0
        , isLoading = True
        , isEnd = False
        }
    , selectedActionCategory = "all"
    , openedActionSeq = -1
    , now = 0
    }


actionCategory : Dict String (List String)
actionCategory =
    Dict.fromList
        [ ( "transfer", [ "transfer" ] )
        , ( "claimrewards", [ "claimrewards" ] )
        , ( "ram", [ "buyram", "buyrambytes", "sellram" ] )
        , ( "resource", [ "delegatebw", "undelegatebw" ] )
        , ( "regproxy", [ "regproxy" ] )
        , ( "voteproducer", [ "voteproducer" ] )
        , ( "newaccount", [ "newaccount" ] )
        ]


initCmd : String -> Model -> Cmd Message
initCmd query { pagination } =
    let
        accountCmd =
            query
                |> getAccount
                |> Http.send OnFetchAccount

        actionsCmd =
            getActions query pagination.base historyApiLimit
                |> Http.send OnFetchActions

        delbandCmd =
            getTableRows "eosio" query "delband" -1
                |> Http.send OnFetchTableRows
    in
    Cmd.batch
        [ accountCmd
        , actionsCmd
        , delbandCmd
        , getNow OnTime
        ]


type Message
    = OnFetchAccount (Result Http.Error Account)
    | OnFetchTableRows (Result Http.Error (List Row))
    | OnFetchActions (Result Http.Error (List Action))
    | SelectActionCategory SelectedActionCategory
    | ShowMore
    | ShowMemo OpenedActionSeq
    | ChangeUrl String
    | OnTime Time.Time


update : Message -> Model -> ( Model, Cmd Message )
update message ({ query, pagination, openedActionSeq } as model) =
    case message of
        OnFetchAccount (Ok data) ->
            ( { model | account = data }, Cmd.none )

        OnFetchAccount (Err _) ->
            ( model, Navigation.newUrl "/notfound" )

        OnFetchTableRows (Ok rows) ->
            ( { model | delbandTable = rows }, Cmd.none )

        OnFetchTableRows (Err _) ->
            ( model, Cmd.none )

        OnFetchActions (Ok actions) ->
            let
                uniqueActions =
                    removeDuplicated actions

                refinedActions =
                    List.map (refineAction query) uniqueActions
                        |> List.reverse
            in
            if List.length actions > 0 then
                ( { model
                    | actions = refinedActions ++ model.actions
                    , pagination =
                        { pagination
                            | base = pagination.base + historyApiLimit
                            , isLoading = False
                        }
                  }
                , Cmd.none
                )

            else
                -- NOTE(boseok): There're no more actions to load
                ( { model
                    | actions = refinedActions ++ model.actions
                    , pagination = { pagination | isEnd = True, isLoading = False }
                  }
                , Cmd.none
                )

        OnFetchActions (Err _) ->
            ( { model | pagination = { pagination | isLoading = False } }, Cmd.none )

        SelectActionCategory selectedActionCategory ->
            ( { model | selectedActionCategory = selectedActionCategory }, Cmd.none )

        ShowMore ->
            let
                actionsCmd =
                    getActions query pagination.base historyApiLimit
                        |> Http.send OnFetchActions
            in
            if not pagination.isEnd then
                ( { model | pagination = { pagination | isLoading = True } }, actionsCmd )

            else
                -- TODO(boseok): alert it is the end of records
                ( model, Cmd.none )

        ShowMemo clickedActionSeq ->
            let
                newOpenedActionSeq =
                    if openedActionSeq == clickedActionSeq then
                        -1

                    else
                        clickedActionSeq
            in
            ( { model | openedActionSeq = newOpenedActionSeq }, Cmd.none )

        ChangeUrl url ->
            ( model, Navigation.newUrl url )

        OnTime now ->
            ( { model | now = now }, Cmd.none )



-- VIEW


view : Language -> Model -> Html Message
view language ({ account, actions, selectedActionCategory, openedActionSeq, now, pagination } as model) =
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
            account.voterInfo.staked |> larimerToEos |> floatToAsset 4 "EOS"

        ( cpuUsed, cpuAvailable, cpuTotal, cpuPercent, cpuColorCode ) =
            getResource "cpu" account.cpuLimit.used account.cpuLimit.available account.cpuLimit.max

        ( netUsed, netAvailable, netTotal, netPercent, netColorCode ) =
            getResource "net" account.netLimit.used account.netLimit.available account.netLimit.max

        ( ramUsed, ramAvailable, ramTotal, ramPercent, ramColorCode ) =
            getResource "ram" account.ramUsage (account.ramQuota - account.ramUsage) account.ramQuota

        resourceDetailDiv topic available total used colorCode percent =
            div []
                [ h4 []
                    [ text topic
                    ]
                , p []
                    [ text (translate language AvailableCapacity)
                    , br []
                        []
                    , text available
                    ]
                , p []
                    [ text (translate language (TotalCapacity total)) ]
                , p []
                    [ text (translate language (UsedCapacity used)) ]
                , div [ class "status" ]
                    [ span [ class (getResourceColorClass colorCode), attribute "style" ("height:" ++ percent) ]
                        []
                    , text percent
                    ]
                ]
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
                        [ span [] [ text "Unstaked" ]
                        , strong [ title account.coreLiquidBalance ]
                            [ text account.coreLiquidBalance ]
                        ]
                    , li []
                        [ span [] [ text "Staked" ]
                        , strong [ title stakedAmount ]
                            [ text stakedAmount ]
                        , i [] [ text "more infomation" ]
                        , viewStakedDetail language model
                        ]
                    , li []
                        [ span [] [ text "Refunding" ]
                        , strong [ title unstakingAmount ]
                            [ text unstakingAmount ]
                        , span [ class "remaining time" ] [ text (getLeftTime account.refundRequest.requestTime now) ]
                        ]
                    ]
                ]
            , section [ class "resource" ]
                [ h3 []
                    [ text (translate language Translation.Resource) ]
                , div [ class "wrapper" ]
                    [ resourceDetailDiv "CPU" cpuAvailable cpuTotal cpuUsed cpuColorCode cpuPercent
                    , resourceDetailDiv "NET" netAvailable netTotal netUsed netColorCode netPercent
                    , resourceDetailDiv "RAM" ramAvailable ramTotal ramUsed ramColorCode ramPercent
                    ]
                ]
            , viewPermissionSection language account
            , section [ class "transaction history" ]
                [ h3 []
                    [ text (translate language Actions) ]
                , select
                    [ id ""
                    , name ""
                    , Html.Attributes.value selectedActionCategory
                    , on "change" (Decode.map SelectActionCategory targetValue)
                    ]
                    [ option [ Html.Attributes.value "all" ]
                        [ text (translate language Translation.All) ]
                    , option [ Html.Attributes.value "transfer" ]
                        [ text (translate language Transfer) ]
                    , option [ Html.Attributes.value "claimrewards" ]
                        [ text (translate language Claimrewards) ]
                    , option [ Html.Attributes.value "ram" ]
                        [ text (translate language Ram) ]
                    , option [ Html.Attributes.value "resource" ]
                        [ text "CPU / NET" ]
                    , option [ Html.Attributes.value "regproxy" ]
                        [ text (translate language Regproxy) ]
                    , option [ Html.Attributes.value "voteproducer" ]
                        [ text (translate language Voteproducer) ]
                    , option [ Html.Attributes.value "newaccount" ]
                        [ text (translate language NewaccountTx) ]
                    ]
                , table []
                    [ thead []
                        [ tr []
                            [ th [ scope "col" ]
                                [ text (translate language TxId) ]
                            , th [ scope "col" ]
                                [ text (translate language Type) ]
                            , th [ scope "col" ]
                                [ text (translate language Time) ]
                            , th [ scope "col" ]
                                [ text (translate language Info) ]
                            ]
                        ]
                    , tbody []
                        (viewActionList selectedActionCategory account.accountName openedActionSeq actions)
                    ]
                , viewShowMoreButton language pagination
                ]
            ]
        ]


viewStakedDetail : Language -> Model -> Html Message
viewStakedDetail language { account, delbandTable } =
    let
        { totalResources, selfDelegatedBandwidth } =
            account

        totalResourceAmount =
            eosAdd totalResources.cpuWeight totalResources.netWeight

        selfStakedAmount =
            eosAdd selfDelegatedBandwidth.cpuWeight selfDelegatedBandwidth.netWeight

        stakedByAmount =
            eosSubtract totalResourceAmount selfStakedAmount

        stakedToAmount =
            sumStakedToList delbandTable account.accountName

        uElement i18n amount =
            u []
                [ text
                    (translate language i18n
                        ++ ": "
                        ++ amount
                    )
                ]

        totalList =
            [ uElement SelfStaked selfStakedAmount
            , uElement StakedBy stakedByAmount
            , uElement StakedTo stakedToAmount
            ]

        delbandList =
            delbandTable
                |> filterDelbandWithAccountName account.accountName
                |> List.map
                    (\maybeDelband ->
                        let
                            ( maybeReceiver, sum ) =
                                case maybeDelband of
                                    Delband { receiver, cpuWeight, netWeight } ->
                                        ( receiver, eosAdd cpuWeight netWeight )

                                    _ ->
                                        ( "", "0 EOS" )
                        in
                        s [] [ text (maybeReceiver ++ ": " ++ sum) ]
                    )
    in
    b []
        (List.append totalList delbandList)


sumStakedToList : List Row -> String -> String
sumStakedToList delbandTable accountName =
    let
        delbandEachSumList =
            delbandTable
                |> filterDelbandWithAccountName accountName
                |> List.map
                    (\maybeDelband ->
                        case maybeDelband of
                            Delband { cpuWeight, netWeight } ->
                                eosAdd cpuWeight netWeight

                            _ ->
                                "0 EOS"
                    )
    in
    List.foldl eosAdd "0 EOS" delbandEachSumList


filterDelbandWithAccountName : String -> List Row -> List Row
filterDelbandWithAccountName accountName delbandTable =
    List.filter
        (\maybeDelband ->
            case maybeDelband of
                Delband { receiver } ->
                    receiver /= accountName

                _ ->
                    False
        )
        delbandTable


viewPermissionSection : Language -> Account -> Html Message
viewPermissionSection language account =
    section [ class "permission" ]
        [ h3 []
            [ text (translate language Permissions) ]
        , table []
            [ thead []
                [ tr []
                    [ th [ scope "col" ]
                        [ text (translate language Translation.Permission) ]
                    , th [ scope "col" ]
                        [ text (translate language Threshold) ]
                    , th [ scope "col" ]
                        [ text (translate language Keys) ]
                    ]
                ]
            , tbody []
                (List.map (viewPermission account.accountName) account.permissions)
            ]
        ]


viewPermission : String -> Permission -> Html Message
viewPermission accountName { permName, requiredAuth } =
    tr []
        [ td []
            [ text (accountName ++ "@" ++ permName) ]
        , td []
            [ text (requiredAuth.threshold |> toString) ]
        , td []
            (viewKeyPermissionLevelWeightList requiredAuth)
        ]


viewKeyPermissionLevelWeightList : Authority -> List (Html Message)
viewKeyPermissionLevelWeightList authority =
    let
        keyList =
            List.map viewKeyWeightSpan authority.keys

        accountList =
            List.map viewAccountSpan authority.accounts
    in
    List.append keyList accountList


viewKeyWeightSpan : KeyWeight -> Html Message
viewKeyWeightSpan { key, weight } =
    span []
        [ text
            ("+" ++ (weight |> toString) ++ " ")
        , addSearchLink
            (key |> getPubKeyUrl |> ChangeUrl)
            (text key)
        , br [] []
        ]


viewAccountSpan : PermissionLevelWeight -> Html Message
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


viewActionList : SelectedActionCategory -> String -> Int -> List Action -> List (Html Message)
viewActionList selectedActionCategory accountName openedActionSeq actions =
    List.map (viewAction selectedActionCategory accountName openedActionSeq) actions
        |> List.reverse


viewAction : SelectedActionCategory -> String -> Int -> Action -> Html Message
viewAction selectedActionCategory _ openedActionSeq ({ trxId, blockTime, actionName, actionTag } as action) =
    tr [ hidden (actionHidden selectedActionCategory actionName) ]
        [ td [ title trxId ]
            [ text trxId ]
        , td [ class (String.toLower actionTag) ]
            [ text actionTag ]
        , td []
            [ text (timeFormatter blockTime) ]
        , viewActionInfo action openedActionSeq
        ]


viewShowMoreButton : Language -> Pagination -> Html Message
viewShowMoreButton language pagination =
    div [ class "btn_area" ]
        [ button
            [ type_ "button"
            , class
                ("view_more button"
                    ++ (if pagination.isLoading then
                            " loading"

                        else
                            ""
                       )
                )
            , onClick ShowMore
            ]
            [ text (translate language Translation.ShowMore) ]
        ]


viewAccountLink : String -> Html Message
viewAccountLink query =
    addSearchLink (query |> getAccountUrl |> ChangeUrl) (em [] [ text query ])


viewBpAccountLink : String -> Html Message
viewBpAccountLink bp =
    addSearchLink (bp |> getAccountUrl |> ChangeUrl) (span [] [ em [] [ text bp ], text ", " ])


viewActionInfo : Action -> Int -> Html Message
viewActionInfo { globalSequence, contractAccount, actionName, data } openedActionSeq =
    case data of
        -- controlled actions
        Ok actionParameters ->
            case ( contractAccount, actionName ) of
                ( "eosio.token", "transfer" ) ->
                    case actionParameters of
                        Action.Transfer _ params ->
                            td [ class "info" ]
                                [ viewAccountLink params.from
                                , text " -> "
                                , viewAccountLink params.to
                                , span [ class "asset" ] [ text (" " ++ params.quantity) ]
                                , span
                                    [ class
                                        ("memo popup"
                                            ++ (if globalSequence == openedActionSeq then
                                                    " viewing"

                                                else
                                                    ""
                                               )
                                        )
                                    , title "클릭하시면 메모를 보실 수 있습니다."
                                    ]
                                    [ span []
                                        [ strong [ attribute "role" "title" ]
                                            [ text "메모" ]
                                        , span [ class "description" ]
                                            [ text params.memo ]
                                        , button [ class "icon view button", type_ "button", onClick (ShowMemo globalSequence) ]
                                            [ text "열기/닫기" ]
                                        ]
                                    ]
                                ]

                        _ ->
                            td [] []

                ( "eosio", "sellram" ) ->
                    case actionParameters of
                        Action.Sellram params ->
                            td [ class "info" ]
                                [ viewAccountLink params.account
                                , text (" sold " ++ toString params.bytes ++ " bytes RAM")
                                ]

                        _ ->
                            td [] []

                ( "eosio", "buyram" ) ->
                    case actionParameters of
                        Action.Buyram params ->
                            td [ class "info" ]
                                [ viewAccountLink params.payer
                                , text (" bought " ++ params.quant ++ " RAM for ")
                                , viewAccountLink params.receiver
                                ]

                        _ ->
                            td [] []

                ( "eosio", "buyrambytes" ) ->
                    case actionParameters of
                        Action.Buyrambytes params ->
                            td [ class "info" ]
                                [ viewAccountLink params.payer
                                , text (" bought " ++ toString params.bytes ++ "bytes RAM for ")
                                , viewAccountLink params.receiver
                                ]

                        _ ->
                            td [] []

                ( "eosio", "delegatebw" ) ->
                    case actionParameters of
                        Action.Delegatebw params ->
                            td [ class "info" ]
                                [ viewAccountLink params.from
                                , text " delegated to the account "
                                , viewAccountLink params.receiver
                                , text
                                    (" "
                                        ++ params.stakeNetQuantity
                                        ++ " for NET, and "
                                        ++ params.stakeCpuQuantity
                                        ++ " for CPU "
                                        ++ (if params.transfer == 1 then
                                                "(transfer)"

                                            else
                                                ""
                                           )
                                    )
                                ]

                        _ ->
                            td [] []

                ( "eosio", "undelegatebw" ) ->
                    case actionParameters of
                        Action.Undelegatebw params ->
                            td [ class "info" ]
                                [ viewAccountLink params.receiver
                                , text " undelegated from the account "
                                , viewAccountLink params.from
                                , text
                                    (" "
                                        ++ params.unstakeNetQuantity
                                        ++ " for NET, and "
                                        ++ params.unstakeCpuQuantity
                                        ++ " for CPU"
                                    )
                                ]

                        _ ->
                            td [] []

                ( "eosio", "regproxy" ) ->
                    case actionParameters of
                        Action.Regproxy params ->
                            td [ class "info" ]
                                [ viewAccountLink params.proxy
                                , text
                                    (if params.isproxy == 1 then
                                        " registered as voting proxy"

                                     else
                                        " unregistered as voting proxy"
                                    )
                                ]

                        _ ->
                            td [] []

                ( "eosio", "voteproducer" ) ->
                    case actionParameters of
                        Action.Voteproducer params ->
                            td [ class "info" ]
                                [ viewAccountLink params.voter
                                , if String.length params.proxy == 0 then
                                    span []
                                        (text " voted for block producers "
                                            :: List.map viewBpAccountLink params.producers
                                        )

                                  else
                                    span []
                                        [ text " voted through "
                                        , viewAccountLink params.proxy
                                        ]
                                ]

                        _ ->
                            td [] []

                ( "eosio", "newaccount" ) ->
                    case actionParameters of
                        Action.Newaccount params ->
                            td [ class "info" ]
                                [ text "New account "
                                , viewAccountLink params.name
                                , text " was created by "
                                , viewAccountLink params.creator
                                ]

                        _ ->
                            td [ class "info" ] []

                _ ->
                    td [ class "info" ]
                        [ text (toString actionParameters) ]

        -- undefined actions in eoshub
        Err str ->
            td [ class "info" ]
                [ text (removeQuatation str) ]


removeQuatation : String -> String
removeQuatation str =
    str
        |> replace Regex.All (regex "([\\\\][\\\"])") (\_ -> "'")
        |> replace Regex.All (regex "\"") (\_ -> "")


actionHidden : SelectedActionCategory -> String -> Bool
actionHidden selectedActionCategory currentAction =
    let
        maybeSet =
            Dict.get selectedActionCategory actionCategory
                |> Maybe.withDefault []
    in
    case selectedActionCategory of
        "all" ->
            False

        _ ->
            if List.member currentAction maybeSet then
                False

            else
                True


getLeftTime : String -> Time -> String
getLeftTime requestTime now =
    case Date.fromIsoString (requestTime ++ "+00:00") of
        Ok time ->
            let
                expectedDate =
                    Date.add Hour 72 time

                nowDate =
                    Date.fromTime now

                leftHours =
                    Date.diff Hour nowDate expectedDate

                leftMinutes =
                    Date.diff Minute nowDate expectedDate
            in
            if leftHours < 1 then
                (leftMinutes |> toString) ++ " minutes"

            else
                (leftHours |> toString) ++ " hours"

        Err _ ->
            ""
