module Page.Account.EmailConfirmed exposing (Message(..), Model, initModel, update, view)

import Html exposing (Html, button, div, input, li, p, text, ul, ol, article, h1, img, h2)
import Html.Attributes exposing (class, attribute, alt, src, type_)
import Html.Events exposing (onClick, onInput)
import Navigation


-- MODEL


type alias Model =
    { confirmToken : String
    , email: String
    }


initModel : String -> Maybe String -> Model
initModel confirmToken maybeEmail =
    let
        email = 
            case maybeEmail of
                Nothing ->
                    ""

                Just emailAddr ->
                    emailAddr
    in
        { confirmToken = confirmToken
        , email = email
        }



-- UPDATES


type Message
    = Next


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case msg of
        Next ->
            ( model, Navigation.newUrl "/account/create_keys/" )



-- VIEW


view : Model -> Html Message
view model =
    div []
        [ ol [ class "progress bar" ]
            [ li [ class "done" ]
                [ text "인증하기" ]
            , li []
                [ text "키 생성" ]
            , li []
                [ text "계정생성" ]
            ]
        , article [ attribute "data-step" "2" ]
            [ h1 []
                [ img [ alt "", src "./image/symbol-complete.svg" ]
                    []
                , text "이메일 인증완료!    "
                ]
            , p []
                [ text "다음으로 넘어가주세요" ]
            , h2 []
                [ text model.email ]
            ]
        , div [ class "btn_area" ]
            [ button [ class "middle white_blue next button", type_ "button", onClick Next ]
                [ text "다음" ]
            ]
        ]
