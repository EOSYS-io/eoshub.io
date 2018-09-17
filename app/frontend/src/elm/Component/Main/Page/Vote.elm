module Component.Main.Page.Vote exposing (Message, Model, initModel, update, view)

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
        , attribute
        , class
        , for
        , id
        , placeholder
        , scope
        , src
        , title
        , type_
        )
import Html.Events exposing (onClick)
import Translation exposing (Language)



-- MESSAGE


type Tab
    = VoteTab
    | ProxyVoteTab


type Message
    = SwitchTab Tab



-- MODEL


type alias Model =
    { tab : Tab
    }


initModel : Model
initModel =
    { tab = VoteTab
    }



-- UPDATE


update : Message -> Model -> Model
update message model =
    case message of
        SwitchTab newTab ->
            { model | tab = newTab }



-- VIEW


view : Language -> Model -> Html Message
view _ { tab } =
    let
        ( addedMainClass, tabView ) =
            case tab of
                VoteTab ->
                    ( "", voteView )

                ProxyVoteTab ->
                    ( " proxy", proxyView )
    in
    main_ [ class ("vote" ++ addedMainClass) ]
        [ h2 []
            [ text "투표하기" ]
        , p []
            [ text "건강한 이오스 생태계를 위해 투표해주세요." ]
        , div [ class "tab" ]
            [ a
                [ class "vote ing tab button"
                , onClick (SwitchTab VoteTab)
                ]
                [ text "투표하기" ]
            , a
                [ class "proxy_vote tab button"
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
                        , button [ class "vote ok button", attribute "disabled" "", type_ "button" ]
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
                        [ text "" ]
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
                [ text "Proxied EOS      "
                , strong []
                    [ text "370,006,164.1111 EOS" ]
                ]
            , li []
                [ text "Proxied Accounts      "
                , strong []
                    [ text "147 Accounts" ]
                ]
            , li []
                [ text "Proxied BP      "
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
                [ img [ alt "", src "./image/bi-demo.png" ]
                    []
                , strong [ title "eosbpkorea" ]
                    [ text "eosyskoreabeosyskoreabeosyskoreabeosyskoreabppppeosyskoreabp" ]
                , span []
                    [ text "Korea" ]
                ]
            , li []
                [ img [ alt "", src "./image/bi-demo.png" ]
                    []
                , strong [ title "eosbpkorea" ]
                    [ text "eosyskoreabp" ]
                , span []
                    [ text "Korea" ]
                ]
            , li []
                [ img [ alt "", src "./image/bi-demo.png" ]
                    []
                , strong [ title "eosbpkorea" ]
                    [ text "eosyskoreabp" ]
                , span []
                    [ text "Korea" ]
                ]
            , li []
                [ img [ alt "", src "./image/bi-demo.png" ]
                    []
                , strong [ title "eosbpkorea" ]
                    [ text "eosyskoreabp" ]
                , span []
                    [ text "Korea" ]
                ]
            ]
        ]
    ]
