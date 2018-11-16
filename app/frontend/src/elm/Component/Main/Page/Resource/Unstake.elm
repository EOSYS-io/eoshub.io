module Component.Main.Page.Resource.Unstake exposing
    ( Message(..)
    , Model
    , PercentageOfResource(..)
    , ResourceType(..)
    , getPercentageOfResource
    , getUnstakePossibleResource
    , initModel
    , percentageButton
    , update
    , validate
    , validateAttr
    , validateText
    , view
    )

import Data.Account exposing (Account)
import Data.Action as Action exposing (UndelegatebwParameters, encodeActions)
import Html exposing (Html, button, div, h3, input, label, p, section, span, strong, text)
import Html.Attributes exposing (attribute, class, disabled, for, placeholder, step, type_)
import Html.Events exposing (onClick, onInput)
import Port
import Round
import Translation exposing (I18n(..), Language, translate)
import Util.Constant exposing (minimumRequiredResources)
import Util.Formatter
    exposing
        ( assetToFloat
        , eosSubtract
        , numberWithinDigitLimit
        )
import Util.Validation
    exposing
        ( AccountStatus(..)
        , QuantityStatus(..)
        , validateQuantity
        )



-- MODEL


type alias Model =
    { undelegatebw : UndelegatebwParameters
    , percentageOfCpu : PercentageOfResource
    , percentageOfNet : PercentageOfResource
    , cpuQuantityValidation : QuantityStatus
    , netQuantityValidation : QuantityStatus
    , isFormValid : Bool
    }


type PercentageOfResource
    = NoOp
    | Percentage10
    | Percentage50
    | Percentage70
    | Percentage100


type ResourceType
    = Cpu
    | Net


initModel : Model
initModel =
    { undelegatebw = { from = "", receiver = "", unstakeNetQuantity = "", unstakeCpuQuantity = "" }
    , percentageOfCpu = NoOp
    , percentageOfNet = NoOp
    , cpuQuantityValidation = EmptyQuantity
    , netQuantityValidation = EmptyQuantity
    , isFormValid = False
    }



-- UPDATE


type Message
    = CpuAmountInput String
    | ClickCpuPercentage PercentageOfResource
    | ClickNetPercentage PercentageOfResource
    | NetAmountInput String
    | SubmitAction


update : Message -> Model -> Account -> ( Model, Cmd Message )
update message ({ undelegatebw } as model) { accountName, selfDelegatedBandwidth } =
    let
        unstakePossibleCpu =
            getUnstakePossibleResource selfDelegatedBandwidth.cpuWeight minimumRequiredResources.cpu

        unstakePossibleNet =
            getUnstakePossibleResource selfDelegatedBandwidth.netWeight minimumRequiredResources.net
    in
    case message of
        CpuAmountInput value ->
            if numberWithinDigitLimit 4 value then
                let
                    newModel =
                        { model
                            | undelegatebw =
                                { undelegatebw
                                    | unstakeCpuQuantity = value
                                }
                            , percentageOfCpu = NoOp
                        }
                in
                ( validate newModel unstakePossibleCpu unstakePossibleNet, Cmd.none )

            else
                ( model, Cmd.none )

        NetAmountInput value ->
            if numberWithinDigitLimit 4 value then
                let
                    newModel =
                        { model
                            | undelegatebw =
                                { undelegatebw
                                    | unstakeNetQuantity = value
                                }
                            , percentageOfNet = NoOp
                        }
                in
                ( validate newModel unstakePossibleCpu unstakePossibleNet, Cmd.none )

            else
                ( model, Cmd.none )

        ClickCpuPercentage percentageOfResource ->
            let
                ratio =
                    getPercentageOfResource percentageOfResource

                value =
                    assetToFloat unstakePossibleCpu
                        * ratio
                        |> Round.round 4

                newModel =
                    { model
                        | undelegatebw =
                            { undelegatebw
                                | unstakeCpuQuantity = value
                            }
                        , percentageOfCpu = percentageOfResource
                    }
            in
            ( validate newModel unstakePossibleCpu unstakePossibleNet, Cmd.none )

        ClickNetPercentage percentageOfResource ->
            let
                ratio =
                    getPercentageOfResource percentageOfResource

                value =
                    assetToFloat unstakePossibleNet
                        * ratio
                        |> Round.round 4

                newModel =
                    { model
                        | undelegatebw =
                            { undelegatebw
                                | unstakeNetQuantity = value
                            }
                        , percentageOfNet = percentageOfResource
                    }
            in
            ( validate newModel unstakePossibleCpu unstakePossibleNet, Cmd.none )

        SubmitAction ->
            let
                cmd =
                    { undelegatebw | from = accountName, receiver = accountName }
                        |> Action.Undelegatebw
                        |> List.singleton
                        |> encodeActions "undelegatebw"
                        |> Port.pushAction
            in
            ( { model | undelegatebw = { undelegatebw | from = accountName, receiver = accountName } }, cmd )



