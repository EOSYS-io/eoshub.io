module Component.SidebarComponent exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Navigation
import Port
import Translation exposing (Language(..), I18n(..), translate)
import Util.WalletDecoder
    exposing
        ( Wallet
        , WalletResponse
        , WalletStatus(Authenticated, NotFound)
        , decodeWalletResponse
        )


-- MODEL


type State
    = SignIn
    | PairWallet
    | AccountInfo
    | Loading


type alias Model =
    { language : Language
    , wallet : Wallet
    , state : State
    , fold : Bool
    , configPanelOpen : Bool
    }


initModel : Model
initModel =
    { language = English
    , wallet =
        { status = NotFound
        , account = ""
        , authority = ""
        }
    , state = Loading
    , fold = False
    , configPanelOpen = False
    }



-- MESSAGE


type Message
    = AuthenticateAccount
    | CheckWalletStatus
    | ToggleSidebar
    | InvalidateAccount
    | UpdateLanguage Language
    | UpdateWalletStatus WalletResponse
    | UpdateState State
    | ChangeUrl String
    | OpenConfigPanel Bool
    | AndThen Message Message



-- VIEW


view : Model -> List (Html Message)
view { state, wallet, language, fold, configPanelOpen } =
    [ header []
        [ h1
            [ style [ ( "cursor", "pointer" ) ]
            , onClick (ChangeUrl "/")
            ]
            [ text "eoshub" ]
        , button
            [ type_ "button"
            , id "lnbToggleButton"
            , class "folding button"
            , attribute "aria-hidden" "true"
            , onClick ToggleSidebar
            ]
            [ text (translate language OpenCloseSidebar) ]
        ]
    , case state of
        SignIn ->
            signInView language

        PairWallet ->
            pairWalletView language

        AccountInfo ->
            accountInfoView language wallet configPanelOpen

        Loading ->
            loadingView language
    , nav []
        [ div [ class "sns_area" ]
            [ a [ class "sns fb button" ] []
            , a [ class "sns twitter button" ] []
            , a [ class "sns telegram button" ] []
            ]
        , div [ class "lang_area" ]
            [ button
                [ type_ "button"
                , class "lang ko transparent button"
                , attribute "data-lang" "ko"
                , onClick (UpdateLanguage Korean)
                ]
                [ text "한글" ]
            , button
                [ type_ "button"
                , class "lang en transparent button"
                , attribute "data-lang" "en"
                , onClick (UpdateLanguage English)
                ]
                [ text "ENG" ]
            ]
        ]
    ]


signInView : Language -> Html Message
signInView language =
    div [ class "dashboard logout" ]
        [ h2 []
            [ text (translate language Hello ++ ",")
            , br [] []
            , text (translate language WelcomeEosHub)
            ]
        , div [ class "panel" ]
            [ p []
                [ text (translate language IfYouHaveEos)
                , br [] []
                , text (translate language IfYouAreNew)
                ]
            ]
        , div [ class "btn_area" ]
            [ a
                [ class "middle blue_white button"
                , onClick (UpdateState PairWallet)
                ]
                [ text (translate language Login) ]
            , a
                [ class "middle white_blue button"
                , onClick (ChangeUrl "/account/confirm_email")
                ]
                [ text (translate language NewAccount) ]
            ]
        ]


pairWalletView : Language -> Html Message
pairWalletView language =
    div [ class "dashboard hello_world" ]
        [ h2 []
            [ text (translate language AttachableWallet1)
            , br [] []
            , text (translate language AttachableWallet2)
            ]
        , div [ class "panel" ]
            [ p []
                [ text (translate language FurtherUpdate1)
                , br [] []
                , text (translate language FurtherUpdate2)
                ]
            , p [ class "help info" ]
                [ a [] [ text (translate language HowToAttach) ]
                ]
            ]
        , ul [ class "available_wallet_list" ]
            [ li [ class "scatter" ]
                [ text "Scatter"
                , button
                    [ type_ "button"
                    , onClick AuthenticateAccount
                    ]
                    [ text (translate language Attach) ]
                ]
            ]
        ]


