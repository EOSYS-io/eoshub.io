module Component.Main.Page.Vote exposing
    ( Message
    , Model
    , initCmd
    , initModel
    , update
    , view
    )

import Data.Account exposing (Account)
import Data.Json
    exposing
        ( Producer
        , VoteStat
        , initProducer
        , initVoteStat
        , producersDecoder
        , voteStatDecoder
        )
import Data.Table
    exposing
        ( GlobalFields
        , Row
        , TokenStatFields
        , initGlobalFields
        , initTokenStatFields
        )
import Html
    exposing
        ( Html
        , a
        , button
        , caption
        , dd
        , div
        , dl
        , dt
        , form
        , h2
        , h3
        , img
        , input
        , label
        , li
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
        , ul
        )
import Html.Attributes
    exposing
        ( alt
        , class
        , disabled
        , for
        , id
        , placeholder
        , scope
        , src
        , title
        , type_
        )
import Html.Events exposing (onClick)
import Http
import Round
import Task
import Time exposing (Time)
import Translation exposing (Language)
import Util.Flags exposing (Flags)
import Util.Formatter exposing (assetToFloat, formatWithUsLocale)
import Util.HttpRequest exposing (getAccount, getTableRows)
import Util.Urls exposing (getProducersUrl, getRecentVoteStatUrl)



-- MESSAGE


type Tab
    = VoteTab
    | ProxyVoteTab


type Message
    = SwitchTab Tab
    | OnFetchTableRows (Result Http.Error (List Row))
    | OnFetchVoteStat (Result Http.Error VoteStat)
    | OnFetchAccount (Result Http.Error Account)
    | OnFetchProducers (Result Http.Error (List Producer))
    | OnTime Time.Time



-- MODEL


type alias Model =
    { tab : Tab
    , globalTable : GlobalFields
    , tokenStatTable : TokenStatFields
    , producers : List Producer
    , voteStat : VoteStat
    , now : Time
    , proxies : List String
    }


initModel : Model
initModel =
    { tab = VoteTab
    , globalTable = initGlobalFields
    , tokenStatTable = initTokenStatFields
    , producers = []
    , voteStat = initVoteStat
    , now = 0.0
    , proxies = []
    }


getGlobalTable : Cmd Message
getGlobalTable =
    getTableRows "eosio" "eosio" "global"
        |> Http.send OnFetchTableRows


getTokenStatTable : Cmd Message
getTokenStatTable =
    getTableRows "eosio.token" "EOS" "stat"
        |> Http.send OnFetchTableRows


getProducers : Flags -> Cmd Message
getProducers flags =
    Http.get (getProducersUrl flags) producersDecoder |> Http.send OnFetchProducers


getRecentVoteStat : Flags -> Cmd Message
getRecentVoteStat flags =
    Http.get (getRecentVoteStatUrl flags) voteStatDecoder |> Http.send OnFetchVoteStat


getProxyAccount : Cmd Message
getProxyAccount =
    "bpgovernance"
        |> getAccount
        |> Http.send OnFetchAccount


getNow : Cmd Message
getNow =
    Task.perform OnTime Time.now


initCmd : Flags -> Cmd Message
initCmd flags =
    Cmd.batch
        [ getGlobalTable
        , getTokenStatTable
        , getProducers flags
        , getRecentVoteStat flags
        , getNow
        , getProxyAccount
        ]



-- UPDATE


