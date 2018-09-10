module Component.Main.Page.Resource.Stake exposing (Message(..), Model, PercentageOfLiquid(..), distributeCpuNet, initModel, percentageButton, quantityWarningSpan, update, validate, view, viewStakeAmountModal)

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
import Data.Action as Action exposing (DelegatebwParameters, encodeAction)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Round
import Translation exposing (I18n(..), Language, translate)
import Util.Formatter exposing (eosFloatToString, eosStringAdd, eosStringSubtract, eosStringToFloat, larimerToEos)
import Util.Validation as Validation
    exposing
        ( AccountStatus(..)
        , MemoStatus(..)
        , QuantityStatus(..)
        , validateAccount
        , validateMemo
        , validateQuantity
        )



-- MODEL


type alias Model =
    { delegatebw : DelegatebwParameters
    , totalQuantity : String
    , percentageOfLiquid : PercentageOfLiquid
    , totalQuantityValidation : QuantityStatus
    , cpuQuantityValidation : QuantityStatus
    , netQuantityValidation : QuantityStatus
    , isFormValid : Bool
    , isStakeAmountModalOpened : Bool
    }


type PercentageOfLiquid
    = NoOp
    | Percentage10
    | Percentage50
    | Percentage70
    | Percentage100


initModel : Model
initModel =
    { delegatebw = { from = "", receiver = "", stakeNetQuantity = "", stakeCpuQuantity = "", transfer = 1 }
    , totalQuantity = ""
    , percentageOfLiquid = NoOp
    , totalQuantityValidation = EmptyQuantity
    , cpuQuantityValidation = EmptyQuantity
    , netQuantityValidation = EmptyQuantity
    , isFormValid = False
    , isStakeAmountModalOpened = False
    }



-- UPDATE


type Message
    = TotalAmountInput String
    | StakePercentage Float
    | OpenStakeAmountModal
    | CloseModal


update : Message -> Model -> Account -> ( Model, Cmd Message )
update message ({ delegatebw, totalQuantity } as model) ({ totalResources, selfDelegatedBandwidth, coreLiquidBalance } as account) =
    let
        stakeAbleAmount =
            coreLiquidBalance
    in
    case message of
        TotalAmountInput value ->
            let
                ( cpuQuantity, netQuantity ) =
                    distributeCpuNet value 7 3
            in
            ( { model
                | totalQuantity = value
                , delegatebw =
                    { delegatebw | stakeCpuQuantity = cpuQuantity, stakeNetQuantity = netQuantity }
                , percentageOfLiquid = NoOp
              }
            , Cmd.none
            )

        StakePercentage ratio ->
            let
                value =
                    eosStringToFloat coreLiquidBalance
                        * ratio
                        |> Round.round 4

                percentageOfLiquid =
                    case ratio of
                        0.1 ->
                            Percentage10

                        0.5 ->
                            Percentage50

                        0.7 ->
                            Percentage70

                        1 ->
                            Percentage100

                        _ ->
                            NoOp

                ( cpuQuantity, netQuantity ) =
                    distributeCpuNet value 7 3
            in
            ( { model
                | totalQuantity = value
                , delegatebw =
                    { delegatebw | stakeCpuQuantity = cpuQuantity, stakeNetQuantity = netQuantity }
                , percentageOfLiquid = percentageOfLiquid
              }
            , Cmd.none
            )

        OpenStakeAmountModal ->
            ( { model | isStakeAmountModalOpened = True }, Cmd.none )

        CloseModal ->
            ( { model | isStakeAmountModalOpened = False }, Cmd.none )



-- VIEW


