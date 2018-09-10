module Component.Main.Page.Resource.Stake exposing (..)

import Data.Action as Action exposing (DelegatebwParameters, encodeAction)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Translation exposing (I18n(..), Language, translate)
import Util.Validation as Validation
    exposing
        ( AccountStatus(..)
        , QuantityStatus(..)
        , MemoStatus(..)
        , validateAccount
        , validateQuantity
        , validateMemo
        )
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
import Util.Formatter exposing (eosStringAdd, eosStringSubtract, eosFloatToString, larimerToEos)


-- MODEL


type alias Model =
    { delegatebw : DelegatebwParameters
    , totalQuantity : String
    , totalQuantityValidation : QuantityStatus
    , cpuQuantityValidation : QuantityStatus
    , netQuantityValidation : QuantityStatus
    , isFormValid : Bool
    }


initModel : Model
initModel =
    { delegatebw = { from = "", receiver = "", stakeNetQuantity = "", stakeCpuQuantity = "", transfer = 1 }
    , totalQuantity = ""
    , totalQuantityValidation = EmptyQuantity
    , cpuQuantityValidation = EmptyQuantity
    , netQuantityValidation = EmptyQuantity
    , isFormValid = False
    }



-- UPDATE


type Message
    = TotalAmountInput String
    | OpenStakeAmountModal -- This is controlled at Resource module
    | StakePercentage Float


update : Message -> Model -> Account -> ( Model, Cmd Message )
update message model ({ totalResources, selfDelegatedBandwidth, coreLiquidBalance } as account) =
    let
        stakeAbleAmount =
            coreLiquidBalance
    in
        case message of
            TotalAmountInput value ->
                ( { model | totalQuantity = value }, Cmd.none )

            StakePercentage percentage ->
                ( model, Cmd.none )

            _ ->
                ( model, Cmd.none )



-- VIEW


view : Language -> Model -> Account -> Html Message
view language model ({ totalResources, selfDelegatedBandwidth, coreLiquidBalance } as account) =
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
                        [ text ("임대받은 토큰 : " ++ (eosStringSubtract totalResources.cpuWeight selfDelegatedBandwidth.cpuWeight)) ]
                    , div [ class "graph status" ]
                        [ span [ class cpuColor, attribute "style" ("height:" ++ cpuPercent) ]
                            []
                        , text (cpuPercent)
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
                        [ text ("임대받은 토큰 : " ++ (eosStringSubtract totalResources.netWeight selfDelegatedBandwidth.netWeight)) ]
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
                    , a [ id "setDirect", onClick (OpenStakeAmountModal) ]
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
                        , onInput (TotalAmountInput)
                        ]
                        []
                    , span [ class "validate description" ]
                        [ text "보유한 수량만큼 스테이크 할 수 있습니다." ]

                    -- TODO(boseok): this should be applied to new design
                    , p [ class "validate description" ]
                        [ text "cpu" ]
                    , p [ class "validate description" ]
                        [ text "net" ]
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
        { from, receiver, stakeNetQuantity, stakeCpuQuantity, transfer } =
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
