module Component.Main.Page.ChangeKey exposing (Message, Model, initModel, update, view)

import Data.Account exposing (Account)
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


view : Language -> Model -> Account -> Html Message
view language _ { accountName } =
    main_ [ class "change account key" ]
        [ h2 []
            [ text (translate language ChangeKey) ]
        , p []
            [ text (translate language ChangeKeyDetail) ]
        , div [ class "container" ]
            [ div [ class "account summary" ]
                [ h3 []
                    [ text (translate language MyAccountDefault)
                    , strong []
                        [ text accountName ]
                    ]
                ]
            , div [ class "alert notice" ]
                [ h3 []
                    [ text (translate language Caution) ]
                , p []
                    [ text (translate language CautionDetail) ]
                ]
            , form []
                [ ul []
                    [ li []
                        [ input [ placeholder (translate language TypeOwnerKey), type_ "text" ]
                            []
                        , span [ class "true validate description" ]
                            [ text (translate language ValidKey) ]
                        ]
                    , li []
                        [ input [ placeholder (translate language TypeActiveKey), type_ "text" ]
                            []
                        , span [ class "false validate description" ]
                            [ text (translate language InvalidKey) ]
                        ]
                    ]
                ]
            , div [ class "btn_area align right" ]
                [ button [ class "ok button", disabled True, type_ "button" ]
                    [ text (translate language Confirm) ]
                ]
            ]
        ]
