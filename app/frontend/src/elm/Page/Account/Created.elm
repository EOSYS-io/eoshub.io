module Page.Account.Created exposing (Message(..), Model, initModel, update, view)

import Html exposing (Html, button, div, h1, text, ol, li, h1, br, p, article, img, a)
import Html.Attributes exposing (class, attribute, alt, src, href)
import Html.Events exposing (onClick)
import Navigation


-- MODEL


type alias Model =
    {}


initModel : Model
initModel =
    {}



-- UPDATES


type Message
    = Home


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case msg of
        Home ->
            ( model, Navigation.newUrl("/") )



-- VIEW


view : Model -> Html Message
view model =
    div [ class "container join" ]
        [ ol [ class "progress bar" ]
            [ li [ class "done" ]
                [ text "인증하기" ]
            , li [ class "done" ]
                [ text "키 생성" ]
            , li [ class "done" ]
                [ text "계정생성" ]
            ]
        , article [ attribute "data-step" "5" ]
            [ h1 [ class "finished" ]
                [ text "축하합니다! 새로운 계정을 만들었어요!"
                , br []
                    []
                , text "        정식 주민이 된 것을 환영합니다!"
                ]
            , p []
                [ text "이제 홈에서 로그인하실 수 있어요!" ]
            , img [ alt "", class "finished icon", src "./image/group-18.svg" ]
                []
            ]
        , div [ class "btn_area" ]
            [ a [ class "middle button blue_white", onClick Home ]
                [ text "홈 화면 바로가기" ]
            ]
        ]
