module Component.Main.Page.Resource.Undelegate exposing (Message(..), Model, initModel, update, view)

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
import Html.Events exposing (onClick, onInput)
import Translation exposing (I18n(..), Language, translate)



-- MODEL


type alias Model =
    { undelegateInput : String
    }


initModel : Model
initModel =
    { undelegateInput = "" }



-- UPDATE


type Message
    = InputUndelegateAmount String
    | OpenDelegateListModal -- This is controlled at Resource module


update : Message -> Model -> Account -> ( Model, Cmd Message )
update message model ({ totalResources, selfDelegatedBandwidth, coreLiquidBalance } as account) =
    case message of
        InputUndelegateAmount value ->
            ( { model | undelegateInput = value }, Cmd.none )

        _ ->
            ( model, Cmd.none )



-- VIEW


view : Language -> Model -> Account -> Html Message
view language model ({ totalResources, selfDelegatedBandwidth, coreLiquidBalance } as account) =
    div [ class "rental cancel container" ]
        [ div [ class "available status" ]
            [ h3 []
                [ text "임대해준 토큰 총량"
                , strong []
                    [ text "8 EOS" ]
                ]
            , a [ id "viewRentalListAccount", onClick OpenDelegateListModal ]
                [ text "임대해준 계정 리스트 보기" ]
            ]
        , section []
            [ div [ class "input field" ]
                [ input [ attribute "autofocus" "", class "size large", attribute "maxlength" "12", pattern "[\\w\\d]+", placeholder "임대취소할 계정의 이름을 입력하세요", attribute "required" "", type_ "text" ]
                    []
                , span [ class "validate description" ]
                    [ text "계정이름 예시:eoshubby" ]
                ]
            ]
        , section []
            [ h3 []
                [ text "임대해준 토큰 총량" ]
            , p []
                [ text "0 EOS" ]
            , div [ class "field group" ]
                [ div [ class "input field" ]
                    [ label [ for "cpu" ]
                        [ text "CPU" ]
                    , input [ id "cpu", Html.Attributes.max "1000000000", Html.Attributes.min "0.0001", pattern "\\d+(\\.\\d{1,4})?", placeholder "0", step "0.0001", type_ "number" ]
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
        ]
