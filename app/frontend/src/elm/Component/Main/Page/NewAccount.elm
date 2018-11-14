module Component.Main.Page.ChangeKey exposing (view)

import Html
    exposing
        ( Html
        , br
        , button
        , dd
        , div
        , dl
        , dt
        , form
        , h2
        , h3
        , input
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
import Html.Attributes exposing (attribute, class, id, placeholder, scope, step, type_)


view : Html msg
view =
    main_ [ class "create account" ]
        [ h2 []
            [ text "계정생성" ]
        , p []
            [ text "검색하신 계정에 대한 정보입니다." ]
        , div [ class "container" ]
            [ div [ class "account summary" ]
                [ h3 []
                    [ text "내 계정"
                    , strong []
                        [ text "blockone" ]
                    ]
                ]
            , form []
                [ ul []
                    [ li []
                        [ input [ attribute "autofocus" "", placeholder "새로 만들 계정의 이름을 입력하세요.", attribute "required" "", type_ "text" ]
                            []
                        , span [ class "validate description" ]
                            [ text "계정이름 예시:eoshubby" ]
                        ]
                    , li []
                        [ input [ placeholder "오너 키를 설정하세요.", type_ "text" ]
                            []
                        , span [ class "validate description" ]
                            []
                        ]
                    , li []
                        [ input [ placeholder "액티브 키를 설정하세요.", type_ "text" ]
                            []
                        , span [ class "validate description" ]
                            []
                        ]
                    ]
                ]
            , div [ class "btn_area align right" ]
                [ button [ class "undo button", attribute "disabled" "", type_ "button" ]
                    [ text "취소" ]
                , button [ class "ok button", attribute "disabled" "", type_ "button" ]
                    [ text "확인" ]
                ]
            , div [ class "account list" ]
                [ h3 []
                    [ text "생성한 계정목록" ]
                , table []
                    [ thead []
                        [ tr []
                            [ th [ scope "col" ]
                                [ text "계정" ]
                            , th [ scope "col" ]
                                [ text "키정보" ]
                            , th [ scope "col" ]
                                [ text "시간" ]
                            ]
                        ]
                    , tbody []
                        [ tr []
                            [ td []
                                [ text "eosyskoreabp" ]
                            , td []
                                [ text "owner : EOS55bzfeUCMvJuDZM4hxZbApSMsrdavAR18VuodiyYN5ARVVJBLy"
                                , br []
                                    []
                                , text "active : EOS55bzfeUCMvJuDZM4hxZbApSMsrdavAR18VuodiyYN5ARVVJBLy"
                                ]
                            , td []
                                [ text "8:06:36 AM, Apr 6, 2018" ]
                            ]
                        , tr []
                            [ td []
                                [ text "eosyskoreabp" ]
                            , td []
                                [ text "owner : EOS55bzfeUCMvJuDZM4hxZbApSMsrdavAR18VuodiyYN5ARVVJBLy"
                                , br []
                                    []
                                , text "active : EOS55bzfeUCMvJuDZM4hxZbApSMsrdavAR18VuodiyYN5ARVVJBLy"
                                ]
                            , td []
                                [ text "8:06:36 AM, Apr 6, 2018" ]
                            ]
                        , tr []
                            [ td []
                                [ text "eosyskoreabp" ]
                            , td []
                                [ text "owner : EOS55bzfeUCMvJuDZM4hxZbApSMsrdavAR18VuodiyYN5ARVVJBLy"
                                , br []
                                    []
                                , text "active : EOS55bzfeUCMvJuDZM4hxZbApSMsrdavAR18VuodiyYN5ARVVJBLy"
                                ]
                            , td []
                                [ text "8:06:36 AM, Apr 6, 2018" ]
                            ]
                        , tr []
                            [ td []
                                [ text "eosyskoreabp" ]
                            , td []
                                [ text "owner : EOS55bzfeUCMvJuDZM4hxZbApSMsrdavAR18VuodiyYN5ARVVJBLy"
                                , br []
                                    []
                                , text "active : EOS55bzfeUCMvJuDZM4hxZbApSMsrdavAR18VuodiyYN5ARVVJBLy"
                                ]
                            , td []
                                [ text "8:06:36 AM, Apr 6, 2018" ]
                            ]
                        , tr []
                            [ td []
                                [ text "eosyskoreabp" ]
                            , td []
                                [ text "owner : EOS55bzfeUCMvJuDZM4hxZbApSMsrdavAR18VuodiyYN5ARVVJBLy"
                                , br []
                                    []
                                , text "active : EOS55bzfeUCMvJuDZM4hxZbApSMsrdavAR18VuodiyYN5ARVVJBLy"
                                ]
                            , td []
                                [ text "8:06:36 AM, Apr 6, 2018" ]
                            ]
                        , tr []
                            [ td []
                                [ text "eosyskoreabp" ]
                            , td []
                                [ text "owner : EOS55bzfeUCMvJuDZM4hxZbApSMsrdavAR18VuodiyYN5ARVVJBLy"
                                , br []
                                    []
                                , text "active : EOS55bzfeUCMvJuDZM4hxZbApSMsrdavAR18VuodiyYN5ARVVJBLy"
                                ]
                            , td []
                                [ text "8:06:36 AM, Apr 6, 2018" ]
                            ]
                        ]
                    ]
                , div [ class "btn_area" ]
                    [ button [ class "view_more button", type_ "button" ]
                        [ text "더 보기" ]
                    ]
                ]
            ]
        , section [ attribute "aria-live" "true", class "create_account modal popup", id "popup", attribute "role" "alert" ]
            [ div [ class "wrapper" ]
                [ h2 []
                    [ text "계정 생성" ]
                , p []
                    [ text "현재 계정에서 보유한 토큰 수량중 아래에 명시된 수량만큼 새롭게 생성되는 계정으로 전송됩니다. " ]
                , dl []
                    [ dt []
                        [ text "CPU" ]
                    , dd []
                        [ text "0.1 EOS" ]
                    , dt []
                        [ text "NET" ]
                    , dd []
                        [ text "0.1 EOS" ]
                    , dt []
                        [ text "RAM" ]
                    , dd []
                        [ text "4 KB (4096 bytes)" ]
                    ]
                , div [ class "btn_area choice" ]
                    [ button [ class "rent choice button", type_ "button" ]
                        [ text "임대해주기" ]
                    , button [ class "send choice button", type_ "button" ]
                        [ text "전송하기" ]
                    ]
                , div [ class "btn_area" ]
                    [ button [ class "ok button", attribute "disabled" "", type_ "button" ]
                        [ text "확인" ]
                    ]
                , button [ class "close", id "closePopup", type_ "button" ]
                    [ text "닫기" ]
                ]
            ]
        ]
