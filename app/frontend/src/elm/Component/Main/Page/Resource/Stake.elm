module Component.Main.Page.Resource.Stake exposing (..)

import Component.Main.Page.Transfer exposing (QuantityStatus(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Translation exposing (I18n(..), Language, translate)
import Data.Account
    exposing
        ( Account
        , ResourceInEos
        , Resource
        , Refund
        , accountDecoder
        , defaultAccount
        , keyAccountsDecoder
        , getTotalAmount
        , getUnstakingAmount
        , getResource
        )


-- MODEL


type alias Model =
    { stakeInput : String
    , quantityValidation : QuantityStatus
    , isFormValid : Bool
    }


initModel : Model
initModel =
    { stakeInput = ""
    , quantityValidation = EmptyQuantity
    , isFormValid = False
    }



-- UPDATE


type Message
    = InputStakeAmount String
    | OpenStakeAmountModal -- This is controlled at Resource module
    | StakePercentage Float


update : Message -> Model -> ResourceInEos -> ResourceInEos -> String -> ( Model, Cmd Message )
update message model totalResources selfDelegatedBandwidth coreLiquidBalance =
    let
        stakeAbleAmount =
            coreLiquidBalance
    in
        case message of
            InputStakeAmount value ->
                ( { model | stakeInput = value }, Cmd.none )

            StakePercentage percentage ->
                ( model, Cmd.none )

            _ ->
                ( model, Cmd.none )



-- VIEW


view : Language -> Model -> ResourceInEos -> ResourceInEos -> String -> Html Message
view language model totalResources selfDelegatedBandwidth coreLiquidBalance =
    div [ class "stake container" ]
        [ div [ class "my resource" ]
            [ div []
                [ h3 []
                    [ text "CPU 총량"
                    , strong []
                        [ text "18 EOS" ]
                    ]
                , p []
                    [ text "내가 스테이크한 토큰 : 8 EOS" ]
                , p []
                    [ text "임대받은 토큰 : 4 EOS" ]
                , div [ class "graph status" ]
                    [ span [ class "hell", attribute "style" "height:10%" ]
                        []
                    , text "10%"
                    ]
                ]
            , div []
                [ h3 []
                    [ text "NET 총량"
                    , strong []
                        [ text "18 EOS" ]
                    ]
                , p []
                    [ text "내가 스테이크한 토큰 : 8 EOS" ]
                , p []
                    [ text "임대받은 토큰 : 4 EOS" ]
                , div [ class "graph status" ]
                    [ span [ class "hell", attribute "style" "height:10%" ]
                        []
                    , text "10%"
                    ]
                ]
            ]
        , section []
            [ div [ class "wallet status" ]
                [ h3 []
                    [ text "스테이크 가능한 토큰" ]
                , p []
                    [ text "100 EOS" ]
                , a [ id "setDirect", onClick (OpenStakeAmountModal) ]
                    [ text "직접설정" ]
                ]
            , div [ class "input field" ]
                [ label [ for "eos" ]
                    [ text "EOS" ]
                , input [ attribute "autofocus" "", class "size large", id "EOS", Html.Attributes.max "1000000000", Html.Attributes.min "0.0001", pattern "\\d+(\\.\\d{1,4})?", placeholder "수량을 입력하세요", step "0.0001", type_ "number" ]
                    []
                , span [ class "validate description" ]
                    [ text "보유한 수량만큼 스테이크 할 수 있습니다." ]
                , button [ type_ "button", onClick (StakePercentage 0.1) ]
                    [ text "10%" ]
                , button [ type_ "button", onClick (StakePercentage 0.5) ]
                    [ text "50%" ]
                , button [ type_ "button", onClick (StakePercentage 0.7) ]
                    [ text "70%" ]
                , button [ type_ "button", onClick (StakePercentage 1) ]
                    [ text "최대" ]
                ]
            , div [ class "btn_area" ]
                [ button [ class "ok button", attribute "disabled" "", type_ "button" ]
                    [ text "확인" ]
                ]
            ]
        ]


quantityWarningSpan : QuantityStatus -> Language -> Html Message
quantityWarningSpan quantityStatus language =
    let
        ( classAddedValue, textValue ) =
            case quantityStatus of
                InvalidQuantity ->
                    ( " false", translate language InvalidAmount )

                OverTransferableQuantity ->
                    ( " false", translate language OverTransferableAmount )

                ValidQuantity ->
                    ( " true", translate language Transferable )

                EmptyQuantity ->
                    ( "", translate language TransferableAmountDesc )
    in
        span [ class ("validate description" ++ classAddedValue) ]
            [ text textValue ]
