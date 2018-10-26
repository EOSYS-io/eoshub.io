module Component.Main.Page.Vote exposing
    ( Message
    , Model
    , Tab(..)
    , initCmd
    , initModel
    , subscriptions
    , update
    , view
    )

import Data.Account exposing (Account, defaultAccount)
import Data.Action exposing (encodeAction)
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
        ( checked
        , class
        , disabled
        , for
        , href
        , id
        , placeholder
        , scope
        , target
        , title
        , type_
        , value
        )
import Html.Events exposing (onClick, onInput, onWithOptions, targetChecked)
import Http
import Json.Decode
import Port
import Round
import Set exposing (Set)
import Time exposing (Time)
import Translation exposing (I18n(..), Language, translate)
import Util.Constant exposing (eosysProxyAccount)
import Util.Flags exposing (Flags)
import Util.Formatter exposing (assetToFloat, formatWithUsLocale, getNow)
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
    | ExpandProducers
    | OnSearchInput String
    | SubmitVoteProxyAction
    | SubmitVoteProducersAction
    | OnToggleProducer String Bool
    | UpdateVoteData Time.Time



-- MODEL


type alias Model =
    { tab : Tab
    , globalTable : GlobalFields
    , tokenStatTable : TokenStatFields
    , producers : List Producer
    , voteStat : VoteStat
    , now : Time
    , proxies : List String
    , producersLimit : Int
    , searchInput : String
    , producerNamesToVote : Set String
    }


initModel : Account -> Model
initModel { voterInfo } =
    { tab = VoteTab
    , globalTable = initGlobalFields
    , tokenStatTable = initTokenStatFields
    , producers = []
    , voteStat = initVoteStat
    , now = 0.0
    , proxies = []
    , producersLimit = 100
    , searchInput = ""
    , producerNamesToVote = Set.fromList voterInfo.producers
    }


getGlobalTable : Cmd Message
getGlobalTable =
    getTableRows "eosio" "eosio" "global" 1
        |> Http.send OnFetchTableRows


getTokenStatTable : Cmd Message
getTokenStatTable =
    getTableRows "eosio.token" "EOS" "stat" 1
        |> Http.send OnFetchTableRows


getProducers : Flags -> Cmd Message
getProducers flags =
    Http.get (getProducersUrl flags) producersDecoder |> Http.send OnFetchProducers


getRecentVoteStat : Flags -> Cmd Message
getRecentVoteStat flags =
    Http.get (getRecentVoteStatUrl flags) voteStatDecoder |> Http.send OnFetchVoteStat


getProxyAccount : String -> Cmd Message
getProxyAccount proxyAccount =
    proxyAccount
        |> getAccount
        |> Http.send OnFetchAccount


initCmd : Flags -> Cmd Message
initCmd flags =
    Cmd.batch
        [ getGlobalTable
        , getTokenStatTable
        , getProducers flags
        , getRecentVoteStat flags
        , getNow OnTime
        , getProxyAccount eosysProxyAccount
        ]



-- UPDATE


update : Message -> Model -> Flags -> Account -> ( Model, Cmd Message )
update message ({ producersLimit, producerNamesToVote } as model) flags { accountName } =
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

        ExpandProducers ->
            ( { model | producersLimit = producersLimit + 100 }, Cmd.none )

        OnSearchInput searchInput ->
            ( { model | searchInput = searchInput |> String.toLower }, Cmd.none )

        SubmitVoteProxyAction ->
            let
                params =
                    Data.Action.VoteproducerParameters accountName eosysProxyAccount []
            in
            ( model
            , params
                |> Data.Action.Voteproducer
                |> encodeAction
                |> Port.pushAction
            )

        SubmitVoteProducersAction ->
            let
                params =
                    Data.Action.VoteproducerParameters accountName "" (producerNamesToVote |> Set.toList)
            in
            ( model
            , params
                |> Data.Action.Voteproducer
                |> encodeAction
                |> Port.pushAction
            )

        OnToggleProducer owner check ->
            if check then
                if Set.size producerNamesToVote >= 30 then
                    ( model, Cmd.none )

                else
                    ( { model | producerNamesToVote = Set.insert owner producerNamesToVote }, Cmd.none )

            else
                ( { model | producerNamesToVote = Set.remove owner producerNamesToVote }, Cmd.none )

        UpdateVoteData _ ->
            ( model
            , Cmd.batch
                [ getGlobalTable
                , getTokenStatTable
                , getProducers flags
                , getRecentVoteStat flags
                , getNow OnTime
                , getProxyAccount eosysProxyAccount
                ]
            )



-- VIEW


view : Language -> Model -> Account -> Html Message
view language ({ tab, now } as model) account =
    let
        ( addedMainClass, tabView, voteTabClass, proxyVoteTabClass ) =
            case tab of
                VoteTab ->
                    ( "", voteView model account language now, " ing", "" )

                ProxyVoteTab ->
                    ( " proxy", proxyView model account language, "", " ing" )
    in
    main_ [ class ("vote" ++ addedMainClass) ]
        [ h2 []
            [ text (translate language Vote) ]
        , p []
            [ text (translate language VoteDesc ++ " :)") ]
        , div [ class "tab" ]
            [ a
                [ class ("vote tab button" ++ voteTabClass)
                , onClick (SwitchTab VoteTab)
                ]
                [ text (translate language Vote) ]
            , a
                [ class ("proxy_vote tab button" ++ proxyVoteTabClass)
                , onClick (SwitchTab ProxyVoteTab)
                ]
                [ text (translate language ProxyVote) ]
            ]
        , div [ class "container" ] tabView
        ]


