module Component.Main.Page.Index exposing (Message(ChangeUrl), view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Translation exposing (I18n(..), Language, translate)



-- MESSAGE --


type Message
    = ChangeUrl String



-- VIEW --


view : Language -> Html Message
view language =
    main_ [ class "index" ]
        [ section [ class "menu_area" ]
            [ h2 [] [ text "Menu" ]
            , div [ class "container" ]
                [ div [ class "greeting" ]
                    [ h3 []
                        [ text (translate language Hello)
                        , br [] []
                        , text (translate language WelcomeEosHub)
                        ]
                    , p
                        []
                        [ a [] [ text "이오스 허브 사용법 보기" ]
                        ]
                    ]
                , a
                    [ onClick (ChangeUrl "/resource")
                    , class "card resource"
                    ]
                    [ h3 [] [ text "리소스 관리" ]
                    , p [] [ text "이오스 동작을 위한 리소스를 관리합니다." ]
                    ]
                , a
                    [ onClick (ChangeUrl "/transfer")
                    , class "card transfer"
                    ]
                    [ h3 [] [ text (translate language Transfer) ]
                    , p [] [ text (translate language TransferHereDesc) ]
                    ]
                , a
                    [ onClick (ChangeUrl "/rammarket")
                    , class "card ram_market"
                    ]
                    [ h3 [] [ text (translate language RamMarket) ]
                    , p [] [ text (translate language RamMarketDesc) ]
                    ]
                , a
                    [ onClick (ChangeUrl "/voting")
                    , class "card vote"
                    ]
                    [ h3 [] [ text (translate language Vote) ]
                    , p [] [ text (translate language VoteDesc) ]
                    ]
                ]
            ]
        , section [ class "dapps" ]
            [ h2 [] [ text "최신 이오스 디앱" ]
            , p [] [ text "업데이트되는 다양한 이오스 디앱들을 만나보세요" ]
            , div [ class "rolling banner" ]
                [ text "Comming Soon"
                ]
            , a [ class "view more" ] [ text " 더 보기" ]
            ]
        ]
