module Component.Main.Page.Resource.Undelegate exposing
    ( Message(..)
    , Model
    , PercentageOfResource(..)
    , ResourceType(..)
    , getPercentageOfResource
    , initCmd
    , initModel
    , percentageButton
    , update
    , validate
    , validateAttr
    , validateText
    , view
    )

import Component.Main.Page.Resource.Modal.DelegateList as DelegateList
    exposing
        ( Message(..)
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
import Data.Table exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
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
import Util.HttpRequest exposing (getFullPath, getTableRows, post)
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
    , unstakePossibleCpu : String
    , unstakePossibleNet : String
    , delbandTable : List Row
    , percentageOfCpu : PercentageOfResource
    , percentageOfNet : PercentageOfResource
    , accountValidation : AccountStatus
    , cpuQuantityValidation : QuantityStatus
    , netQuantityValidation : QuantityStatus
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
    { undelegatebw = { from = "", receiver = "", unstakeNetQuantity = "", unstakeCpuQuantity = "" }
    , unstakePossibleCpu = "0 EOS"
    , unstakePossibleNet = "0 EOS"
    , delbandTable = []
    , percentageOfCpu = NoOp
    , percentageOfNet = NoOp
    , accountValidation = EmptyAccount
    , cpuQuantityValidation = EmptyQuantity
    , netQuantityValidation = EmptyQuantity
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
    | CpuAmountInput String
    | NetAmountInput String
    | ClickCpuPercentage PercentageOfResource
    | ClickNetPercentage PercentageOfResource
    | SubmitAction
    | OpenDelegateListModal
    | DelegateListMessage DelegateList.Message


update : Message -> Model -> Account -> ( Model, Cmd Message )
update message ({ undelegatebw, delegateListModal, unstakePossibleCpu, unstakePossibleNet } as model) ({ accountName, totalResources, selfDelegatedBandwidth, coreLiquidBalance } as account) =
    case message of
        OnFetchTableRows (Ok rows) ->
            ( { model | delbandTable = rows }, Cmd.none )

        OnFetchTableRows (Err str) ->
            ( model, Cmd.none )

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
                    { undelegatebw | from = accountName }
                        |> Action.Undelegatebw
                        |> encodeAction
                        |> Port.pushAction
            in
            ( { model | undelegatebw = { undelegatebw | from = accountName } }, cmd )

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
                ClickDelband receiver cpu net ->
                    let
                        newModel =
                            { model
                                | undelegatebw =
                                    { undelegatebw
                                        | receiver = receiver
                                        , unstakeCpuQuantity = cpu |> removeSymbolIfExists
                                        , unstakeNetQuantity = net |> removeSymbolIfExists
                                    }
                                , unstakePossibleCpu = cpu
                                , unstakePossibleNet = net
                                , delegateListModal =
                                    { delegateListModal
                                        | isDelegateListModalOpened = False
                                    }
                            }
                    in
                    ( validate newModel cpu net, Cmd.none )

                _ ->
                    let
                        ( newModel, _ ) =
                            DelegateList.update subMessage delegateListModal
                    in
                    ( { model | delegateListModal = newModel }, Cmd.none )



-- VIEW


view : Language -> Model -> Account -> Html Message
view language ({ delbandTable, unstakePossibleCpu, unstakePossibleNet, cpuQuantityValidation, netQuantityValidation, percentageOfCpu, percentageOfNet, undelegatebw, isFormValid, delegateListModal } as model) ({ accountName, totalResources, selfDelegatedBandwidth, coreLiquidBalance } as account) =
    let
        unstakedAmount =
            floatToAsset (larimerToEos account.voterInfo.staked)

        unstakePossibleAmount =
            assetAdd selfDelegatedBandwidth.cpuWeight selfDelegatedBandwidth.netWeight

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

        modalHtml =
            Html.map DelegateListMessage (DelegateList.view language delegateListModal delbandTable accountName)
    in
    div [ class "rental cancel container" ]
        [ div [ class "available status" ]
            [ a [ id "viewRentalListAccount", onClick OpenDelegateListModal ]
                [ text "임대해준 계정 리스트 보기" ]
            ]
        , section []
            [ div [ class "input field" ]
                [ input
                    [ attribute "autofocus" ""
                    , class "size large"
                    , attribute "maxlength" "12"
                    , placeholder "임대취소할 계정을 선택하세요"
                    , type_ "text"
                    , value undelegatebw.receiver
                    , disabled True
                    ]
                    []
                , span [ class "validate description" ]
                    [ text "계정이름 예시:eoshubby" ]
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
resourceInputDiv ({ undelegatebw, percentageOfCpu, percentageOfNet, cpuQuantityValidation, netQuantityValidation } as model) resourceType =
    let
        cpuValidateAttr =
            validateAttr cpuQuantityValidation

        netValidateAttr =
            validateAttr netQuantityValidation

        ( resourceText, validateAttribute, inputMessage, resourceQuantity, percentageOfResource ) =
            case resourceType of
                Cpu ->
                    ( "CPU", cpuValidateAttr, CpuAmountInput, undelegatebw.unstakeCpuQuantity, percentageOfCpu )

                Net ->
                    ( "NET", netValidateAttr, NetAmountInput, undelegatebw.unstakeNetQuantity, percentageOfNet )
    in
    div [ class "input field" ]
        [ label [ for resourceText ]
            [ text resourceText ]
        , input
            [ attribute "data-validate" validateAttribute
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



-- NOTE(boseok): consider integration with Delegate.validateEach


validateEach : AccountStatus -> QuantityStatus -> QuantityStatus -> ( Bool, Bool, Bool, Bool )
validateEach accountValidation cpuQuantityValidation netQuantityValidation =
    let
        isAccountValid =
            accountValidation == ValidAccount

        isNotEmptyBoth =
            not ((cpuQuantityValidation == EmptyQuantity) && (netQuantityValidation == EmptyQuantity))

        isCpuValid =
            (cpuQuantityValidation == ValidQuantity) || (cpuQuantityValidation == EmptyQuantity)

        isNetValid =
            (netQuantityValidation == ValidQuantity) || (netQuantityValidation == EmptyQuantity)
    in
    ( isAccountValid, isNotEmptyBoth, isCpuValid, isNetValid )


validate : Model -> String -> String -> Model
validate ({ undelegatebw } as model) unstakePossibleCpu unstakePossibleNet =
    let
        accountValidation =
            validateAccount undelegatebw.receiver

        netQuantityValidation =
            validateQuantity
                undelegatebw.unstakeNetQuantity
                (assetToFloat unstakePossibleNet)

        cpuQuantityValidation =
            validateQuantity
                undelegatebw.unstakeCpuQuantity
                (assetToFloat unstakePossibleCpu)

        ( isAccountValid, isNotEmptyBoth, isCpuValid, isNetValid ) =
            validateEach accountValidation cpuQuantityValidation netQuantityValidation

        isFormValid =
            isAccountValid
                && isCpuValid
                && isNetValid
                && isNotEmptyBoth
    in
    { model
        | accountValidation = accountValidation
        , cpuQuantityValidation = cpuQuantityValidation
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
validateText ({ cpuQuantityValidation, netQuantityValidation } as model) =
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
