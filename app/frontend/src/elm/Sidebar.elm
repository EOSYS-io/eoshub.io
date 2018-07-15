module Sidebar exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Port
import Response
    exposing
        ( ScatterResponse
        , Wallet
        , WalletResponse
        , WalletStatus(Authenticated, NotFound)
        , decodeScatterResponse
        , decodeWalletResponse
        )
import Translation exposing (Language(..), I18n(..), translate)
import View.Notification


-- MODEL


type State
    = SignIn
    | PairWallet
    | AccountInfo


type alias Model =
    { language : Language
    , notification : View.Notification.Message
    , wallet : Wallet
    , state : State
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
    , state = SignIn
    }



-- MESSAGE


type Message
    = AuthenticateAccount
    | CheckWalletStatus
    | InvalidateAccount
    | UpdateLanguage Language
    | UpdateScatterResponse ScatterResponse
    | UpdateState State
    | UpdateWalletStatus WalletResponse



-- VIEW


view : Model -> List (Html Message)
view { state, wallet, language } =
    [ header []
        [ h1 [] [ text "eoshub" ]
        , button [ type_ "button", class "bugger button", attribute "aria-hidden" "true" ] [ text "사이드바 영역 열기/닫기" ]
        ]
    , div
        [ class "dashboard" ]
        (case state of
            SignIn ->
                signInView language

            PairWallet ->
                pairWalletView language

            AccountInfo ->
                accountInfoView language wallet
        )
    , nav []
        [ div [ class "sns_area" ]
            [ a [ href "#", class "sns fb button" ] [ text "Go to Facebook" ]
            , a [ href "#", class "sns twitter button" ] [ text "Go to Twitter" ]
            , a [ href "#", class "sns telegram button" ] [ text "Go to Telegram" ]
            ]
        , div [ class "lang_area" ]
            [ button [ type_ "button", class "lang ko transparent button", attribute "data-lang" "ko", onClick (UpdateLanguage Korean) ] [ text "한글" ]
            , button [ type_ "button", class "lang ko transparent button", attribute "data-lang" "en", onClick (UpdateLanguage English) ] [ text "ENG" ]
            ]
        ]
    ]


signInView : Language -> List (Html Message)
signInView language =
    [ h2 [] [ text "안녕하세요,", br [] [], text "이오스허브입니다." ]
    , div [ class "panel" ]
        [ p [] [ text "이오스 계정이 있으시면 로그인을,", br [] [], text "이오스가 처음이라면 신규계정을 생성해주세요!" ]
        ]
    , div [ class "btn_area" ]
        [ a [ class "middle blue_white button", onClick (UpdateState PairWallet) ] [ text (translate language Login) ]
        , a [ href "#", class "middle white_blue button" ] [ text (translate language NewAccount) ]
        ]
    ]


pairWalletView : Language -> List (Html Message)
pairWalletView _ =
    [ h2 [] [ text "이오스 허브와 연동이", br [] [], text "가능한 eos 지갑입니다." ]
    , div [ class "panel" ]
        [ p [] [ text "추후 업데이트를 통해 연동가능한", br [] [], text "지갑수를 늘려갈 예정이오니 조금만 기다려주세요!" ]
        , p [ class "help info" ]
            [ a [ href "#" ] [ text "지갑연동방법 알아보기" ]
            ]
        ]
    , ul [ class "available_wallet_list" ]
        [ li []
            [ text "Scatter"
            , button [ type_ "button", onClick AuthenticateAccount ] [ text "연동하기" ]
            ]
        ]
    ]


accountInfoView : Language -> Wallet -> List (Html Message)
accountInfoView _ { account, authority } =
    [ h2 [] [ text "Succeed to pair a wallet." ]
    , h2 [] [ text (account ++ "@" ++ authority) ]
    ]



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message ({ state } as model) =
    case message of
        AuthenticateAccount ->
            ( model, Port.authenticateAccount () )

        CheckWalletStatus ->
            ( model, Port.checkWalletStatus () )

        InvalidateAccount ->
            ( model, Port.invalidateAccount () )

        UpdateLanguage language ->
            ( { model | language = language }, Cmd.none )

        UpdateScatterResponse resp ->
            ( { model | notification = resp |> decodeScatterResponse }, Cmd.none )

        UpdateState newState ->
            ( { model | state = newState }, Cmd.none )

        UpdateWalletStatus resp ->
            let
                ({ status } as newWallet) =
                    decodeWalletResponse resp

                newState =
                    case status of
                        Authenticated ->
                            AccountInfo

                        _ ->
                            state
            in
                ( { model | wallet = newWallet, state = newState }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions _ =
    Sub.batch
        [ Port.receiveWalletStatus UpdateWalletStatus
        , Port.receiveScatterResponse UpdateScatterResponse
        ]
