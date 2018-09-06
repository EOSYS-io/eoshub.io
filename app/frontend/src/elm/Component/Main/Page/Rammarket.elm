module Component.Main.Page.Rammarket exposing (view)

import Html
    exposing
        ( Html
        , div
        , h2
        , h3
        , text
        , main_
        , section
        , i
        , form
        , input
        , a
        , button
        , p
        , span
        )
import Html.Attributes
    exposing
        ( class
        , style
        , type_
        , placeholder
        , attribute
        , disabled
        , id
        )
import Translation exposing (Language, I18n(..), translate)


-- VIEW


view : Language -> Html message
view language =
    main_ [ class "ram_market" ]
        [ h2 [] [ text (translate language RamMarket) ]
        , p [] [ text (translate language RamMarketDesc) ]
        , section [ class "dashboard" ]
            [ div [ class "ram status" ]
                [ div [ class "wrapper" ]
                    [ h3 [] [ text "이오스 램 가격" ]
                    , p [] [ text "0.15793210 EOS/kb" ]
                    ]
                , div [ class "wrapper" ]
                    [ h3 [] [ text "램 점유율" ]
                    , p [] [ text "46.44/66.36GB (69.97%)" ]
                    ]
                , div [ class "graph", id "tv_chart_container" ] []
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
        ]
