module Component.Main.Page.Resource.Stake exposing
    ( DistributionRatio
    , Message(..)
    , Model
    , PercentageOfLiquid(..)
    , StakeAmountMessage(..)
    , StakeAmountModal
    , distributeCpuNet
    , getPercentageOfLiquid
    , initModel
    , modalValidateAttr
    , percentageButton
    , quantityWarningSpan
    , update
    , validate
    , view
    , viewStakeAmountModal
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
import Data.Action as Action exposing (DelegatebwParameters, encodeAction)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Port
import Round
import Translation exposing (I18n(..), Language, translate)
import Util.Formatter
    exposing
        ( assetAdd
        , assetSubtract
        , assetToFloat
        , floatToAsset
        , formatAsset
        , larimerToEos
        , removeSymbolIfExists
        )
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
    , distributionRatio : DistributionRatio
    , totalQuantityValidation : QuantityStatus
    , cpuQuantityValidation : QuantityStatus
    , netQuantityValidation : QuantityStatus
    , manuallySet : Bool
    , isFormValid : Bool
    , isStakeAmountModalOpened : Bool
    , stakeAmountModal : StakeAmountModal
    }


type PercentageOfLiquid
    = NoOp
    | Percentage10
    | Percentage50
    | Percentage70
    | Percentage100


type alias DistributionRatio =
    { cpu : Float
    , net : Float
    }


type alias StakeAmountModal =
    { totalQuantity : String
    , cpuQuantity : String
    , netQuantity : String
    , totalQuantityValidation : QuantityStatus
    , cpuQuantityValidation : QuantityStatus
    , netQuantityValidation : QuantityStatus
    , isFormValid : Bool
    }


initModel : Model
initModel =
    { delegatebw = { from = "", receiver = "", stakeNetQuantity = "", stakeCpuQuantity = "", transfer = 0 }
    , totalQuantity = ""
    , percentageOfLiquid = NoOp
    , distributionRatio = { cpu = 4, net = 1 }
    , totalQuantityValidation = EmptyQuantity
    , cpuQuantityValidation = EmptyQuantity
    , netQuantityValidation = EmptyQuantity
    , manuallySet = False
    , isFormValid = False
    , isStakeAmountModalOpened = False
    , stakeAmountModal =
        initStakeAmountModal
    }


initStakeAmountModal : StakeAmountModal
initStakeAmountModal =
    { totalQuantity = "0"
    , cpuQuantity = ""
    , netQuantity = ""
    , totalQuantityValidation = EmptyQuantity
    , cpuQuantityValidation = EmptyQuantity
    , netQuantityValidation = EmptyQuantity
    , isFormValid = False
    }



-- UPDATE


type Message
    = TotalAmountInput String
    | StakePercentage PercentageOfLiquid
    | OpenStakeAmountModal
    | SubmitAction
    | ModalMessage StakeAmountMessage


type StakeAmountMessage
    = CpuAmountInput String
    | NetAmountInput String
    | ClickOk
    | CloseModal


update : Message -> Model -> Account -> ( Model, Cmd Message )
update message ({ delegatebw, totalQuantity, distributionRatio, stakeAmountModal, isStakeAmountModalOpened } as model) ({ totalResources, selfDelegatedBandwidth, coreLiquidBalance, accountName } as account) =
    case message of
        TotalAmountInput value ->
            let
                ( cpuQuantity, netQuantity ) =
                    distributeCpuNet value distributionRatio.cpu distributionRatio.net

                newModel =
                    { model
                        | totalQuantity = value
                        , delegatebw =
                            { delegatebw | stakeCpuQuantity = cpuQuantity, stakeNetQuantity = netQuantity }
                        , percentageOfLiquid = NoOp
                        , manuallySet = False
                    }
            in
            ( validate newModel (assetToFloat coreLiquidBalance) isStakeAmountModalOpened
            , Cmd.none
            )

        StakePercentage percentageOfLiquid ->
            let
                ratio =
                    getPercentageOfLiquid percentageOfLiquid

                value =
                    assetToFloat coreLiquidBalance
                        * ratio
                        |> Round.round 4

                ( cpuQuantity, netQuantity ) =
                    distributeCpuNet value distributionRatio.cpu distributionRatio.net

                newModel =
                    { model
                        | totalQuantity = value
                        , delegatebw =
                            { delegatebw | stakeCpuQuantity = cpuQuantity, stakeNetQuantity = netQuantity }
                        , percentageOfLiquid = percentageOfLiquid
                        , manuallySet = False
                    }
            in
            ( validate newModel (assetToFloat coreLiquidBalance) isStakeAmountModalOpened
            , Cmd.none
            )

        OpenStakeAmountModal ->
            ( { model | isStakeAmountModalOpened = True }, Cmd.none )

        SubmitAction ->
            let
                cmd =
                    { delegatebw | from = accountName, receiver = accountName }
                        |> Action.Delegatebw
                        |> encodeAction
                        |> Port.pushAction
            in
            ( { model | delegatebw = { delegatebw | from = accountName, receiver = accountName } }, cmd )

        ModalMessage stakeAmountMessage ->
            case stakeAmountMessage of
                CpuAmountInput value ->
                    let
                        newTotalQuantity =
                            assetAdd value stakeAmountModal.netQuantity
                                |> assetToFloat
                                |> toString

                        newModel =
                            { model
                                | stakeAmountModal =
                                    { stakeAmountModal
                                        | totalQuantity = newTotalQuantity
                                        , cpuQuantity = value
                                    }
                            }
                    in
                    ( validate newModel (assetToFloat coreLiquidBalance) isStakeAmountModalOpened, Cmd.none )

                NetAmountInput value ->
                    let
                        newTotalQuantity =
                            assetAdd stakeAmountModal.cpuQuantity value
                                |> assetToFloat
                                |> toString

                        newModel =
                            { model
                                | stakeAmountModal =
                                    { stakeAmountModal
                                        | totalQuantity = newTotalQuantity
                                        , netQuantity = value
                                    }
                            }
                    in
                    ( validate newModel (assetToFloat coreLiquidBalance) isStakeAmountModalOpened, Cmd.none )

                ClickOk ->
                    ( { model
                        | delegatebw =
                            { delegatebw
                                | stakeCpuQuantity =
                                    stakeAmountModal.cpuQuantity
                                , stakeNetQuantity =
                                    stakeAmountModal.netQuantity
                            }
                        , percentageOfLiquid = NoOp
                        , totalQuantity = stakeAmountModal.totalQuantity
                        , totalQuantityValidation = stakeAmountModal.totalQuantityValidation
                        , cpuQuantityValidation = stakeAmountModal.cpuQuantityValidation
                        , netQuantityValidation = stakeAmountModal.netQuantityValidation
                        , manuallySet = True
                        , isFormValid = stakeAmountModal.isFormValid
                        , isStakeAmountModalOpened = False
                      }
                    , Cmd.none
                    )

                CloseModal ->
                    ( { model
                        | isStakeAmountModalOpened = False
                        , stakeAmountModal =
                            initStakeAmountModal
                      }
                    , Cmd.none
                    )



