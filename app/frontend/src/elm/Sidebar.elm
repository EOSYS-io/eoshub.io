module Sidebar exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Port
import Translation exposing (Language(..), I18n(..), translate)
import Util.WalletDecoder
    exposing
        ( ScatterResponse
        , Wallet
        , WalletResponse
        , WalletStatus(Authenticated, NotFound)
        , decodeScatterResponse
        , decodeWalletResponse
        )
import View.Notification


-- MODEL


type State
    = SignIn
    | PairWallet
    | AccountInfo
    | Loading


type alias Model =
    { language : Language
    , notification : View.Notification.Message
    , wallet : Wallet
    , state : State
    , fold : Bool
    }


initModel : Model
initModel =
    { language = English
    , notification = View.Notification.None
    , wallet =
        { status = NotFound
        , account = ""
        , authority = ""
        }
    , state = Loading
    , fold = False
    }



-- MESSAGE


type Message
    = AuthenticateAccount
    | CheckWalletStatus
    | Fold
    | InvalidateAccount
    | Unfold
    | UpdateLanguage Language
    | UpdateScatterResponse ScatterResponse
    | UpdateState State
    | UpdateWalletStatus WalletResponse



-- VIEW


view : Model -> List (Html Message)
view { state, wallet, language, fold } =
    [ header []
        [ h1 [] [ text "eoshub" ]
        , button
            [ type_ "button"
            , id "lnbToggleButton"
            , class "folding button"
            , attribute "aria-hidden" "true"
            , onClick
                (if fold then
                    Unfold
                 else
                    Fold
                )
            ]
            [ text "사이드바 영역 열기/닫기" ]
        ]
    , case state of
        SignIn ->
            signInView language

        PairWallet ->
            pairWalletView language

        AccountInfo ->
            accountInfoView language wallet

        Loading ->
            loadingView language
    , nav []
        [ div [ class "sns_area" ]
            [ a [ class "sns fb button" ] [ text "Go to Facebook" ]
            , a [ class "sns twitter button" ] [ text "Go to Twitter" ]
            , a [ class "sns telegram button" ] [ text "Go to Telegram" ]
            ]
        , div [ class "lang_area" ]
            [ button [ type_ "button", class "lang ko transparent button", attribute "data-lang" "ko", onClick (UpdateLanguage Korean) ] [ text "한글" ]
            , button [ type_ "button", class "lang en transparent button", attribute "data-lang" "en", onClick (UpdateLanguage English) ] [ text "ENG" ]
            ]
        ]
    ]


signInView : Language -> Html Message
signInView language =
    div [ class "dashboard logout" ]
        [ h2 [] [ text "안녕하세요,", br [] [], text "이오스허브입니다." ]
        , div [ class "panel" ]
            [ p [] [ text "이오스 계정이 있으시면 로그인을,", br [] [], text "이오스가 처음이라면 신규계정을 생성해주세요!" ]
            ]
        , div [ class "btn_area" ]
            [ a [ class "middle blue_white button", onClick (UpdateState PairWallet) ] [ text (translate language Login) ]
            , a [ class "middle white_blue button" ] [ text (translate language NewAccount) ]
            ]
        ]


pairWalletView : Language -> Html Message
pairWalletView _ =
    div [ class "dashboard hello_world" ]
        [ h2 [] [ text "이오스 허브와 연동이", br [] [], text "가능한 eos 지갑입니다." ]
        , div [ class "panel" ]
            [ p [] [ text "추후 업데이트를 통해 연동가능한", br [] [], text "지갑수를 늘려갈 예정이오니 조금만 기다려주세요!" ]
            , p [ class "help info" ]
                [ a [] [ text "지갑연동방법 알아보기" ]
                ]
            ]
        , ul [ class "available_wallet_list" ]
            [ li []
                [ text "Scatter"
                , button [ type_ "button", onClick AuthenticateAccount ] [ text "연동하기" ]
                ]
            ]
        ]


accountInfoView : Language -> Wallet -> Html Message
accountInfoView _ { account, authority } =
    div [ class "dashboard logged" ]
        [ div [ class "user_status" ]
            [ h2 [] [ text (account ++ "@" ++ authority) ]
            , div [ class "config_panel" ]
                [ button
                    [ type_ "button"
                    , class "icon gear button"
                    , attribute "wai-aria" "hidden"
                    ]
                    [ text "option" ]
                , div [ class "menu_list" ]
                    [ a [] [ text "지갑 변경하기" ]
                    , a [] [ text "내 계정보기" ]
                    , a [ onClick InvalidateAccount ] [ text "로그아웃" ]
                    ]
                ]
            ]
        , div [ class "panel" ]
            [ h3 [] [ text "총 보유 수량", strong [] [ text "1820 EOS" ] ]
            , ul [ class "status" ]
                [ li [] [ text "보관취소 토큰", strong [] [ text "30 EOS" ] ]
                , li [] [ text "보관한 토큰", strong [] [ text "10 EOS" ] ]
                ]
            , div [ class "graph" ] [ span [ style [ ( "width", "50%" ) ], title "50%" ] [] ]
            , p [ class "description" ] [ text "원할한 트랜잭션 사용이 가능합니다." ]
            ]
        , div [ class "btn_area" ]
            [ a [ class "middle lightgray_white button manage" ] [ text "토큰 보관 관리하기" ]
            ]
        , p [ class "help" ]
            [ a [] [ text "토큰 보관이 뭔가요?" ]
            ]
        , p [ class "help" ]
            [ a [ onClick InvalidateAccount ] [ text "로그아웃" ] ]
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
update message model =
    case message of
        AuthenticateAccount ->
            ( model, Port.authenticateAccount () )

        CheckWalletStatus ->
            ( model, Port.checkWalletStatus () )

        Fold ->
            ( { model | fold = True }, Cmd.none )

        InvalidateAccount ->
            ( model, Port.invalidateAccount () )

        Unfold ->
            ( { model | fold = False }, Cmd.none )

        UpdateLanguage language ->
            ( { model | language = language }, Cmd.none )

        UpdateScatterResponse resp ->
            ( { model | notification = resp |> decodeScatterResponse }, Cmd.none )

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



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions _ =
    Sub.batch
        [ Port.receiveWalletStatus UpdateWalletStatus
        , Port.receiveScatterResponse UpdateScatterResponse
        ]