voteView : Model -> Account -> Language -> Time -> List (Html Message)
voteView { globalTable, tokenStatTable, producers, voteStat, producersLimit, searchInput, producerNamesToVote } account language now =
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

        filteredProducers =
            producers
                |> List.filter (\producer -> String.startsWith searchInput producer.owner)

        eosysAddedProducers =
            if String.isEmpty searchInput then
                List.append
                    (producers
                        |> List.filter (\{ owner } -> owner == "eosyskoreabp")
                    )
                    filteredProducers

            else
                filteredProducers

        producersView =
            eosysAddedProducers
                |> List.take producersLimit
                |> List.map (producerTableRow totalVotePower (now |> Time.inSeconds) producerNamesToVote)

        viewMoreButton =
            if List.length eosysAddedProducers > producersLimit then
                div [ class "btn_area" ]
                    [ button [ type_ "button", class "view_more button", onClick ExpandProducers ]
                        [ text (translate language ShowMore) ]
                    ]

            else
                text ""

        buttonDisabled =
            account == defaultAccount || Set.size producerNamesToVote == 0
    in
    [ section [ class "vote summary" ]
        [ h3 []
            [ text (translate language VoteRate) ]
        , p []
            [ text votingPercentage ]
        , dl []
            [ dt []
                [ text (translate language TotalVotedEos) ]
            , dd []
                [ text (formattedVotedEos ++ " (" ++ votingPercentage ++ ")") ]
            , dt []
                [ text (translate language TotalEosSupply) ]
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
                        [ text (translate language Rank) ]
                    , th [ scope "col" ]
                        [ span []
                            []
                        ]
                    , th [ class "search", scope "col" ]
                        [ form []
                            [ input
                                [ placeholder (translate language SearchBpCandidate)
                                , type_ "text"
                                , onInput <| OnSearchInput
                                , value searchInput
                                ]
                                []
                            , button [ type_ "submit" ]
                                []
                            ]
                        ]
                    , th [ scope "col" ]
                        [ text (translate language Poll) ]
                    , th [ scope "col" ]
                        [ span [ class "count" ]
                            [ text ((producerNamesToVote |> Set.size |> toString) ++ "/30") ]
                        , button
                            [ class "vote ok button"
                            , type_ "button"
                            , disabled buttonDisabled
                            , onClick SubmitVoteProducersAction
                            ]
                            [ text (translate language SimplifiedVote) ]
                        ]
                    ]
                ]
            , tbody [] producersView
            ]
        , viewMoreButton
        ]
    ]


producerTableRow : Float -> Float -> Set String -> Producer -> Html Message
producerTableRow totalVotedEos now producerNamesToVote { owner, totalVotes, country, rank, prevRank, url } =
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

        checkBoxValue =
            Set.member owner producerNamesToVote

        -- To prevent default browser action, redefine onCheck function.
        onCheck tagger =
            onWithOptions "click"
                { stopPropagation = True
                , preventDefault = True
                }
                (Json.Decode.map
                    tagger
                    targetChecked
                )
    in
    tr []
        [ td []
            [ text (rank |> toString) ]
        , td []
            [ span [ class upDownClass ]
                [ text delta ]
            ]
        , td []
            [ span [ class ("bi bp-" ++ owner) ]
                []
            , strong []
                [ a [ href url, target "_blank" ] [ text owner ] ]
            , text country
            ]
        , td []
            [ strong []
                [ text votingYield ]
            , span []
                [ text formattedEos ]
            ]
        , td []
            [ input
                [ id owner
                , type_ "checkbox"
                , onCheck <|
                    OnToggleProducer owner
                , checked checkBoxValue
                ]
                []
            , label [ for owner ]
                []
            ]
        ]


proxyView : Model -> Account -> Language -> List (Html Message)
proxyView { voteStat, producers, proxies } account language =
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
                [ text (translate language VotePhilosophy) ]
            , p []
                [ text (translate language VotePhilosophyDesc) ]
            , button
                [ class "ok button"
                , type_ "button"
                , disabled (account == defaultAccount)
                , onClick SubmitVoteProxyAction
                ]
                [ text (translate language DoProxyVote) ]
            ]
        ]
    , section [ class "proxy vote status" ]
        [ ul []
            [ li []
                [ text (translate language ProxiedEos)
                , strong []
                    [ text
                        (formattedProxiedEos
                            ++ " EOS"
                        )
                    ]
                ]
            , li []
                [ text (translate language ProxiedAccounts)
                , strong []
                    [ text (proxiedAccounts ++ " Accounts") ]
                ]
            , li []
                [ text (translate language VotedBp)
                , strong []
                    [ text (proxyingAccountCount ++ " BP") ]
                ]
            ]
        ]
    , section [ class "voted bp" ]
        [ h3 []
            [ text (translate language VoteStatus) ]
        , ul [ class "list" ]
            (List.map (producerSimplifiedView producers) proxies)
        ]
    ]


producerSimplifiedView : List Producer -> String -> Html Message
producerSimplifiedView producers accountName =
    let
        { country, url } =
            List.filter (\producer -> producer.owner == accountName) producers
                |> List.head
                |> Maybe.withDefault initProducer
    in
    li []
        [ span [ class ("bi bp-" ++ accountName) ]
            []
        , strong [ title accountName ]
            [ text accountName ]
        , span []
            [ text country ]
        , a [ href url, target "_blank" ] [ text url ]
        ]



-- SUBSCRIPTIONS


subscriptions : Sub Message
subscriptions =
    Time.every (3 * Time.minute) UpdateVoteData



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
