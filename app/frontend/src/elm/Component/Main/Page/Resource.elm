module Component.Main.Page.Resource exposing (..)

import Component.Main.Page.Resource.Stake as Stake exposing (..)
import Component.Main.Page.Resource.Unstake as Unstake exposing (..)
import Component.Main.Page.Resource.Delegate as Delegate exposing (..)
import Component.Main.Page.Resource.Undelegate as Undelegate exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Translation exposing (I18n(..), Language, translate)
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


-- MODEL


type alias Model =
    { selectedTab : String
    , tab : ResourceTab
    , isStakeAmountModalOpened : Bool
    , isDelegateListModalOpened : Bool
    }


type ResourceTab
    = Stake Stake.Model
    | Unstake Unstake.Model
    | Delegate Delegate.Model
    | Undelegate Undelegate.Model


initModel : Model
initModel =
    { selectedTab = "stake"
    , tab = Stake Stake.initModel
    , isStakeAmountModalOpened = False
    , isDelegateListModalOpened = False
    }



-- UPDATE


type Message
    = StakeMessage Stake.Message
    | UnstakeMessage Unstake.Message
    | DelegateMessage Delegate.Message
    | UndelegateMessage Undelegate.Message
    | ChangeTab ResourceTab
    | CloseModal


update : Message -> Model -> ResourceInEos -> ResourceInEos -> String -> ( Model, Cmd Message )
update message ({ tab } as model) totalResources selfDelegatedBandwidth coreLiquidBalance =
    case ( message, tab ) of
        ( StakeMessage stakeMessage, Stake stakeModel ) ->
            case stakeMessage of
                OpenStakeAmountModal ->
                    ( { model | isStakeAmountModalOpened = True }, Cmd.none )

                _ ->
                    let
                        ( newModel, subCmd ) =
                            Stake.update
                                stakeMessage
                                stakeModel
                                totalResources
                                selfDelegatedBandwidth
                                coreLiquidBalance
                    in
                        ( { model | tab = Stake newModel }, Cmd.none )

        ( UnstakeMessage unstakeMessage, Unstake unstakeModel ) ->
            let
                ( newModel, subCmd ) =
                    Unstake.update
                        unstakeMessage
                        unstakeModel
                        totalResources
                        selfDelegatedBandwidth
                        coreLiquidBalance
            in
                ( { model | tab = Unstake newModel }, Cmd.none )

        ( ChangeTab newTab, _ ) ->
            case newTab of
                Stake stakeModel ->
                    ( { model | tab = newTab, selectedTab = "stake" }, Cmd.none )

                Unstake unstakeModel ->
                    ( { model | tab = newTab, selectedTab = "unstake" }, Cmd.none )

                Delegate delegateModel ->
                    ( { model | tab = newTab, selectedTab = "delegate" }, Cmd.none )

                Undelegate undelegateModel ->
                    ( { model | tab = newTab, selectedTab = "undelegate" }, Cmd.none )

        ( DelegateMessage delegateMessage, Delegate delegateModel ) ->
            case delegateMessage of
                Delegate.OpenDelegateListModal ->
                    ( { model | isDelegateListModalOpened = True }, Cmd.none )

                _ ->
                    let
                        ( newModel, subCmd ) =
                            Delegate.update
                                delegateMessage
                                delegateModel
                                totalResources
                                selfDelegatedBandwidth
                                coreLiquidBalance
                    in
                        ( { model | tab = Delegate newModel }, Cmd.none )

        ( UndelegateMessage undelegateMessage, Undelegate undelegateModel ) ->
            case undelegateMessage of
                Undelegate.OpenDelegateListModal ->
                    ( { model | isDelegateListModalOpened = True }, Cmd.none )

                _ ->
                    let
                        ( newModel, subCmd ) =
                            Undelegate.update
                                undelegateMessage
                                undelegateModel
                                totalResources
                                selfDelegatedBandwidth
                                coreLiquidBalance
                    in
                        ( { model | tab = Undelegate newModel }, Cmd.none )

        ( CloseModal, _ ) ->
            ( { model | isStakeAmountModalOpened = False, isDelegateListModalOpened = False }, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )



-- VIEW