-- VIEW


view : Language -> Model -> Account -> Html Message
view language ({ cpuQuantityValidation, netQuantityValidation, percentageOfCpu, percentageOfNet, undelegatebw, isFormValid } as model) { selfDelegatedBandwidth } =
    let
        ( validatedText, validatedAttr ) =
            validateText language model

        cpuValidateAttr =
            validateAttr cpuQuantityValidation

        netValidateAttr =
            validateAttr netQuantityValidation
    in
    div [ class "unstake container" ]
        [ div [ class "my resource" ]
            [ div []
                [ h3 []
                    [ text "CPU self-staked"
                    , strong []
                        [ text selfDelegatedBandwidth.cpuWeight ]
                    ]
                ]
            , div []
                [ h3 []
                    [ text "NET self-staked"
                    , strong []
                        [ text selfDelegatedBandwidth.netWeight ]
                    ]
                ]
            ]
        , section []
            -- NOTE(boseok): new design is needed
            [ h3 []
                [ text (translate language (RecommendedStakeAmount minimumRequiredResources.cpu minimumRequiredResources.net)) ]
            , p [ class ("validate description" ++ validatedAttr) ]
                [ text validatedText ]
            , div [ class "field group" ]
                [ div [ class "input field" ]
                    [ label [ for "cpu" ]
                        [ text "CPU" ]
                    , input
                        [ attribute "data-validate" cpuValidateAttr
                        , placeholder (translate language TypeUnstakeAmount)
                        , step "0.0001"
                        , type_ "number"
                        , onInput CpuAmountInput
                        , Html.Attributes.value undelegatebw.unstakeCpuQuantity
                        ]
                        []
                    , span [ class "unit" ]
                        [ text "EOS" ]
                    , percentageButton language Cpu percentageOfCpu Percentage10
                    , percentageButton language Cpu percentageOfCpu Percentage50
                    , percentageButton language Cpu percentageOfCpu Percentage70
                    , percentageButton language Cpu percentageOfCpu Percentage100
                    ]
                , div [ class "input field" ]
                    [ label [ for "net" ]
                        [ text "NET" ]
                    , input
                        [ attribute "data-validate" netValidateAttr
                        , placeholder (translate language TypeUnstakeAmount)
                        , step "0.0001"
                        , type_ "number"
                        , onInput NetAmountInput
                        , Html.Attributes.value undelegatebw.unstakeNetQuantity
                        ]
                        []
                    , span [ class "unit" ]
                        [ text "EOS" ]
                    , percentageButton language Net percentageOfNet Percentage10
                    , percentageButton language Net percentageOfNet Percentage50
                    , percentageButton language Net percentageOfNet Percentage70
                    , percentageButton language Net percentageOfNet Percentage100
                    ]
                ]
            , div [ class "btn_area" ]
                [ button
                    [ class "ok button"
                    , disabled (not isFormValid)
                    , type_ "button"
                    , onClick SubmitAction
                    ]
                    [ text (translate language Confirm) ]
                ]
            ]
        ]