accountInfoView : Language -> Wallet -> Bool -> Html Message
accountInfoView language { account, authority } configPanelOpen =
    let
        configPanelClass =
            class
                ("config_panel"
                    ++ (if configPanelOpen then
                            " expand"
                        else
                            ""
                       )
                )
    in
        div [ class "dashboard logged" ]
            [ div [ class "user_status" ]
                [ h2 [] [ text (account ++ "@" ++ authority) ]
                , div
                    [ configPanelClass ]
                    [ button
                        [ type_ "button"
                        , class "icon gear button"
                        , attribute "wai-aria" "hidden"
                        , onClick (OpenConfigPanel (not configPanelOpen))
                        ]
                        [ text "option" ]
                    , div [ class "menu_list" ]
                        [ a
                            [ style [ ( "cursor", "pointer" ) ]
                            , onClick (AndThen (OpenConfigPanel False) (UpdateState PairWallet))
                            ]
                            [ text (translate language ChangeWallet) ]
                        , a
                            [ style [ ( "cursor", "pointer" ) ]
                            , onClick (AndThen (OpenConfigPanel False) (ChangeUrl ("search?query=" ++ account)))
                            ]
                            [ text (translate language MyAccount) ]
                        , a
                            [ style [ ( "cursor", "pointer" ) ]
                            , onClick (AndThen (OpenConfigPanel False) InvalidateAccount)
                            ]
                            [ text (translate language SignOut) ]
                        ]
                    ]
                ]
            , div [ class "panel" ]
                [ h3 []
                    [ text (translate language TotalAmount)
                    , strong [] [ text "1820 EOS" ]
                    ]
                , ul [ class "status" ]
                    [ li []
                        [ text
                            (translate language UnstakedAmount)
                        , strong [] [ text "30 EOS" ]
                        ]
                    , li []
                        [ text
                            (translate language StakedAmount)
                        , strong [] [ text "10 EOS" ]
                        ]
                    ]
                , div [ class "graph" ] [ span [ style [ ( "width", "50%" ) ], title "50%" ] [] ]
                , p [ class "description" ] [ text (translate language FastTransactionPossible) ]
                ]
            , div [ class "btn_area" ]
                [ a [ class "middle lightgray_white button manage" ]
                    [ text (translate language ManageStaking) ]
                ]
            , p [ class "help" ]
                [ a [] [ text (translate language WhatIsStaking) ]
                ]
            ]


loadingView : Language -> Html Message
loadingView _ =
    div [ class "dashboard" ] [ h2 [] [ text "Loading..." ] ]


foldClass : Bool -> Html.Attribute msg
foldClass folded =
    if folded then
        class "fold sidebar"
    else
        class "sidebar"



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message ({ configPanelOpen, fold } as model) =
    case message of
        AuthenticateAccount ->
            ( model, Port.authenticateAccount () )

        CheckWalletStatus ->
            ( model, Port.checkWalletStatus () )

        ToggleSidebar ->
            ( { model | fold = not fold }, Cmd.none )

        InvalidateAccount ->
            ( model, Port.invalidateAccount () )

        UpdateLanguage language ->
            ( { model | language = language }, Cmd.none )

        UpdateState state ->
            ( { model | state = state }, Cmd.none )

        UpdateWalletStatus resp ->
            let
                ({ status } as newWallet) =
                    decodeWalletResponse resp

                newState =
                    case status of
                        Authenticated ->
                            AccountInfo

                        _ ->
                            SignIn
            in
                update (UpdateState newState) { model | wallet = newWallet }

        ChangeUrl url ->
            ( model, Navigation.newUrl url )

        OpenConfigPanel bool ->
            ( { model | configPanelOpen = not configPanelOpen }, Cmd.none )

        AndThen firstMessage secondMessage ->
            let
                ( firstModel, firstCmd ) =
                    update firstMessage model

                ( secondModel, secondCmd ) =
                    update secondMessage firstModel
            in
                ( secondModel, Cmd.batch [ firstCmd, secondCmd ] )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions _ =
    Port.receiveWalletStatus UpdateWalletStatus
