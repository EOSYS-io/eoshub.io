module Component.Main.Page.Resource exposing
    ( Message(..)
    , Model
    , ResourceTab(..)
    , SelectedTab(..)
    , initModel
    , resourceTabA
    , update
    , view
    )

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
            let
                ( newModel, subCmd ) =
                    StakeTab.update
                        stakeMessage
                        stakeModel
                        account
            in
            ( { model | tab = Stake newModel }, Cmd.map StakeMessage subCmd )

        ( UnstakeMessage unstakeMessage, Unstake unstakeModel ) ->
            let
                ( newModel, subCmd ) =
                    UnstakeTab.update
                        unstakeMessage
                        unstakeModel
                        account
            in
            ( { model | tab = Unstake newModel }, Cmd.map UnstakeMessage subCmd )

        ( DelegateMessage delegateMessage, Delegate delegateModel ) ->
            let
                ( newModel, _ ) =
                    DelegateTab.update
                        delegateMessage
                        delegateModel
                        account
            in
            ( { model | tab = Delegate newModel }, Cmd.none )

        ( UndelegateMessage undelegateMessage, Undelegate undelegateModel ) ->
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

        ( _, _ ) ->
            ( model, Cmd.none )



-- VIEW


view : Language -> Model -> Account -> Html Message
view language ({ selectedTab, tab } as model) account =
    let
        tabHtml =
            case tab of
                Stake stakeModel ->
                    Html.map StakeMessage (StakeTab.view language stakeModel account)

                Unstake unstakeModel ->
                    Html.map UnstakeMessage (UnstakeTab.view language unstakeModel account)

                Delegate delegateModel ->
                    Html.map DelegateMessage (DelegateTab.view language delegateModel account)

                Undelegate undelegateModel ->
                    Html.map UndelegateMessage (UndelegateTab.view language undelegateModel account)
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