view : Language -> Model -> ResourceInEos -> ResourceInEos -> String -> Html Message
view language ({ selectedTab, tab, isStakeAmountModalOpened, isDelegateListModalOpened } as model) totalResources selfDelegatedBandwidth coreLiquidBalance =
    let
        tabHtml =
            case tab of
                Stake stakeModel ->
                    Html.map StakeMessage (Stake.view language Stake.initModel totalResources selfDelegatedBandwidth coreLiquidBalance)

                Unstake unstakeModel ->
                    Html.map UnstakeMessage (Unstake.view language Unstake.initModel totalResources selfDelegatedBandwidth coreLiquidBalance)

                Delegate delegateModel ->
                    Html.map DelegateMessage (Delegate.view language Delegate.initModel totalResources selfDelegatedBandwidth coreLiquidBalance)

                Undelegate undelegateModel ->
                    Html.map UndelegateMessage (Undelegate.view language Undelegate.initModel totalResources selfDelegatedBandwidth coreLiquidBalance)
    in
        div []
            [ main_ [ class "resource_management" ]
                [ h2 []
                    [ text "리소스 관리" ]
                , p []
                    [ text "EOS 네트워크를 활용하기 위한 리소스 관리 페이지입니다." ]
                , div [ class "tab" ]
                    [ a
                        [ class
                            (if (selectedTab == "stake") then
                                "ing"
                             else
                                ""
                            )
                        , onClick (ChangeTab (Stake Stake.initModel))
                        ]
                        [ text "스테이크" ]
                    , a
                        [ class
                            (if (selectedTab == "unstake") then
                                "ing"
                             else
                                ""
                            )
                        , onClick (ChangeTab (Unstake Unstake.initModel))
                        ]
                        [ text "언스테이크" ]
                    , a
                        [ class
                            (if (selectedTab == "delegate") then
                                "ing"
                             else
                                ""
                            )
                        , onClick (ChangeTab (Delegate Delegate.initModel))
                        ]
                        [ text "임대해주기" ]
                    , a
                        [ class
                            (if (selectedTab == "undelegate") then
                                "ing"
                             else
                                ""
                            )
                        , onClick (ChangeTab (Undelegate Undelegate.initModel))
                        ]
                        [ text "임대취소하기" ]
                    ]
                , tabHtml
                ]
            , viewStakeAmountModal isStakeAmountModalOpened
            , viewDelegateListModal isDelegateListModalOpened
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
            , p [ class "validate description" ]
                [ text "7:3 비율로 스테이킹 하는 것이 가장 좋습니다." ]
            , div [ class "btn_area" ]
                [ button [ class "undo button", type_ "button", onClick (CloseModal) ]
                    [ text "취소" ]
                , button [ class "ok button", attribute "disabled" "", type_ "button" ]
                    [ text "확인" ]
                ]
            ]
        ]


viewDelegateListModal : Bool -> Html Message
viewDelegateListModal opened =
    section
        [ attribute "aria-live" "true"
        , class
            ("rental_account modal popup"
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
                [ text "임대해준 계정 리스트" ]
            , Html.form [ action "" ]
                [ input [ class "search_token", id "", name "", placeholder "계정명 검색하기", type_ "text" ]
                    []
                , button [ type_ "button" ]
                    [ text "검색" ]
                ]
            , div [ class "result list", attribute "role" "listbox" ]
                [ ul []
                    [ li []
                        [ h3 []
                            [ text "blockoine123" ]
                        , p []
                            [ text "CPU : 123123123 EOS" ]
                        , p []
                            [ text "NET : 123123123 EOS" ]
                        , button [ type_ "button" ]
                            [ text "취소하기" ]
                        ]
                    , li []
                        [ h3 []
                            [ text "blockoine123" ]
                        , p []
                            [ text "CPU : 123123123 EOS" ]
                        , p []
                            [ text "NET : 123123123 EOS" ]
                        , button [ type_ "button" ]
                            [ text "취소하기" ]
                        ]
                    , li []
                        [ h3 []
                            [ text "blockoine123" ]
                        , p []
                            [ text "CPU : 123123123 EOS" ]
                        , p []
                            [ text "NET : 123123123 EOS" ]
                        , button [ type_ "button" ]
                            [ text "취소하기" ]
                        ]
                    , li []
                        [ h3 []
                            [ text "blockoine123" ]
                        , p []
                            [ text "CPU : 123123123 EOS" ]
                        , p []
                            [ text "NET : 123123123 EOS" ]
                        , button [ type_ "button" ]
                            [ text "취소하기" ]
                        ]
                    ]
                ]
            , button [ class "close", id "closePopup", type_ "button", onClick (CloseModal) ]
                [ text "닫기" ]
            ]
        ]
