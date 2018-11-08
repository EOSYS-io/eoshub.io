module Component.Main.Page.ChangeKey exposing (Message, Model, initModel, update, view)

import Html
    exposing
        ( Html
        , button
        , div
        , form
        , h2
        , h3
        , input
        , li
        , main_
        , p
        , span
        , strong
        , text
        , ul
        )
import Html.Attributes exposing (class, disabled, placeholder, type_)
import Translation exposing (I18n(..), Language(..), translate)


type Message
    = None


type alias Model =
    {}


initModel : Model
initModel =
    {}


update : Message -> Model -> Model
update message model =
    case message of
        None ->
            model


view : Language -> Model -> Html Message
view _ _ =
    main_ [ class "change account key" ]
        [ h2 []
            [ text "계정 키 변경" ]
        , p []
            [ text "@owner키로만 변경이 가능하며 오너와 액티브 중 하나만 변경할 수도 있습니다." ]
        , div [ class "container" ]
            [ div [ class "account summary" ]
                [ h3 []
                    [ text "내 계정"
                    , strong []
                        [ text "blockone" ]
                    ]
                ]
            , div [ class "alert notice" ]
                [ h3 []
                    [ text "주의사항" ]
                , p []
                    [ text "Make sure you have access to the private key associated with the public key you enter. Otherwise, you will lose access to your account. NOTE: If you wish to change the \"owner\" key, you must select the \"@owner\" account in your Scatter identity." ]
                ]
            , form []
                [ ul []
                    [ li []
                        [ input [ placeholder "변경할 오너 키를 설정하세요.", type_ "text" ]
                            []
                        , span [ class "true validate description" ]
                            [ text "변경가능한 오너 키입니다." ]
                        ]
                    , li []
                        [ input [ placeholder "변경할 액티브 키를 설정하세요.", type_ "text" ]
                            []
                        , span [ class "false validate description" ]
                            [ text "변경 가능한 액티브 키가 아닙니다." ]
                        ]
                    ]
                ]
            , div [ class "btn_area align right" ]
                [ button [ class "undo button", disabled True, type_ "button" ]
                    [ text "취소" ]
                , button [ class "ok button", disabled True, type_ "button" ]
                    [ text "확인" ]
                ]
            ]
        ]
