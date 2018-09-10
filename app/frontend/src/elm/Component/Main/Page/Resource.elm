module Component.Main.Page.Resource exposing (Message(..), Model, ResourceTab(..), SelectedTab(..), initModel, resourceTabA, update, view, viewDelegateListModal, viewStakeAmountModal)

import Component.Main.Page.Resource.Delegate as DelegateTab
import Component.Main.Page.Resource.Stake as StakeTab
import Component.Main.Page.Resource.Undelegate as UndelegateTab
import Component.Main.Page.Resource.Unstake as UnstakeTab
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
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Translation exposing (I18n(..), Language, translate)



-- MODEL


type alias Model =
    { selectedTab : SelectedTab
    , tab : ResourceTab
    , isStakeAmountModalOpened : Bool
    , isDelegateListModalOpened : Bool
    }


type ResourceTab
    = Stake StakeTab.Model
    | Unstake UnstakeTab.Model
    | Delegate DelegateTab.Model
    | Undelegate UndelegateTab.Model


type SelectedTab
    = StakeSelected
    | UnstakeSelected
    | DelegateSelected
    | UndelegateSelected


initModel : Model
initModel =
    { selectedTab = StakeSelected
    , tab = Stake StakeTab.initModel
    , isStakeAmountModalOpened = False
    , isDelegateListModalOpened = False
    }



-- UPDATE


type Message
    = StakeMessage StakeTab.Message
    | UnstakeMessage UnstakeTab.Message
    | DelegateMessage DelegateTab.Message
    | UndelegateMessage UndelegateTab.Message
    | ChangeTab ResourceTab
    | CloseModal


update : Message -> Model -> Account -> ( Model, Cmd Message )
update message ({ tab } as model) ({ totalResources, selfDelegatedBandwidth, coreLiquidBalance } as account) =
    case ( message, tab ) of
        ( StakeMessage stakeMessage, Stake stakeModel ) ->
            case stakeMessage of
                StakeTab.OpenStakeAmountModal ->
                    ( { model | isStakeAmountModalOpened = True }, Cmd.none )

                _ ->
                    let
                        ( newModel, _ ) =
                            StakeTab.update
                                stakeMessage
                                stakeModel
                                account
                    in
                    ( { model | tab = Stake newModel }, Cmd.none )

        ( UnstakeMessage unstakeMessage, Unstake unstakeModel ) ->
            let
                ( newModel, _ ) =
                    UnstakeTab.update
                        unstakeMessage
                        unstakeModel
                        account
            in
            ( { model | tab = Unstake newModel }, Cmd.none )

        ( DelegateMessage delegateMessage, Delegate delegateModel ) ->
            case delegateMessage of
                DelegateTab.OpenDelegateListModal ->
                    ( { model | isDelegateListModalOpened = True }, Cmd.none )

                _ ->
                    let
                        ( newModel, _ ) =
                            DelegateTab.update
                                delegateMessage
                                delegateModel
                                account
                    in
                    ( { model | tab = Delegate newModel }, Cmd.none )

        ( UndelegateMessage undelegateMessage, Undelegate undelegateModel ) ->
            case undelegateMessage of
                UndelegateTab.OpenDelegateListModal ->
                    ( { model | isDelegateListModalOpened = True }, Cmd.none )

                _ ->
                    let
                        ( newModel, _ ) =
                            UndelegateTab.update
                                undelegateMessage
                                undelegateModel
                                account
                    in
                    ( { model | tab = Undelegate newModel }, Cmd.none )

        ( ChangeTab newTab, _ ) ->
            case newTab of
                Stake stakeModel ->
                    ( { model | tab = newTab, selectedTab = StakeSelected }, Cmd.none )

                Unstake unstakeModel ->
                    ( { model | tab = newTab, selectedTab = UnstakeSelected }, Cmd.none )

                Delegate delegateModel ->
                    ( { model | tab = newTab, selectedTab = DelegateSelected }, Cmd.none )

                Undelegate undelegateModel ->
                    ( { model | tab = newTab, selectedTab = UndelegateSelected }, Cmd.none )

        ( CloseModal, _ ) ->
            ( { model | isStakeAmountModalOpened = False, isDelegateListModalOpened = False }, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )



-- VIEW


view : Language -> Model -> Account -> Html Message
view language ({ selectedTab, tab, isStakeAmountModalOpened, isDelegateListModalOpened } as model) account =
    let
        tabHtml =
            case tab of
                Stake stakeModel ->
                    Html.map StakeMessage (StakeTab.view language StakeTab.initModel account)

                Unstake unstakeModel ->
                    Html.map UnstakeMessage (UnstakeTab.view language UnstakeTab.initModel account)

                Delegate delegateModel ->
                    Html.map DelegateMessage (DelegateTab.view language DelegateTab.initModel account)

                Undelegate undelegateModel ->
                    Html.map UndelegateMessage (UndelegateTab.view language UndelegateTab.initModel account)
    in
    div []
        [ main_ [ class "resource_management" ]
            [ h2 []
                [ text "리소스 관리" ]
            , p []
                [ text "EOS 네트워크를 활용하기 위한 리소스 관리 페이지입니다." ]
            , div [ class "tab" ]
                [ resourceTabA model StakeSelected
                , resourceTabA model UnstakeSelected
                , resourceTabA model DelegateSelected
                , resourceTabA model UndelegateSelected
                ]
            , tabHtml
            ]
        , viewStakeAmountModal isStakeAmountModalOpened
        , viewDelegateListModal isDelegateListModalOpened
        ]


resourceTabA : Model -> SelectedTab -> Html Message
resourceTabA ({ selectedTab } as model) selected =
    let
        aText =
            case selected of
                StakeSelected ->
                    "스테이크"

                UnstakeSelected ->
                    "언스테이크"

                DelegateSelected ->
                    "임대해주기"

                UndelegateSelected ->
                    "임대취소하기"

        resourceTab =
            case selected of
                StakeSelected ->
                    Stake StakeTab.initModel

                UnstakeSelected ->
                    Unstake UnstakeTab.initModel

                DelegateSelected ->
                    Delegate DelegateTab.initModel

                UndelegateSelected ->
                    Undelegate UndelegateTab.initModel
    in
    a
        [ class
            (if selectedTab == selected then
                "ing"

             else
                ""
            )
        , onClick (ChangeTab resourceTab)
        ]
        [ text aText ]


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
                [ button [ class "undo button", type_ "button", onClick CloseModal ]
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
            , button [ class "close", id "closePopup", type_ "button", onClick CloseModal ]
                [ text "닫기" ]
            ]
        ]
