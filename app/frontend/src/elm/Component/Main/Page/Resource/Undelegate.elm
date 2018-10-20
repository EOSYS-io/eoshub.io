module Component.Main.Page.Resource.Undelegate exposing
    ( Message(..)
    , Model
    , PercentageOfResource(..)
    , ResourceType(..)
    , getEmptyStringIfZeroEos
    , getNoOpIfZeroEos
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

import Component.Main.Page.Resource.Modal.DelegateList as DelegateList exposing (Message(..))
import Data.Account exposing (Account)
import Data.Action as Action exposing (UndelegatebwParameters, encodeAction)
import Data.Table exposing (Row)
import Html exposing (Html, button, div, h3, input, label, p, section, span, strong, text)
import Html.Attributes
    exposing
        ( attribute
        , class
        , disabled
        , for
        , id
        , placeholder
        , readonly
        , step
        , type_
        )
import Html.Events exposing (onClick, onInput)
import Http
import Port
import Round
import Translation exposing (I18n(..), Language, translate)
import Util.Formatter
    exposing
        ( assetToFloat
        , numberWithinDigitLimit
        , removeSymbolIfExists
        )
import Util.HttpRequest exposing (getTableRows)
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
    getTableRows "eosio" query "delband" -1
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
update message ({ undelegatebw, delegateListModal, unstakePossibleCpu, unstakePossibleNet } as model) { accountName } =
    case message of
        OnFetchTableRows (Ok rows) ->
            ( { model | delbandTable = rows }, Cmd.none )

        OnFetchTableRows (Err _) ->
            ( model, Cmd.none )

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
                        |> getEmptyStringIfZeroEos

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
                        |> getEmptyStringIfZeroEos

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
                                        , unstakeCpuQuantity =
                                            cpu
                                                |> removeSymbolIfExists
                                                |> getEmptyStringIfZeroEos
                                        , unstakeNetQuantity =
                                            net
                                                |> removeSymbolIfExists
                                                |> getEmptyStringIfZeroEos
                                    }
                                , unstakePossibleCpu = cpu
                                , unstakePossibleNet = net
                                , percentageOfCpu = getNoOpIfZeroEos cpu Percentage100
                                , percentageOfNet = getNoOpIfZeroEos net Percentage100
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
view language ({ delbandTable, unstakePossibleCpu, unstakePossibleNet, undelegatebw, isFormValid, delegateListModal } as model) { accountName } =
    let
        ( validatedText, validatedAttr ) =
            validateText language model

        modalHtml =
            Html.map DelegateListMessage (DelegateList.view language delegateListModal delbandTable accountName)
    in
    div [ class "rental cancel container" ]
        [ section [ class "search" ]
            [ div [ class "input field" ]
                [ input
                    [ attribute "autofocus" ""
                    , class "size large"
                    , attribute "maxlength" "12"
                    , placeholder (translate language SelectAccountToUndelegate)
                    , type_ "text"
                    , Html.Attributes.value undelegatebw.receiver
                    , readonly True
                    ]
                    []
                , button [ id "viewRentalListAccount", class "choice button", type_ "button", onClick OpenDelegateListModal ]
                    [ text (translate language DelegatedList) ]
                ]
            ]
        , div [ class "my resource" ]
            [ div []
                [ h3 []
                    [ text (translate language (DelegatedAmount "CPU"))
                    , strong []
                        [ text unstakePossibleCpu ]
                    ]
                ]
            , div []
                [ h3 []
                    [ text (translate language (DelegatedAmount "NET"))
                    , strong []
                        [ text unstakePossibleNet ]
                    ]
                ]
            ]
        , section []
            [ p [ class ("validate description" ++ validatedAttr) ]
                [ text validatedText ]
            , div [ class "field group" ]
                [ resourceInputDiv language model Cpu
                , resourceInputDiv language model Net
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
        , modalHtml
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


resourceInputDiv : Language -> Model -> ResourceType -> Html Message
resourceInputDiv language { undelegatebw, percentageOfCpu, percentageOfNet, cpuQuantityValidation, netQuantityValidation } resourceType =
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
            , Html.Attributes.value resourceQuantity
            ]
            []
        , span [ class "unit" ]
            [ text "EOS" ]
        , percentageButton language resourceType percentageOfResource Percentage10
        , percentageButton language resourceType percentageOfResource Percentage50
        , percentageButton language resourceType percentageOfResource Percentage70
        , percentageButton language resourceType percentageOfResource Percentage100
        ]



-- NOTE(boseok): Consider integration with Delegate.validateEach


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
        -- NOTE(boseok): Because receiver must be one of delegate list accounts, requestStatus is passed as Succeed.
        accountValidation =
            validateAccount undelegatebw.receiver Validation.Succeed

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
        ( translate language UndelegatePossible, " true" )

    else if isNotEmptyBoth then
        if not isCpuValid && not isNetValid then
            ( translate language (InvalidQuantityInput "CPU, NET"), " false" )

        else if not isCpuValid then
            ( translate language (InvalidQuantityInput "CPU"), " false" )

        else if not isNetValid then
            ( translate language (InvalidQuantityInput "NET"), " false" )

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


getEmptyStringIfZeroEos : String -> String
getEmptyStringIfZeroEos asset =
    if assetToFloat asset == 0 then
        ""

    else
        asset


getNoOpIfZeroEos : String -> PercentageOfResource -> PercentageOfResource
getNoOpIfZeroEos asset currentPercentage =
    if assetToFloat asset == 0 then
        NoOp

    else
        currentPercentage
