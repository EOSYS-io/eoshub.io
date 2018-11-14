module Component.Main.Page.NewAccount exposing (Message, Model, initModel, update, view)

import Data.Account exposing (Account)
import Html
    exposing
        ( Html
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
        , text
        , ul
        )
import Html.Attributes
    exposing
        ( autofocus
        , class
        , disabled
        , id
        , placeholder
        , type_
        )
import Translation exposing (I18n(..), Language, translate)


type Message
    = None


type alias Model =
    {}


initModel : Model
initModel =
    {}


update : Message -> Model -> Account -> ( Model, Cmd Message )
update _ model _ =
    ( model, Cmd.none )


view : Language -> Model -> Account -> Html Message
view language _ { accountName } =
    main_ [ class "create account" ]
        [ h2 []
            [ text (translate language CreateAccount) ]
        , p []
            [ text (translate language CreateAccountDetail) ]
        , div [ class "container" ]
            [ div [ class "account summary" ]
                [ h3 []
                    [ text (translate language MyAccountDefault)
                    , strong []
                        [ text accountName ]
                    ]
                ]
            , form []
                [ ul []
                    [ li []
                        [ input
                            [ autofocus True
                            , placeholder (translate language AccountPlaceholder)
                            , type_ "text"
                            ]
                            []
                        , span [ class "validate description" ]
                            [ text (translate language AccountExample) ]
                        ]
                    , li []
                        [ input
                            [ placeholder (translate language TypeActiveKey)
                            , type_ "text"
                            ]
                            []
                        , span [ class "validate description" ]
                            []
                        ]
                    , li []
                        [ input
                            [ placeholder (translate language TypeOwnerKey)
                            , type_ "text"
                            ]
                            []
                        , span [ class "validate description" ]
                            []
                        ]
                    ]
                ]
            , div [ class "btn_area align right" ]
                [ button [ class "ok button", disabled True, type_ "button" ]
                    [ text (translate language Confirm) ]
                ]
            ]
        , section [ class "create_account modal popup", id "popup" ]
            [ div [ class "wrapper" ]
                [ h2 []
                    [ text (translate language CreateAccount) ]
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
                    [ button [ class "ok button", disabled True, type_ "button" ]
                        [ text (translate language Confirm) ]
                    ]
                , button [ class "close", id "closePopup", type_ "button" ]
                    [ text (translate language Close) ]
                ]
            ]
        ]