view : Language -> Model -> Account -> Html Message
view language ({ delegatebw, totalQuantity, percentageOfLiquid, isStakeAmountModalOpened } as model) ({ totalResources, selfDelegatedBandwidth, coreLiquidBalance } as account) =
    let
        stakedAmount =
            eosFloatToString (larimerToEos account.voterInfo.staked)

        ( cpuUsed, cpuAvailable, cpuTotal, cpuPercent, cpuColor ) =
            getResource "cpu" account.cpuLimit.used account.cpuLimit.available account.cpuLimit.max

        ( netUsed, netAvailable, netTotal, netPercent, netColor ) =
            getResource "net" account.netLimit.used account.netLimit.available account.netLimit.max
    in
    div [ class "stake container" ]
        [ div [ class "my resource" ]
            [ div []
                [ h3 []
                    [ text "CPU 총량"
                    , strong []
                        [ text totalResources.cpuWeight ]
                    ]
                , p []
                    [ text ("내가 스테이크한 토큰 : " ++ selfDelegatedBandwidth.cpuWeight) ]
                , p []
                    [ text
                        ("임대받은 토큰 : "
                            ++ eosStringSubtract
                                totalResources.cpuWeight
                                selfDelegatedBandwidth.cpuWeight
                        )
                    ]
                , div [ class "graph status" ]
                    [ span [ class cpuColor, attribute "style" ("height:" ++ cpuPercent) ]
                        []
                    , text cpuPercent
                    ]
                ]
            , div []
                [ h3 []
                    [ text "NET 총량"
                    , strong []
                        [ text totalResources.netWeight ]
                    ]
                , p []
                    [ text ("내가 스테이크한 토큰 : " ++ selfDelegatedBandwidth.netWeight) ]
                , p []
                    [ text
                        ("임대받은 토큰 : "
                            ++ eosStringSubtract
                                totalResources.netWeight
                                selfDelegatedBandwidth.netWeight
                        )
                    ]
                , div [ class "graph status" ]
                    [ span [ class netColor, attribute "style" ("height:" ++ netPercent) ]
                        []
                    , text netPercent
                    ]
                ]
            ]
        , section []
            [ div [ class "wallet status" ]
                [ h3 []
                    [ text "스테이크 가능한 토큰" ]
                , p []
                    [ text coreLiquidBalance ]
                , a [ onClick OpenStakeAmountModal ]
                    [ text "직접설정" ]
                ]
            , div [ class "input field" ]
                [ label [ for "eos" ]
                    [ text "EOS" ]

                -- TODO(boseok) Change it to Elm code
                , input
                    [ attribute "autofocus" ""
                    , class "size large"
                    , id "EOS"
                    , Html.Attributes.max "1000000000"
                    , Html.Attributes.min "0.0001"
                    , pattern "\\d+(\\.\\d{1,4})?"
                    , placeholder "수량을 입력하세요"
                    , step "0.0001"
                    , type_ "number"
                    , onInput TotalAmountInput
                    , value totalQuantity
                    ]
                    []
                , span [ class "validate description" ]
                    [ text "보유한 수량만큼 스테이크 할 수 있습니다." ]

                -- TODO(boseok): this should be applied to new design
                , p [ class "validate description" ]
                    [ text ("cpu : " ++ delegatebw.stakeCpuQuantity) ]
                , p [ class "validate description" ]
                    [ text ("net : " ++ delegatebw.stakeNetQuantity) ]
                , percentageButton percentageOfLiquid Percentage10 0.1
                , percentageButton percentageOfLiquid Percentage50 0.5
                , percentageButton percentageOfLiquid Percentage70 0.7
                , percentageButton percentageOfLiquid Percentage100 1
                ]
            , div [ class "btn_area" ]
                [ button [ class "ok button", attribute "disabled" "", type_ "button" ]
                    [ text "확인" ]
                ]
            ]
        , viewStakeAmountModal isStakeAmountModalOpened
        ]


