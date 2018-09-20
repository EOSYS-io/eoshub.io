module Component.Main.Page.Resource.Delegate exposing
    ( Message(..)
    , Model
    , PercentageOfResource(..)
    , ResourceType(..)
    , getPercentageOfResource
    , initModel
    , percentageButton
    , update
    , validate
    , validateText
    , view
    )

import Component.Main.Page.Resource.Modal.DelegateList as DelegateList
    exposing
        ( Message(..)
        , viewDelegateListModal
        )
import Component.Main.Page.Resource.Stake exposing (modalValidateAttr)
import Component.Main.Page.Transfer exposing (accountWarningSpan)
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
import Html.Events exposing (..)
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
    , percentageOfCpu : PercentageOfResource
    , percentageOfNet : PercentageOfResource
    , totalQuantityValidation : QuantityStatus
    , cpuQuantityValidation : QuantityStatus
    , netQuantityValidation : QuantityStatus
    , accountValidation : AccountStatus
    , isFormValid : Bool
    , delegateListModal : DelegateList.Model
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
    { delegatebw = { from = "", receiver = "", stakeNetQuantity = "", stakeCpuQuantity = "", transfer = 0 }
    , totalQuantity = ""
    , percentageOfCpu = NoOp
    , percentageOfNet = NoOp
    , totalQuantityValidation = EmptyQuantity
    , cpuQuantityValidation = EmptyQuantity
    , netQuantityValidation = EmptyQuantity
    , accountValidation = EmptyAccount
    , isFormValid = False
    , delegateListModal = DelegateList.initModel
    }



-- UPDATE


type Message
    = OpenDelegateListModal
    | CpuAmountInput String
    | NetAmountInput String
    | ReceiverInput String
    | ClickCpuPercentage PercentageOfResource
    | ClickNetPercentage PercentageOfResource
    | SubmitAction
    | DelegateListMessage DelegateList.Message


update : Message -> Model -> Account -> ( Model, Cmd Message )
update message ({ delegatebw, delegateListModal } as model) ({ totalResources, selfDelegatedBandwidth, coreLiquidBalance, accountName } as account) =
    let
        eosLiquidAmount =
            assetToFloat coreLiquidBalance
    in
    case message of
        CpuAmountInput value ->
            let
                total =
                    assetAdd value delegatebw.stakeNetQuantity

                newModel =
                    { model
                        | delegatebw =
                            { delegatebw
                                | stakeCpuQuantity = value
                            }
                        , percentageOfCpu = NoOp
                        , totalQuantity = total
                    }
            in
            ( validate newModel eosLiquidAmount, Cmd.none )

        NetAmountInput value ->
            let
                total =
                    assetAdd delegatebw.stakeCpuQuantity value

                newModel =
                    { model
                        | delegatebw =
                            { delegatebw
                                | stakeNetQuantity = value
                            }
                        , percentageOfNet = NoOp
                        , totalQuantity = total
                    }
            in
            ( validate newModel eosLiquidAmount, Cmd.none )

        ReceiverInput value ->
            let
                newModel =
                    { model
                        | delegatebw =
                            { delegatebw
                                | receiver = value
                            }
                    }
            in
            ( validate newModel eosLiquidAmount, Cmd.none )

        ClickCpuPercentage percentageOfResource ->
            let
                ratio =
                    getPercentageOfResource percentageOfResource

                value =
                    assetToFloat coreLiquidBalance
                        * ratio
                        |> Round.round 4

                total =
                    assetAdd value delegatebw.stakeNetQuantity

                newModel =
                    { model
                        | delegatebw =
                            { delegatebw
                                | stakeCpuQuantity = value
                            }
                        , totalQuantity = total
                        , percentageOfCpu = percentageOfResource
                    }
            in
            ( validate newModel eosLiquidAmount, Cmd.none )

        ClickNetPercentage percentageOfResource ->
            let
                ratio =
                    getPercentageOfResource percentageOfResource

                value =
                    assetToFloat coreLiquidBalance
                        * ratio
                        |> Round.round 4

                total =
                    assetAdd delegatebw.stakeCpuQuantity value

                newModel =
                    { model
                        | delegatebw =
                            { delegatebw
                                | stakeNetQuantity = value
                            }
                        , totalQuantity = total
                        , percentageOfNet = percentageOfResource
                    }
            in
            ( validate newModel eosLiquidAmount, Cmd.none )

        SubmitAction ->
            let
                cmd =
                    { delegatebw | from = accountName }
                        |> Action.Delegatebw
                        |> encodeAction
                        |> Port.pushAction
            in
            ( { model | delegatebw = { delegatebw | from = accountName } }, cmd )

        OpenDelegateListModal ->
            ( { model
                | delegateListModal =
                    { delegateListModal
                        | isDelegateListModalOpened = True
                    }
              }
            , Cmd.none
            )

        DelegateListMessage subMessage ->
            let
                ( newModel, _ ) =
                    DelegateList.update subMessage delegateListModal
            in
            ( { model | delegateListModal = newModel }, Cmd.none )



