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
        )
import Html exposing (Html, a, div, h2, main_, p, text)
import Html.Attributes exposing (class)
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
update message ({ tab } as model) ({ accountName } as account) =
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
                ( newModel, subCmd ) =
                    DelegateTab.update
                        delegateMessage
                        delegateModel
                        account
            in
            ( { model | tab = Delegate newModel }, Cmd.map DelegateMessage subCmd )

        ( UndelegateMessage undelegateMessage, Undelegate undelegateModel ) ->
            let
                ( newModel, subCmd ) =
                    UndelegateTab.update
                        undelegateMessage
                        undelegateModel
                        account
            in
            ( { model | tab = Undelegate newModel }, Cmd.map UndelegateMessage subCmd )

        ( ChangeTab newTab, _ ) ->
            case newTab of
                Stake _ ->
                    ( { model | tab = newTab, selectedTab = StakeSelected }, Cmd.none )

                Unstake _ ->
                    ( { model | tab = newTab, selectedTab = UnstakeSelected }, Cmd.none )

                Delegate _ ->
                    let
                        cmd =
                            Cmd.map DelegateMessage (DelegateTab.initCmd accountName)
                    in
                    ( { model | tab = newTab, selectedTab = DelegateSelected }, cmd )

                Undelegate _ ->
                    let
                        cmd =
                            Cmd.map UndelegateMessage (UndelegateTab.initCmd accountName)
                    in
                    ( { model | tab = newTab, selectedTab = UndelegateSelected }, cmd )

        ( _, _ ) ->
            ( model, Cmd.none )



-- VIEW


view : Language -> Model -> Account -> Html Message
view language ({ tab } as model) account =
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
                [ text (translate language ManageResource) ]
            , p []
                [ text (translate language ManageResourceDesc) ]
            , div [ class "tab" ]
                [ resourceTabA language model StakeSelected
                , resourceTabA language model UnstakeSelected
                , resourceTabA language model DelegateSelected
                , resourceTabA language model UndelegateSelected
                ]
            , tabHtml
            ]
        ]


resourceTabA : Language -> Model -> SelectedTab -> Html Message
resourceTabA language { selectedTab } selected =
    let
        aText =
            case selected of
                StakeSelected ->
                    translate language Translation.Stake

                UnstakeSelected ->
                    translate language Translation.Unstake

                DelegateSelected ->
                    translate language Translation.Delegate

                UndelegateSelected ->
                    translate language Translation.Undelegate

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