viewStakeAmountModal : Bool -> Html Message
viewStakeAmountModal opened =
    section
        [ attribute "aria-live" "true"
        , class
            ("set_division_manual modal popup"
                ++ (if opened then
                        " viewing"

                    else
                        ""
                   )
            )
        , id "popup"
        , attribute "role" "alert"
        ]
        [ div [ class "wrapper" ]
            [ h2 []
                [ text "토큰 스테이크 수량 직접 설정" ]
            , div [ class "token status" ]
                [ h3 []
                    [ text "스테이크할 토큰"
                    , strong []
                        [ text "10 EOS" ]
                    ]
                , button [ class "set auto button", type_ "button" ]
                    [ text "자동 분배" ]
                ]
            , div [ class "form container" ]
                [ h3 []
                    [ text "CPU" ]
                , p []
                    [ text "Staked : 18 EOS" ]
                , Html.form [ action "", class "true validate" ]
                    [ input [ class "user", attribute "data-validate" "false", id "", name "", placeholder "스테이크할 수량을 설정하세요", type_ "text" ]
                        []
                    , span []
                        [ text "EOS" ]
                    ]
                ]
            , div [ class "form container" ]
                [ h3 []
                    [ text "NET" ]
                , p []
                    [ text "Staked : 18 EOS" ]
                , Html.form [ action "" ]
                    [ input [ class "user", attribute "data-validate" "true", id "", name "", placeholder "스테이크할 수량을 설정하세요", type_ "text" ]
                        []
                    , span []
                        [ text "EOS" ]
                    ]
                ]
            , div [ class "btn_area" ]
                [ button [ class "ok button", attribute "disabled" "", type_ "button" ]
                    [ text "확인" ]
                ]
            , p [ class "validate description" ]
                [ text "7:3 비율로 스테이킹 하는 것이 가장 좋습니다." ]
            , div [ class "btn_area" ]
                [ button [ class "undo button", type_ "button", onClick CloseModal ]
                    [ text "취소" ]
                , button [ class "ok button", attribute "disabled" "", type_ "button" ]
                    [ text "확인" ]
                ]
            ]
        ]


percentageButton : PercentageOfLiquid -> PercentageOfLiquid -> Float -> Html Message
percentageButton percentageOfLiquid thisPercentageOfLiquid ratio =
    let
        buttonText =
            if ratio < 1 then
                Round.round 0 (ratio * 100) ++ "%"

            else
                "최대"
    in
    button
        [ type_ "button"
        , class
            (if percentageOfLiquid == thisPercentageOfLiquid then
                "clicked"

             else
                ""
            )
        , onClick (StakePercentage ratio)
        ]
        [ text buttonText ]


quantityWarningSpan : QuantityStatus -> Language -> Html Message
quantityWarningSpan quantityStatus language =
    let
        ( classAddedValue, textValue ) =
            case quantityStatus of
                InvalidQuantity ->
                    ( " false", translate language InvalidAmount )

                OverValidQuantity ->
                    ( " false", translate language OverTransferableAmount )

                ValidQuantity ->
                    ( " true", translate language Transferable )

                EmptyQuantity ->
                    ( "", translate language TransferableAmountDesc )
    in
    span [ class ("validate description" ++ classAddedValue) ]
        [ text textValue ]


validate : Model -> Float -> Model
validate ({ delegatebw } as model) eosLiquidAmount =
    let
        { from, receiver, stakeNetQuantity, stakeCpuQuantity } =
            delegatebw

        totalQuantity =
            eosStringAdd stakeNetQuantity stakeCpuQuantity

        netQuantityValidation =
            validateQuantity stakeNetQuantity eosLiquidAmount

        cpuQuantityValidation =
            validateQuantity stakeCpuQuantity eosLiquidAmount

        totalQuantityValidation =
            validateQuantity totalQuantity eosLiquidAmount

        isFormValid =
            (netQuantityValidation == ValidQuantity)
                && (cpuQuantityValidation == ValidQuantity)
    in
    { model
        | totalQuantityValidation = netQuantityValidation
        , cpuQuantityValidation = cpuQuantityValidation
        , netQuantityValidation = netQuantityValidation
        , isFormValid = isFormValid
    }


distributeCpuNet : String -> Float -> Float -> ( String, String )
distributeCpuNet totalQuantity a b =
    let
        cpuQuantity =
            eosFloatToString <| eosStringToFloat totalQuantity * (a / (a + b))

        netQuantity =
            eosStringSubtract totalQuantity cpuQuantity
    in
    ( cpuQuantity, netQuantity )