-- VIEW


view : Language -> Model -> Account -> Html Message
view language ({ delegatebw, cpuQuantityValidation, netQuantityValidation, accountValidation, totalQuantityValidation, totalQuantity, percentageOfCpu, percentageOfNet, isFormValid, delegateListModal } as model) ({ totalResources, selfDelegatedBandwidth, coreLiquidBalance } as account) =
    let
        accountWarning =
            accountWarningSpan accountValidation language

        ( validatedText, validatedAttr ) =
            validateText model

        cpuValidateAttr =
            modalValidateAttr totalQuantityValidation cpuQuantityValidation

        netValidateAttr =
            modalValidateAttr totalQuantityValidation netQuantityValidation

        modalHtml =
            Html.map DelegateListMessage (viewDelegateListModal language delegateListModal)
    in
    div [ class "rental cancel container" ]
        [ div [ class "available status" ]
            [ h3 []
                [ text "임대가능 토큰수량"
                , strong []
                    [ text coreLiquidBalance ]
                ]
            , a [ id "viewRentalListAccount", onClick OpenDelegateListModal ]
                [ text "임대해준 계정 리스트 보기" ]
            ]
        , section []
            [ div [ class "input field" ]
                [ input
                    [ attribute "autofocus" ""
                    , class "size large"
                    , placeholder "임대해줄 계정의 이름을 입력하세요"
                    , onInput ReceiverInput
                    , type_ "text"
                    ]
                    []
                , accountWarning
                ]
            ]
        , section []
            [ div [ class "wallet status" ]
                [ h3 []
                    [ text "임대해 줄 토큰 총량" ]
                , p []
                    [ text totalQuantity ]
                , p [ class ("validate description" ++ validatedAttr) ]
                    [ text validatedText ]
                ]
            , div [ class "field group" ]
                [ resourceInputDiv model Cpu
                , resourceInputDiv model Net
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
        , modalHtml
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


resourceInputDiv : Model -> ResourceType -> Html Message
resourceInputDiv ({ delegatebw, percentageOfCpu, percentageOfNet, totalQuantityValidation, cpuQuantityValidation, netQuantityValidation } as model) resourceType =
    let
        cpuValidateAttr =
            modalValidateAttr totalQuantityValidation cpuQuantityValidation

        netValidateAttr =
            modalValidateAttr totalQuantityValidation netQuantityValidation

        ( resourceText, validateAttr, inputMessage, resourceQuantity, percentageOfResource ) =
            case resourceType of
                Cpu ->
                    ( "CPU", cpuValidateAttr, CpuAmountInput, delegatebw.stakeCpuQuantity, percentageOfCpu )

                Net ->
                    ( "NET", netValidateAttr, NetAmountInput, delegatebw.stakeNetQuantity, percentageOfNet )
    in
    div [ class "input field" ]
        [ label [ for resourceText ]
            [ text resourceText ]
        , input
            [ attribute "data-validate" validateAttr
            , placeholder "0"
            , step "0.0001"
            , type_ "number"
            , onInput inputMessage
            , value resourceQuantity
            ]
            []
        , span [ class "unit" ]
            [ text "EOS" ]
        , percentageButton resourceType percentageOfResource Percentage10
        , percentageButton resourceType percentageOfResource Percentage50
        , percentageButton resourceType percentageOfResource Percentage70
        , percentageButton resourceType percentageOfResource Percentage100
        ]


validateEach : AccountStatus -> QuantityStatus -> QuantityStatus -> QuantityStatus -> ( Bool, Bool, Bool, Bool, Bool )
validateEach accountValidation cpuQuantityValidation netQuantityValidation totalQuantityValidation =
    let
        isAccountValid =
            accountValidation == ValidAccount

        isNotEmptyBoth =
            not ((cpuQuantityValidation == EmptyQuantity) && (netQuantityValidation == EmptyQuantity))

        isCpuValid =
            (cpuQuantityValidation == ValidQuantity) || (cpuQuantityValidation == EmptyQuantity)

        isNetValid =
            (netQuantityValidation == ValidQuantity) || (netQuantityValidation == EmptyQuantity)

        isTotalValid =
            totalQuantityValidation == ValidQuantity
    in
    ( isAccountValid, isNotEmptyBoth, isCpuValid, isNetValid, isTotalValid )


validate : Model -> Float -> Model
validate ({ delegatebw, totalQuantity } as model) eosLiquidAmount =
    let
        accountValidation =
            validateAccount delegatebw.receiver

        cpuQuantityValidation =
            validateQuantity delegatebw.stakeCpuQuantity eosLiquidAmount

        netQuantityValidation =
            validateQuantity delegatebw.stakeNetQuantity eosLiquidAmount

        totalQuantityValidation =
            validateQuantity totalQuantity eosLiquidAmount

        ( isAccountValid, isNotEmptyBoth, isCpuValid, isNetValid, isTotalValid ) =
            validateEach accountValidation cpuQuantityValidation netQuantityValidation totalQuantityValidation

        isFormValid =
            isCpuValid
                && isNetValid
                && isNotEmptyBoth
                && isTotalValid
                && isAccountValid
    in
    { model
        | totalQuantityValidation = totalQuantityValidation
        , cpuQuantityValidation = cpuQuantityValidation
        , netQuantityValidation = netQuantityValidation
        , accountValidation = accountValidation
        , isFormValid = isFormValid
    }


validateText : Model -> ( String, String )
validateText ({ cpuQuantityValidation, netQuantityValidation, totalQuantityValidation, accountValidation } as model) =
    let
        ( isAccountValid, isNotEmptyBoth, isCpuValid, isNetValid, isTotalValid ) =
            validateEach accountValidation cpuQuantityValidation netQuantityValidation totalQuantityValidation

        isFormValid =
            isAccountValid
                && isCpuValid
                && isNetValid
                && isNotEmptyBoth
                && isTotalValid
    in
    if isFormValid then
        ( "임대 가능합니다 :)", " true" )

    else if isNotEmptyBoth then
        if not isCpuValid && not isNetValid then
            ( "CPU, NET의 수량입력이 잘못되었습니다", " false" )

        else if not isCpuValid then
            ( "CPU의 수량입력이 잘못되었습니다", " false" )

        else if not isNetValid then
            ( "NET의 수량입력이 잘못되었습니다", " false" )

        else if not isTotalValid then
            ( "임대가능 토큰수량을 초과하였습니다", " false" )

        else
            ( "임대해줄 계정을 입력하세요", " false" )

    else
        ( "임대가능한 토큰 수만큼 임대가 가능합니다", "" )



-- TODO(boseok): gather similar functions in a separate module


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
