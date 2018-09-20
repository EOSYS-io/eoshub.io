module Component.Main.Page.Vote exposing
    ( Message
    , Model
    , initCmd
    , initModel
    , update
    , view
    )

import Data.Json
    exposing
        ( Producer
        , VoteStat
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
import Translation exposing (Language)
import Util.Flags exposing (Flags)
import Util.HttpRequest exposing (getTableRows)
import Util.Urls exposing (getProducersUrl, getRecentVoteStatUrl)



-- MESSAGE


type Tab
    = VoteTab
    | ProxyVoteTab


type Message
    = SwitchTab Tab
    | OnFetchTableRows (Result Http.Error (List Row))
    | OnFetchVoteStat (Result Http.Error VoteStat)
    | OnFetchProducers (Result Http.Error (List Producer))



-- MODEL


type alias Model =
    { tab : Tab
    , globalTable : GlobalFields
    , tokenStatTable : TokenStatFields
    , producers : List Producer
    , voteStat : VoteStat
    }


initModel : Model
initModel =
    { tab = VoteTab
    , globalTable = initGlobalFields
    , tokenStatTable = initTokenStatFields
    , producers = []
    , voteStat = initVoteStat
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


initCmd : Flags -> Cmd Message
initCmd flags =
    Cmd.batch [ getGlobalTable, getTokenStatTable, getProducers flags, getRecentVoteStat flags ]



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



-- VIEW


view : Language -> Model -> Html Message
view _ { tab } =
    let
        ( addedMainClass, tabView, voteTabClass, proxyVoteTabClass ) =
            case tab of
                VoteTab ->
                    ( "", voteView, " ing", "" )

                ProxyVoteTab ->
                    ( " proxy", proxyView, "", " ing" )
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


voteView : List (Html Message)
voteView =
    [ section [ class "vote summary" ]
        [ h3 []
            [ text "총 투표율" ]
        , p []
            [ text "36.7304%" ]
        , dl []
            [ dt []
                [ text "투표된 EOS" ]
            , dd []
                [ text "378,289,459.8382 EOS (37.4233%)" ]
            , dt []
                [ text "전체 EOS 수량" ]
            , dd []
                [ text "1,010,840,557.0558 EOS" ]
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
                [ tr [ class "buy korea" ]
                    [ td []
                        [ text "21" ]
                    , td []
                        [ span []
                            [ text "-" ]
                        ]
                    , td []
                        [ span [ class "bp bi" ]
                            [ img [ alt "", src "" ]
                                []
                            ]
                        , strong []
                            [ text "eos-1" ]
                        , text "korea"
                        ]
                    , td []
                        [ strong []
                            [ text "2.16%" ]
                        , span []
                            [ text "(64,173,932.6431 EOS)" ]
                        ]
                    , td []
                        [ input [ id "eos-1", type_ "checkbox" ]
                            []
                        , label [ for "eos-1", title "eos-1에 투표하시려면 체크하세요!" ]
                            [ text "eosyskoreabp에 투표하시려면 체크하세요!" ]
                        ]
                    ]
                , tr []
                    [ td []
                        [ text "21" ]
                    , td []
                        [ span [ class "up" ] [ text "21" ] ]
                    , td []
                        [ span [ class "bp bi" ]
                            [ img [ alt "", src "" ]
                                []
                            ]
                        , strong []
                            [ text "eos-2" ]
                        , text "korea"
                        ]
                    , td []
                        [ strong []
                            [ text "2.16%" ]
                        , span []
                            [ text "(64,173,932.6431 EOS)" ]
                        ]
                    , td []
                        [ input [ id "eos-2", type_ "checkbox" ]
                            []
                        , label [ for "eos-2" ]
                            [ text "eosyskoreabp에 투표하시려면 체크하세요!" ]
                        ]
                    ]
                ]
            ]
        ]
    ]


proxyView : List (Html Message)
proxyView =
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
                    [ text "370,006,164.1111 EOS" ]
                ]
            , li []
                [ text "Proxied Accounts"
                , strong []
                    [ text "147 Accounts" ]
                ]
            , li []
                [ text "Proxied BP"
                , strong []
                    [ text "9 BP" ]
                ]
            ]
        ]
    , section [ class "voted bp" ]
        [ h3 []
            [ text "투표한 BP" ]
        , ul [ class "list" ]
            [ li []
                [ img [ alt "", src "" ]
                    []
                , strong [ title "eosbpkorea" ]
                    [ text "eosyskoreabeosyskoreabeosyskoreabeosyskoreabppppeosyskoreabp" ]
                , span []
                    [ text "Korea" ]
                ]
            , li []
                [ img [ alt "", src "" ]
                    []
                , strong [ title "eosbpkorea" ]
                    [ text "eosyskoreabp" ]
                , span []
                    [ text "Korea" ]
                ]
            , li []
                [ img [ alt "", src "" ]
                    []
                , strong [ title "eosbpkorea" ]
                    [ text "eosyskoreabp" ]
                , span []
                    [ text "Korea" ]
                ]
            , li []
                [ img [ alt "", src "" ]
                    []
                , strong [ title "eosbpkorea" ]
                    [ text "eosyskoreabp" ]
                , span []
                    [ text "Korea" ]
                ]
            ]
        ]
    ]
