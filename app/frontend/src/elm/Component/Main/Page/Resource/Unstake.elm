module Component.Main.Page.Resource.Unstake exposing
    ( Message(..)
    , MinimumResource
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
import Data.Action as Action exposing (UndelegatebwParameters, encodeAction)
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
        )
import Util.Validation as Validation
    exposing
        ( AccountStatus(..)
        , QuantityStatus(..)
        , validateAccount
        , validateQuantity
        )



-- MODEL


type alias Model =
    { undelegatebw : UndelegatebwParameters
    , minimumResource : MinimumResource
    , percentageOfCpu : PercentageOfResource
    , percentageOfNet : PercentageOfResource
    , cpuQuantityValidation : QuantityStatus
    , netQuantityValidation : QuantityStatus
    , isFormValid : Bool
    }


type alias MinimumResource =
    { cpu : String, net : String }


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
    , minimumResource = { cpu = "0.8 EOS", net = "0.2 EOS" }
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
update message ({ undelegatebw, minimumResource } as model) ({ accountName, totalResources, selfDelegatedBandwidth, coreLiquidBalance } as account) =
    let
        unstakePossibleCpu =
            getUnstakePossibleResource selfDelegatedBandwidth.cpuWeight minimumResource.cpu

        unstakePossibleNet =
            getUnstakePossibleResource selfDelegatedBandwidth.netWeight minimumResource.net
    in
    case message of
        CpuAmountInput value ->
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

        NetAmountInput value ->
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
                        |> encodeAction
                        |> Port.pushAction
            in
            ( { model | undelegatebw = { undelegatebw | from = accountName, receiver = accountName } }, cmd )



-- VIEW


view : Language -> Model -> Account -> Html Message
view language ({ cpuQuantityValidation, netQuantityValidation, minimumResource, percentageOfCpu, percentageOfNet, undelegatebw, isFormValid } as model) ({ totalResources, selfDelegatedBandwidth, coreLiquidBalance } as account) =
    let
        unstakedAmount =
            floatToAsset (larimerToEos account.voterInfo.staked)

        unstakePossibleAmount =
            assetAdd selfDelegatedBandwidth.cpuWeight selfDelegatedBandwidth.netWeight

        unstakePossibleCpu =
            getUnstakePossibleResource selfDelegatedBandwidth.cpuWeight minimumResource.cpu

        unstakePossibleNet =
            getUnstakePossibleResource selfDelegatedBandwidth.netWeight minimumResource.net

        ( _, _, _, cpuPercent, cpuColor ) =
            getResource "cpu" account.cpuLimit.used account.cpuLimit.available account.cpuLimit.max

        ( _, _, _, netPercent, netColor ) =
            getResource "net" account.netLimit.used account.netLimit.available account.netLimit.max

        ( validatedText, validatedAttr ) =
            validateText model

        cpuValidateAttr =
            validateAttr cpuQuantityValidation

        netValidateAttr =
            validateAttr netQuantityValidation
    in
    div [ class "unstake container" ]
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
                    [ text ("임대받은 토큰 : " ++ assetSubtract totalResources.cpuWeight selfDelegatedBandwidth.cpuWeight) ]
                , div [ class "graph status" ]
                    [ span [ class cpuColor, style [ ( "height", cpuPercent ) ] ]
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
                    [ text ("임대받은 토큰 : " ++ assetSubtract totalResources.netWeight selfDelegatedBandwidth.netWeight) ]
                , div [ class "graph status" ]
                    [ span [ class netColor, style [ ( "height", netPercent ) ] ]
                        []
                    , text netPercent
                    ]
                ]
            ]
        , section []
            [ div [ class "wallet status" ]
                [ h3 []
                    [ text "언스테이크 가능한 CPU" ]
                , p []
                    [ text unstakePossibleCpu ]
                , h3 []
                    [ text "언스테이크 가능한 NET" ]
                , p []
                    [ text unstakePossibleNet ]
                , p [ class ("validate description" ++ validatedAttr) ]
                    [ text validatedText ]
                ]
            , div [ class "field group" ]
                [ div [ class "input field" ]
                    [ label [ for "cpu" ]
                        [ text "CPU" ]
                    , input
                        [ attribute "data-validate" cpuValidateAttr
                        , placeholder "CPU 언스테이크 할 수량 입력"
                        , step "0.0001"
                        , type_ "number"
                        , onInput CpuAmountInput
                        , value undelegatebw.unstakeCpuQuantity
                        ]
                        []
                    , span [ class "unit" ]
                        [ text "EOS" ]
                    , percentageButton Cpu percentageOfCpu Percentage10
                    , percentageButton Cpu percentageOfCpu Percentage50
                    , percentageButton Cpu percentageOfCpu Percentage70
                    , percentageButton Cpu percentageOfCpu Percentage100
                    ]
                , div [ class "input field" ]
                    [ label [ for "net" ]
                        [ text "NET" ]
                    , input
                        [ attribute "data-validate" netValidateAttr
                        , placeholder "NET 언스테이크할 수량 입력"
                        , step "0.0001"
                        , type_ "number"
                        , onInput NetAmountInput
                        , value undelegatebw.unstakeNetQuantity
                        ]
                        []
                    , span [ class "unit" ]
                        [ text "EOS" ]
                    , percentageButton Net percentageOfNet Percentage10
                    , percentageButton Net percentageOfNet Percentage50
                    , percentageButton Net percentageOfNet Percentage70
                    , percentageButton Net percentageOfNet Percentage100
                    ]
                ]
            , div [ class "btn_area" ]
                [ button
                    [ class "ok button"
                    , disabled (not isFormValid)
                    , type_ "button"
                    , onClick SubmitAction
                    ]
                    [ text "확인" ]
                ]
            ]
        ]


percentageButton : ResourceType -> PercentageOfResource -> PercentageOfResource -> Html Message
percentageButton resourceType modelPercentageOfResource thisPercentageOfResource =
    let
        ratio =
            getPercentageOfResource thisPercentageOfResource

        buttonText =
            if ratio < 1 then
                Round.round 0 (ratio * 100) ++ "%"

            else
                "최대"
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
            assetSubtract selfDelegatedAmount minimum
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


validateText : Model -> ( String, String )
validateText ({ cpuQuantityValidation, netQuantityValidation, minimumResource } as model) =
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
        ( "언스테이크 가능합니다 :)", " true" )

    else if isNotEmptyBoth then
        if not isCpuValid && not isNetValid then
            ( "CPU, NET의 수량입력이 잘못되었습니다", " false" )

        else if not isCpuValid then
            ( "CPU의 수량입력이 잘못되었습니다", " false" )

        else if not isNetValid then
            ( "NET의 수량입력이 잘못되었습니다", " false" )

        else
            ( "발생 불가 케이스", "" )

    else
        ( "CPU는 최소 " ++ minimumResource.cpu ++ ", NET은 최소 " ++ minimumResource.net ++ " 이상 스테이크 하세요.", "" )


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
