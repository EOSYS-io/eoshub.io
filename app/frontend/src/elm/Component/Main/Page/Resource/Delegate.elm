module Component.Main.Page.Resource.Delegate exposing
    ( Message(..)
    , Model
    , PercentageOfResource(..)
    , ResourceType(..)
    , getPercentageOfResource
    , initCmd
    , initModel
    , percentageButton
    , resourceInputDiv
    , update
    , validateEach
    , validateForm
    , validateQuantityFields
    , validateReceiverField
    , validateText
    , view
    )

import Component.Main.Page.Resource.Modal.DelegateList as DelegateList
    exposing
        ( Message(..)
        )
import Component.Main.Page.Resource.Stake exposing (modalValidateAttr)
import Component.Main.Page.Transfer exposing (accountWarningSpan)
import Data.Account exposing (Account)
import Data.Action as Action exposing (DelegatebwParameters, encodeAction)
import Data.Table exposing (Row)
import Html exposing (Html, a, button, div, h3, input, label, p, section, span, strong, text)
import Html.Attributes exposing (attribute, class, disabled, for, id, placeholder, step, type_)
import Html.Events exposing (onClick, onInput)
import Http
import Port
import Round
import Translation exposing (I18n(..), Language)
import Util.Formatter
    exposing
        ( assetAdd
        , assetToFloat
        )
import Util.HttpRequest exposing (getAccount, getTableRows)
import Util.Validation as Validation
    exposing
        ( AccountStatus(..)
        , MemoStatus(..)
        , QuantityStatus(..)
        , VerificationRequestStatus
        , validateAccount
        , validateQuantity
        )



-- MODEL


type alias Model =
    { delegatebw : DelegatebwParameters
    , delbandTable : List Row
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
    , delbandTable = []
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



-- CMD


initCmd : String -> Cmd Message
initCmd query =
    getTableRows "eosio" query "delband"
        |> Http.send OnFetchTableRows



-- UPDATE


type Message
    = OnFetchTableRows (Result Http.Error (List Row))
    | OnFetchAccountToVerify (Result Http.Error Account)
    | CpuAmountInput String
    | NetAmountInput String
    | ReceiverInput String
    | ClickCpuPercentage PercentageOfResource
    | ClickNetPercentage PercentageOfResource
    | SubmitAction
    | OpenDelegateListModal
    | DelegateListMessage DelegateList.Message


update : Message -> Model -> Account -> ( Model, Cmd Message )
update message ({ delegatebw, delegateListModal } as model) { coreLiquidBalance, accountName } =
    let
        eosLiquidAmount =
            assetToFloat coreLiquidBalance
    in
    case message of
        OnFetchTableRows (Ok rows) ->
            ( { model | delbandTable = rows }, Cmd.none )

        OnFetchTableRows (Err _) ->
            ( model, Cmd.none )

        OnFetchAccountToVerify (Ok _) ->
            validateReceiverField model Validation.Succeed

        OnFetchAccountToVerify (Err _) ->
            validateReceiverField model Validation.Fail

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
            ( validateQuantityFields newModel eosLiquidAmount, Cmd.none )

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
            ( validateQuantityFields newModel eosLiquidAmount, Cmd.none )

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
            validateReceiverField newModel Validation.NotSent

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
            ( validateQuantityFields newModel eosLiquidAmount, Cmd.none )

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
            ( validateQuantityFields newModel eosLiquidAmount, Cmd.none )

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
            case subMessage of
                ClickDelband receiver _ _ ->
                    let
                        newModel =
                            { model
                                | delegatebw =
                                    { delegatebw
                                        | receiver = receiver
                                    }
                                , delegateListModal =
                                    { delegateListModal
                                        | isDelegateListModalOpened = False
                                    }
                            }
                    in
                    validateReceiverField newModel Validation.NotSent

                _ ->
                    let
                        ( newModel, _ ) =
                            DelegateList.update subMessage delegateListModal
                    in
                    ( { model | delegateListModal = newModel }, Cmd.none )



-- VIEW


view : Language -> Model -> Account -> Html Message
view language ({ delegatebw, delbandTable, accountValidation, totalQuantity, isFormValid, delegateListModal } as model) { accountName, coreLiquidBalance } =
    let
        accountWarning =
            accountWarningSpan accountValidation language

        ( validatedText, validatedAttr ) =
            validateText model

        modalHtml =
            Html.map DelegateListMessage (DelegateList.view language delegateListModal delbandTable accountName)
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
                    , attribute "maxlength" "12"
                    , Html.Attributes.value delegatebw.receiver
                    ]
                    []
                , accountWarning
                ]
            ]
        , section []
            [ h3 []
                [ text "임대해 줄 토큰 총량" ]
            , p []
                [ text totalQuantity ]
            , p [ class ("validate description" ++ validatedAttr) ]
                [ text validatedText ]
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
resourceInputDiv { delegatebw, percentageOfCpu, percentageOfNet, totalQuantityValidation, cpuQuantityValidation, netQuantityValidation } resourceType =
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
            , Html.Attributes.value resourceQuantity
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


validateForm : Model -> Model
validateForm ({ accountValidation, cpuQuantityValidation, netQuantityValidation, totalQuantityValidation } as model) =
    let
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


validateReceiverField : Model -> VerificationRequestStatus -> ( Model, Cmd Message )
validateReceiverField ({ delegatebw } as model) requestStatus =
    let
        accountValidation =
            validateAccount delegatebw.receiver requestStatus

        accountCmd =
            if accountValidation == AccountToBeVerified then
                delegatebw.receiver
                    |> getAccount
                    |> Http.send OnFetchAccountToVerify

            else
                Cmd.none
    in
    ( validateForm { model | accountValidation = accountValidation }, accountCmd )


validateQuantityFields : Model -> Float -> Model
validateQuantityFields ({ delegatebw, totalQuantity } as model) eosLiquidAmount =
    validateForm
        { model
            | cpuQuantityValidation = validateQuantity delegatebw.stakeCpuQuantity eosLiquidAmount
            , netQuantityValidation = validateQuantity delegatebw.stakeNetQuantity eosLiquidAmount
            , totalQuantityValidation = validateQuantity totalQuantity eosLiquidAmount
        }


validateText : Model -> ( String, String )
validateText { cpuQuantityValidation, netQuantityValidation, totalQuantityValidation, accountValidation } =
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