update : Message -> Model -> Flags -> ( Model, Cmd Message )
update message model _ =
    case message of
        SwitchTab newTab ->
            ( { model | tab = newTab }, Cmd.none )

        OnFetchTableRows (Ok rows) ->
            case rows of
                (Data.Table.Global fields) :: [] ->
                    ( { model | globalTable = fields }, Cmd.none )

                (Data.Table.TokenStat fields) :: [] ->
                    ( { model | tokenStatTable = fields }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        OnFetchTableRows (Err _) ->
            ( model, Cmd.none )

        OnFetchProducers (Ok producers) ->
            ( { model | producers = producers }, Cmd.none )

        OnFetchProducers (Err _) ->
            ( model, Cmd.none )

        OnFetchVoteStat (Ok voteStat) ->
            ( { model | voteStat = voteStat }, Cmd.none )

        OnFetchVoteStat (Err _) ->
            ( model, Cmd.none )

        OnFetchAccount (Ok { voterInfo }) ->
            ( { model | proxies = voterInfo.producers }, Cmd.none )

        OnFetchAccount (Err _) ->
            ( model, Cmd.none )

        OnTime now ->
            ( { model | now = now }, Cmd.none )



-- VIEW


view : Language -> Model -> Html Message
view _ ({ tab, now } as model) =
    let
        ( addedMainClass, tabView, voteTabClass, proxyVoteTabClass ) =
            case tab of
                VoteTab ->
                    ( "", voteView model now, " ing", "" )

                ProxyVoteTab ->
                    ( " proxy", proxyView model, "", " ing" )
    in
    main_ [ class ("vote" ++ addedMainClass) ]
        [ h2 []
            [ text "투표하기" ]
        , p []
            [ text "건강한 이오스 생태계를 위해 투표해주세요." ]
        , div [ class "tab" ]
            [ a
                [ class ("vote tab button" ++ voteTabClass)
                , onClick (SwitchTab VoteTab)
                ]
                [ text "투표하기" ]
            , a
                [ class ("proxy_vote tab button" ++ proxyVoteTabClass)
                , onClick (SwitchTab ProxyVoteTab)
                ]
                [ text "대리투표" ]
            ]
        , div [ class "container" ] tabView
        ]


voteView : Model -> Time -> List (Html Message)
voteView { globalTable, tokenStatTable, producers, voteStat } now =
    let
        totalEos =
            tokenStatTable.supply |> assetToFloat

        formattedTotalEos =
            (totalEos
                |> formatWithUsLocale 4
            )
                ++ " EOS"

        formattedVotedEos =
            (voteStat.totalVotedEos
                |> formatWithUsLocale 4
            )
                ++ " EOS"

        totalVotePower =
            globalTable.totalProducerVoteWeight |> String.toFloat |> Result.withDefault 0

        votingPercentage =
            Round.round 2 ((voteStat.totalVotedEos / totalEos) * 100) ++ "%"
    in
    [ section [ class "vote summary" ]
        [ h3 []
            [ text "총 투표율" ]
        , p []
            [ text votingPercentage ]
        , dl []
            [ dt []
                [ text "투표된 EOS" ]
            , dd []
                [ text (formattedVotedEos ++ " (" ++ votingPercentage ++ ")") ]
            , dt []
                [ text "전체 EOS 수량" ]
            , dd []
                [ text formattedTotalEos ]
            ]
        , p []
            [ text "Vote for "
            , strong []
                [ text "eosyskoreabp!" ]
            ]
        ]
    , section [ class "bp list" ]
        [ table []
            [ caption []
                [ text "BP list" ]
            , thead []
                [ tr []
                    [ th [ scope "col" ]
                        [ text "순위" ]
                    , th [ scope "col" ]
                        [ span []
                            [ text "변동된 순위" ]
                        ]
                    , th [ class "search", scope "col" ]
                        [ form []
                            [ input [ placeholder "BP 후보 검색", type_ "text" ]
                                []
                            , button [ type_ "submit" ]
                                [ text "검색" ]
                            ]
                        ]
                    , th [ scope "col" ]
                        [ text "득표" ]
                    , th [ scope "col" ]
                        [ span [ class "count" ]
                            [ text "0/30" ]
                        , button [ class "vote ok button", disabled True, type_ "button" ]
                            [ text "투표" ]
                        ]
                    ]
                ]
            , tbody []
                (producers
                    |> List.map (producerTableRow totalVotePower (now |> Time.inSeconds))
                )
            ]
        ]
    ]


producerTableRow : Float -> Float -> Producer -> Html Message
producerTableRow totalVotedEos now { owner, totalVotes, country, rank, prevRank } =
    let
        ( upDownClass, delta ) =
            if rank < prevRank then
                ( "up", toString (prevRank - rank) )

            else if rank > prevRank then
                ( "down", toString (rank - prevRank) )

            else
                ( "", "-" )

        votingYield =
            (((totalVotes / totalVotedEos) * 100) |> Round.round 2) ++ "%"

        eosAmount =
            calculateEosQuantity totalVotes now

        formattedEos =
            (eosAmount
                |> formatWithUsLocale 4
            )
                ++ " EOS"
    in
    tr []
        [ td []
            [ text (rank |> toString) ]
        , td []
            [ span [ class upDownClass ]
                [ text delta ]
            ]
        , td []
            [ span [ class "bp bi" ]
                [ img []
                    []
                ]
            , strong []
                [ text owner ]
            , text country
            ]
        , td []
            [ strong []
                [ text votingYield ]
            , span []
                [ text formattedEos ]
            ]
        , td []
            [ input [ id "eos-1", type_ "checkbox" ]
                []
            , label [ for "eos-1" ]
                []
            ]
        ]


proxyView : Model -> List (Html Message)
proxyView { voteStat, producers, proxies } =
    let
        formattedProxiedEos =
            voteStat.eosysProxyStakedEos
                |> formatWithUsLocale 4

        proxiedAccounts =
            voteStat.eosysProxyStakedAccountCount |> toString

        proxyingAccountCount =
            proxies |> List.length |> toString
    in
    [ section [ class "philosophy" ]
        [ div [ class "animated image" ]
            []
        , div [ class "description" ]
            [ h3 []
                [ text "Vote Philosophy" ]
            , p []
                [ text "EOS Blockchain is secured and utilized only when the Block Producers have the trustworthiness. Trustworthiness could be measured by three important criteria. Technical Excellence, Governance and Community Engagement, and Sharing the Vision and Value of Their Own." ]
            , button [ class "ok button", type_ "button" ]
                [ text "대리투표 하기" ]
            ]
        ]
    , section [ class "proxy vote status" ]
        [ ul []
            [ li []
                [ text "Proxied EOS"
                , strong []
                    [ text
                        (formattedProxiedEos
                            ++ " EOS"
                        )
                    ]
                ]
            , li []
                [ text "Proxied Accounts"
                , strong []
                    [ text (proxiedAccounts ++ " Accounts") ]
                ]
            , li []
                [ text "Proxied BP"
                , strong []
                    [ text (proxyingAccountCount ++ " BP") ]
                ]
            ]
        ]
    , section [ class "voted bp" ]
        [ h3 []
            [ text "투표한 BP" ]
        , ul [ class "list" ]
            (List.map (producerSimplifiedView producers) proxies)
        ]
    ]


producerSimplifiedView : List Producer -> String -> Html Message
producerSimplifiedView producers accountName =
    let
        { country } =
            List.filter (\producer -> producer.owner == accountName) producers
                |> List.head
                |> Maybe.withDefault initProducer
    in
    li []
        [ img [ alt "", src "" ]
            []
        , strong [ title accountName ]
            [ text accountName ]
        , span []
            [ text country ]
        ]



-- Utility functions.


calculatePowerCoefficient : Float -> Float
calculatePowerCoefficient now =
    let
        secsSince2000 =
            now - 946684800

        secsOfWeek =
            604800

        power =
            toFloat (floor (secsSince2000 / secsOfWeek)) / 52.0
    in
    2 ^ power


calculateEosQuantity : Float -> Float -> Float
calculateEosQuantity votingPower now =
    let
        coeff =
            now |> calculatePowerCoefficient
    in
    (votingPower / 10000) / coeff