percentageButton : Language -> ResourceType -> PercentageOfResource -> PercentageOfResource -> Html Message
percentageButton language resourceType modelPercentageOfResource thisPercentageOfResource =
    let
        ratio =
            getPercentageOfResource thisPercentageOfResource

        buttonText =
            if ratio < 1 then
                Round.round 0 (ratio * 100) ++ "%"

            else
                translate language Max
    in
    button
        [ type_ "button"
        , class
            (if modelPercentageOfResource == thisPercentageOfResource then
                "clicked"

             else
                ""
            )
        , onClick
            (case resourceType of
                Cpu ->
                    ClickCpuPercentage thisPercentageOfResource

                Net ->
                    ClickNetPercentage thisPercentageOfResource
            )
        ]
        [ text buttonText ]


getUnstakePossibleResource : String -> String -> String
getUnstakePossibleResource selfDelegatedAmount minimum =
    let
        subtractResult =
            eosSubtract selfDelegatedAmount minimum
    in
    if (subtractResult |> assetToFloat) >= 0 then
        subtractResult

    else
        "0 EOS"


validate : Model -> String -> String -> Model
validate ({ undelegatebw } as model) unstakePossibleCpu unstakePossibleNet =
    let
        netQuantityValidation =
            validateQuantity undelegatebw.unstakeNetQuantity (assetToFloat unstakePossibleNet)

        cpuQuantityValidation =
            validateQuantity undelegatebw.unstakeCpuQuantity (assetToFloat unstakePossibleCpu)

        isCpuValid =
            (cpuQuantityValidation == ValidQuantity) || (cpuQuantityValidation == EmptyQuantity)

        isNetValid =
            (netQuantityValidation == ValidQuantity) || (netQuantityValidation == EmptyQuantity)

        isNotEmptyBoth =
            not ((cpuQuantityValidation == EmptyQuantity) && (netQuantityValidation == EmptyQuantity))

        isFormValid =
            isCpuValid
                && isNetValid
                && isNotEmptyBoth
    in
    { model
        | cpuQuantityValidation = cpuQuantityValidation
        , netQuantityValidation = netQuantityValidation
        , isFormValid = isFormValid
    }


validateAttr : QuantityStatus -> String
validateAttr resourceQuantityStatus =
    case resourceQuantityStatus of
        InvalidQuantity ->
            "false"

        OverValidQuantity ->
            "false"

        ValidQuantity ->
            "true"

        EmptyQuantity ->
            ""


validateText : Language -> Model -> ( String, String )
validateText language { cpuQuantityValidation, netQuantityValidation } =
    let
        isCpuValid =
            (cpuQuantityValidation == ValidQuantity) || (cpuQuantityValidation == EmptyQuantity)

        isNetValid =
            (netQuantityValidation == ValidQuantity) || (netQuantityValidation == EmptyQuantity)

        isNotEmptyBoth =
            not ((cpuQuantityValidation == EmptyQuantity) && (netQuantityValidation == EmptyQuantity))

        isFormValid =
            isCpuValid
                && isNetValid
                && isNotEmptyBoth
    in
    if isFormValid then
        ( translate language UnstakePossible, " true" )

    else if isNotEmptyBoth then
        if not isCpuValid then
            case cpuQuantityValidation of
                InvalidQuantity ->
                    ( translate language (InvalidQuantityInput "CPU"), " false" )

                OverValidQuantity ->
                    ( translate language (OverValidQuantityInput "CPU"), " false" )

                _ ->
                    ( "This case should not happen!", "" )

        else if not isNetValid then
            case netQuantityValidation of
                InvalidQuantity ->
                    ( translate language (InvalidQuantityInput "NET"), " false" )

                OverValidQuantity ->
                    ( translate language (OverValidQuantityInput "NET"), " false" )

                _ ->
                    ( "This case should not happen!", "" )

        else
            ( "This case should not happen!", "" )

    else
        ( "", "" )


getPercentageOfResource : PercentageOfResource -> Float
getPercentageOfResource percentageOfResource =
    case percentageOfResource of
        Percentage10 ->
            0.1

        Percentage50 ->
            0.5

        Percentage70 ->
            0.7

        _ ->
            1