-- VIEW


view : Language -> Model -> Account -> Html Message
view language ({ delegatebw, totalQuantity, percentageOfLiquid, totalQuantityValidation, isStakeAmountModalOpened } as model) ({ totalResources, selfDelegatedBandwidth, coreLiquidBalance } as account) =
    let
        stakedAmount =
            floatToAsset (larimerToEos account.voterInfo.staked)

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
                            ++ assetSubtract
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
                            ++ assetSubtract
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
                , input
                    [ attribute "autofocus" ""
                    , class "size large"
                    , placeholder "수량을 입력하세요"
                    , step "0.0001"
                    , type_ "number"
                    , onInput TotalAmountInput
                    , value totalQuantity
                    ]
                    []
                , quantityWarningSpan totalQuantityValidation language model
                , percentageButton percentageOfLiquid Percentage10
                , percentageButton percentageOfLiquid Percentage50
                , percentageButton percentageOfLiquid Percentage70
                , percentageButton percentageOfLiquid Percentage100
                ]
            , div [ class "btn_area" ]
                [ button
                    [ class "ok button"
                    , attribute
                        (if model.isFormValid then
                            "no_op"

                         else
                            "disabled"
                        )
                        ""
                    , type_ "button"
                    , onClick SubmitAction
                    ]
                    [ text "확인" ]
                ]
            ]
        , Html.map ModalMessage (viewStakeAmountModal language model account isStakeAmountModalOpened)
        ]


viewStakeAmountModal : Language -> Model -> Account -> Bool -> Html StakeAmountMessage
viewStakeAmountModal language ({ distributionRatio, stakeAmountModal } as model) ({ totalResources } as account) opened =
    let
        cpuValidateAttr =
            modalValidateAttr stakeAmountModal.totalQuantityValidation stakeAmountModal.cpuQuantityValidation

        netValidateAttr =
            modalValidateAttr stakeAmountModal.totalQuantityValidation stakeAmountModal.netQuantityValidation
    in
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
                    [ text "총 스테이크할 토큰"
                    , strong []
                        [ text (stakeAmountModal.totalQuantity ++ " EOS") ]
                    ]
                , button [ class "set auto button", type_ "button" ]
                    [ text "자동 분배" ]
                ]
            , div [ class "form container" ]
                [ h3 []
                    [ text "CPU" ]
                , p []
                    [ text ("Staked : " ++ totalResources.cpuWeight) ]
                , Html.form [ action "", class "true validate" ]
                    [ input
                        [ class "user"
                        , attribute "data-validate" cpuValidateAttr
                        , placeholder "스테이크할 수량을 설정하세요"
                        , type_ "text"
                        , onInput CpuAmountInput
                        ]
                        []
                    , span []
                        [ text "EOS" ]
                    ]
                ]
            , div [ class "form container" ]
                [ h3 []
                    [ text "NET" ]
                , p []
                    [ text ("Staked : " ++ totalResources.netWeight) ]
                , Html.form [ action "" ]
                    [ input
                        [ class "user"
                        , attribute "data-validate" netValidateAttr
                        , placeholder "스테이크할 수량을 설정하세요"
                        , type_ "text"
                        , onInput NetAmountInput
                        ]
                        []
                    , span []
                        [ text "EOS" ]
                    ]
                ]
            , p [ class "validate description" ]
                [ text (toString distributionRatio.cpu ++ ":" ++ toString distributionRatio.net ++ " 비율로 스테이킹 하는 것이 가장 좋습니다.") ]
            , div [ class "btn_area" ]
                [ button [ class "undo button", type_ "button", onClick CloseModal ]
                    [ text "취소" ]
                , button
                    [ class "ok button"
                    , disabled (not stakeAmountModal.isFormValid)
                    , type_ "button"
                    , onClick ClickOk
                    ]
                    [ text "확인" ]
                ]
            ]
        ]


