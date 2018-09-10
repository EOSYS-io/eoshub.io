module Component.Main.Page.Resource.Delegate exposing (Message(..), Modal(..), Model, initModel, update, view)

import Component.Main.Page.Resource.Modal.DelegateList as DelegateList
    exposing
        ( Message(..)
        , viewDelegateListModal
        )
import Data.Account
    exposing
        ( Account
        , Refund
        , Resource
        , ResourceInEos
        , accountDecoder
        , defaultAccount
        , getResource
        , getTotalAmount
        , getUnstakingAmount
        , keyAccountsDecoder
        )
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Translation exposing (I18n(..), Language, translate)



-- MODEL


type alias Model =
    { delegateInput : String
    , modal : Modal
    }


type Modal
    = DelegateListModal DelegateList.Model


initModel : Model
initModel =
    { delegateInput = ""
    , modal = DelegateListModal DelegateList.initModel
    }



-- UPDATE


type Message
    = InputDelegateAmount String
    | OpenDelegateListModal
    | DelegateListMessage DelegateList.Message


update : Message -> Model -> Account -> ( Model, Cmd Message )
update message ({ modal } as model) ({ totalResources, selfDelegatedBandwidth, coreLiquidBalance } as account) =
    case ( message, modal ) of
        ( InputDelegateAmount value, _ ) ->
            ( { model | delegateInput = value }, Cmd.none )

        ( OpenDelegateListModal, _ ) ->
            case modal of
                DelegateListModal modalModel ->
                    ( { model
                        | modal =
                            DelegateListModal
                                { modalModel
                                    | isDelegateListModalOpened = True
                                }
                      }
                    , Cmd.none
                    )

        ( DelegateListMessage subMessage, DelegateListModal subModel ) ->
            let
                ( newModel, _ ) =
                    DelegateList.update subMessage subModel
            in
            ( { model | modal = DelegateListModal newModel }, Cmd.none )



-- VIEW


view : Language -> Model -> Account -> Html Message
view language ({ modal } as model) ({ totalResources, selfDelegatedBandwidth, coreLiquidBalance } as account) =
    let
        modalHtml =
            case modal of
                DelegateListModal subModel ->
                    Html.map DelegateListMessage (viewDelegateListModal language subModel)
    in
    div [ class "rental cancel container" ]
        [ div [ class "available status" ]
            [ h3 []
                [ text "임대가능 토큰수량"
                , strong []
                    [ text "8 EOS" ]
                ]
            , a [ id "viewRentalListAccount", onClick OpenDelegateListModal ]
                [ text "임대해준 계정 리스트 보기" ]
            ]
        , section []
            [ div [ class "input field" ]
                -- TODO(boseok) Change it to Elm code
                [ input
                    [ attribute "autofocus" ""
                    , class "size large"
                    , attribute "maxlength" "12"
                    , pattern "[\\w\\d]+"
                    , placeholder "임대해줄 계정의 이름을 입력하세요"
                    , attribute "required" ""
                    , type_ "text"
                    ]
                    []
                , span [ class "validate description" ]
                    [ text "계정이름 예시:eoshubby" ]
                ]
            ]
        , section []
            [ h3 []
                [ text "임대해 줄 토큰 총량" ]
            , p []
                [ text "0 EOS" ]
            , div [ class "field group" ]
                [ div [ class "input field" ]
                    [ label [ for "cpu" ]
                        [ text "CPU" ]

                    -- TODO(boseok) Change it to Elm code
                    , input
                        [ id "cpu"
                        , Html.Attributes.max "1000000000"
                        , Html.Attributes.min "0.0001"
                        , pattern "\\d+(\\.\\d{1,4})?"
                        , placeholder "0"
                        , step "0.0001"
                        , type_ "number"
                        ]
                        []
                    , span [ class "unit" ]
                        [ text "EOS" ]
                    , button [ type_ "button" ]
                        [ text "10%" ]
                    , button [ type_ "button" ]
                        [ text "50%" ]
                    , button [ type_ "button" ]
                        [ text "70%" ]
                    , button [ type_ "button" ]
                        [ text "최대" ]
                    ]
                , div [ class "input field" ]
                    [ label [ for "net" ]
                        [ text "NET" ]
                    , input [ id "net", Html.Attributes.max "1000000000", Html.Attributes.min "0.0001", pattern "\\d+(\\.\\d{1,4})?", placeholder "0", step "0.0001", type_ "number" ]
                        []
                    , span [ class "unit" ]
                        [ text "EOS" ]
                    , button [ type_ "button" ]
                        [ text "10%" ]
                    , button [ type_ "button" ]
                        [ text "50%" ]
                    , button [ type_ "button" ]
                        [ text "70%" ]
                    , button [ type_ "button" ]
                        [ text "최대" ]
                    ]
                ]
            , div [ class "btn_area" ]
                [ button [ class "ok button", attribute "disabled" "", type_ "button" ]
                    [ text "확인" ]
                ]
            ]
        , modalHtml
        ]
