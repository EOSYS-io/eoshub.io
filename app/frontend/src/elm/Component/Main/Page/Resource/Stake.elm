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

import Data.Account exposing (Account)
import Data.Action as Action exposing (DelegatebwParameters, encodeAction)
import Html exposing (Html, a, button, div, em, h2, h3, input, label, p, section, span, strong, text)
import Html.Attributes
    exposing
        ( action
        , attribute
        , class
        , disabled
        , for
        , id
        , placeholder
        , step
        , type_
        )
import Html.Events exposing (onClick, onInput)
import Port
import Round
import Translation exposing (I18n(..), Language, translate)
import Util.Formatter
    exposing
        ( assetAdd
        , assetSubtract
        , assetToFloat
        , numberWithinDigitLimit
        , removeSymbolIfExists
        )
import Util.Validation
    exposing
        ( AccountStatus(..)
        , MemoStatus(..)
        , QuantityStatus(..)
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
update message ({ delegatebw, distributionRatio, stakeAmountModal, isStakeAmountModalOpened } as model) { coreLiquidBalance, accountName } =
    case message of
        TotalAmountInput value ->
            if numberWithinDigitLimit 4 value then
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

            else
                ( model, Cmd.none )

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
                    if numberWithinDigitLimit 4 value then
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

                    else
                        ( model, Cmd.none )

                NetAmountInput value ->
                    if numberWithinDigitLimit 4 value then
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

                    else
                        ( model, Cmd.none )

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
view language ({ totalQuantity, percentageOfLiquid, totalQuantityValidation, isStakeAmountModalOpened } as model) { coreLiquidBalance } =
    div [ class "stake container" ]
        [ p []
            [ text (translate language StakeAvailableAmount)
            , em []
                [ text coreLiquidBalance ]
            ]
        , section []
            [ div [ class "wallet status" ]
                [ h3 []
                    [ text (translate language AutoAllocation) ]
                , a [ onClick OpenStakeAmountModal ]
                    [ text (translate language SetManually) ]
                ]
            , div [ class "input field" ]
                [ label [ for "eos" ]
                    [ text "EOS" ]
                , input
                    [ attribute "autofocus" ""
                    , class "size large"
                    , placeholder (translate language TypeStakeAmount)
                    , step "0.0001"
                    , type_ "number"
                    , onInput TotalAmountInput
                    , Html.Attributes.value totalQuantity
                    ]
                    []
                , quantityWarningSpan totalQuantityValidation language model
                , percentageButton language percentageOfLiquid Percentage10
                , percentageButton language percentageOfLiquid Percentage50
                , percentageButton language percentageOfLiquid Percentage70
                , percentageButton language percentageOfLiquid Percentage100
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
                    [ text (translate language Confirm) ]
                ]
            ]
        , Html.map ModalMessage (viewStakeAmountModal language model isStakeAmountModalOpened coreLiquidBalance)
        ]


viewStakeAmountModal : Language -> Model -> Bool -> String -> Html StakeAmountMessage
viewStakeAmountModal language { stakeAmountModal } opened coreLiquidBalance =
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
            [ div [ class "token status" ]
                [ h3 []
                    [ text (translate language StakeAvailableAmount)
                    , strong []
                        [ text ((coreLiquidBalance |> assetToFloat |> Round.round 4) ++ " EOS") ]
                    ]
                ]
            , div [ class "form container" ]
                [ h3 []
                    [ text "CPU" ]
                , Html.form [ action "", class "true validate" ]
                    [ input
                        [ class "user"
                        , attribute "data-validate" cpuValidateAttr
                        , placeholder (translate language TypeStakeAmount)
                        , type_ "text"
                        , onInput CpuAmountInput
                        , Html.Attributes.value stakeAmountModal.cpuQuantity
                        ]
                        []
                    , span []
                        [ text "EOS" ]
                    ]
                ]
            , div [ class "form container" ]
                [ h3 []
                    [ text "NET" ]
                , Html.form [ action "" ]
                    [ input
                        [ class "user"
                        , attribute "data-validate" netValidateAttr
                        , placeholder (translate language TypeStakeAmount)
                        , type_ "text"
                        , onInput NetAmountInput
                        , Html.Attributes.value stakeAmountModal.netQuantity
                        ]
                        []
                    , span []
                        [ text "EOS" ]
                    ]
                ]
            , p [] []
            , div [ class "btn_area" ]
                [ button [ class "undo button", type_ "button", onClick CloseModal ]
                    [ text (translate language Cancel) ]
                , button
                    [ class "ok button"
                    , disabled (not stakeAmountModal.isFormValid)
                    , type_ "button"
                    , onClick ClickOk
                    ]
                    [ text (translate language Confirm) ]
                ]
            ]
        ]


percentageButton : Language -> PercentageOfLiquid -> PercentageOfLiquid -> Html Message
percentageButton language modelPercentageOfLiquid thisPercentageOfLiquid =
    let
        ratio =
            getPercentageOfLiquid thisPercentageOfLiquid

        buttonText =
            if ratio < 1 then
                Round.round 0 (ratio * 100) ++ "%"

            else
                translate language Max
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
quantityWarningSpan quantityStatus language { delegatebw, manuallySet } =
    let
        ( classAddedValue, textValue ) =
            case quantityStatus of
                InvalidQuantity ->
                    ( " false", translate language InvalidInputAmount )

                OverValidQuantity ->
                    ( " false", translate language ExceedStakeAmount )

                ValidQuantity ->
                    ( " true"
                    , translate language
                        (AutoStakeAmountDesc
                            delegatebw.stakeCpuQuantity
                            delegatebw.stakeNetQuantity
                            manuallySet
                        )
                    )

                EmptyQuantity ->
                    ( "", translate language NeverExceedStakeAmount )
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
distributeCpuNet totalQuantity alpha beta =
    let
        cpuQuantity =
            Round.round 4 <| assetToFloat totalQuantity * (alpha / (alpha + beta))

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