percentageButton : PercentageOfLiquid -> PercentageOfLiquid -> Html Message
percentageButton modelPercentageOfLiquid thisPercentageOfLiquid =
    let
        ratio =
            getPercentageOfLiquid thisPercentageOfLiquid

        buttonText =
            if ratio < 1 then
                Round.round 0 (ratio * 100) ++ "%"

            else
                "최대"
    in
    button
        [ type_ "button"
        , class
            (if modelPercentageOfLiquid == thisPercentageOfLiquid then
                "clicked"

             else
                ""
            )
        , onClick (StakePercentage thisPercentageOfLiquid)
        ]
        [ text buttonText ]


getPercentageOfLiquid : PercentageOfLiquid -> Float
getPercentageOfLiquid percentageOfLiquid =
    case percentageOfLiquid of
        Percentage10 ->
            0.1

        Percentage50 ->
            0.5

        Percentage70 ->
            0.7

        _ ->
            1


quantityWarningSpan : QuantityStatus -> Language -> Model -> Html Message
quantityWarningSpan quantityStatus language ({ delegatebw, manuallySet } as model) =
    let
        -- TODO(boseok): it needs to be translated
        manualText =
            if manuallySet then
                "직접설정"

            else
                "자동설정"

        ( classAddedValue, textValue ) =
            case quantityStatus of
                InvalidQuantity ->
                    ( " false", translate language InvalidAmount )

                OverValidQuantity ->
                    ( " false", translate language OverStakePossibleAmount )

                ValidQuantity ->
                    ( " true"
                    , manualText
                        ++ translate language
                            (StakePossible
                                delegatebw.stakeCpuQuantity
                                delegatebw.stakeNetQuantity
                            )
                    )

                EmptyQuantity ->
                    ( "", translate language StakePossibleAmountDesc )
    in
    span [ class ("validate description" ++ classAddedValue) ]
        [ text textValue ]


validate : Model -> Float -> Bool -> Model
validate ({ delegatebw, stakeAmountModal } as model) eosLiquidAmount isModal =
    let
        ( cpuQuantity, netQuantity ) =
            if not isModal then
                ( delegatebw.stakeNetQuantity, delegatebw.stakeCpuQuantity )

            else
                ( stakeAmountModal.cpuQuantity, stakeAmountModal.netQuantity )

        totalQuantity =
            assetAdd netQuantity cpuQuantity

        netQuantityValidation =
            validateQuantity netQuantity eosLiquidAmount

        cpuQuantityValidation =
            validateQuantity cpuQuantity eosLiquidAmount

        totalQuantityValidation =
            validateQuantity totalQuantity eosLiquidAmount

        isCpuValid =
            (cpuQuantityValidation == ValidQuantity) || (cpuQuantityValidation == EmptyQuantity)

        isNetValid =
            (netQuantityValidation == ValidQuantity) || (netQuantityValidation == EmptyQuantity)

        isFormValid =
            isCpuValid
                && isNetValid
                && (totalQuantityValidation == ValidQuantity)
    in
    if not isModal then
        { model
            | totalQuantityValidation = totalQuantityValidation
            , cpuQuantityValidation = cpuQuantityValidation
            , netQuantityValidation = netQuantityValidation
            , isFormValid = isFormValid
        }

    else
        { model
            | stakeAmountModal =
                { stakeAmountModal
                    | totalQuantityValidation = totalQuantityValidation
                    , cpuQuantityValidation = cpuQuantityValidation
                    , netQuantityValidation = netQuantityValidation
                    , isFormValid = isFormValid
                }
        }


distributeCpuNet : String -> Float -> Float -> ( String, String )
distributeCpuNet totalQuantity a b =
    let
        cpuQuantity =
            Round.round 4 <| assetToFloat totalQuantity * (a / (a + b))

        netQuantity =
            assetSubtract totalQuantity cpuQuantity
                |> removeSymbolIfExists
    in
    ( cpuQuantity, netQuantity )


modalValidateAttr : QuantityStatus -> QuantityStatus -> String
modalValidateAttr totalQuantityStatus resourceQuantityStatus =
    case resourceQuantityStatus of
        InvalidQuantity ->
            "false"

        OverValidQuantity ->
            "false"

        ValidQuantity ->
            if totalQuantityStatus == ValidQuantity then
                "true"

            else
                "false"

        EmptyQuantity ->
            ""
