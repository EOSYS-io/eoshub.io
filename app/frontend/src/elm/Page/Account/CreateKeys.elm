module Page.Account.CreateKeys exposing (Message(..), Model, initModel, subscriptions, update, view)

import Html exposing (Html, button, div, h1, p, text, ol, li, article, img, dl, dt, dd, textarea, node)
import Html.Attributes exposing (class, attribute, alt, src, id, type_)
import Html.Events exposing (onClick)
import Navigation
import Port exposing (KeyPair)


-- MODEL


type alias Model =
    { keys : KeyPair
    , nextEnabled : Bool
    }


initModel : Model
initModel =
    { keys = { privateKey = "", publicKey = "" }
    , nextEnabled = False
    }



-- UPDATES


type Message
    = Next
    | GenerateKeys
    | UpdateKeys KeyPair
    | Copy


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case msg of
        Next ->
            ( model, Navigation.newUrl ("/account/create/" ++ model.keys.publicKey) )

        GenerateKeys ->
            ( model, Port.generateKeys () )

        UpdateKeys keyPair ->
            ( { model | keys = keyPair }, Cmd.none )

        Copy ->
            ( { model | nextEnabled = True }, Port.copy () )



-- VIEW


view : Model -> Html Message
view model =
    div [ class "container join" ]
        [ ol [ class "progress bar" ]
            [ li [ class "done" ]
                [ text "인증하기" ]
            , li [ class "ing" ]
                [ text "키 생성" ]
            , li []
                [ text "계정생성" ]
            ]
        , article [ attribute "data-step" "3" ]
            [ h1 []
                [ text "키 쌍을 만들었어요. 꼭 안전한 곳에 복사해두세요!    " ]
            , p []
                [ text "계정을 증명할 중요한 정보니 복사하여 안전하게 보관하세요!" ]
            , dl [ class "keybox" ]
                [ dt []
                    [ text "공개 키" ]
                , dd []
                    [ text model.keys.publicKey ]
                , dt []
                    [ text "개인 키" ]
                , dd []
                    [ text model.keys.privateKey ]
                ]
            , textarea [ class "hidden_copy_field", id "key", attribute "wai-aria" "hidden" ]
                [ text ("PublicKey:" ++ model.keys.publicKey ++ "\nPrivateKey:" ++ model.keys.privateKey) ]
            , button [ class "button middle copy blue_white", id "copy", type_ "button", onClick Copy ]
                [ text "한번에 복사하기" ]
            ]
        , div [ class "btn_area" ]
            [ button
                [ class "middle white_blue button"
                , attribute
                    (if model.nextEnabled then
                        "enabled"
                     else
                        "disabled"
                    )
                    ""
                , id "next"
                , type_ "button"
                , onClick Next
                ]
                [ text "다음" ]
            ]
        ]



-- SUBSCRIPTIONS


subscriptions : Sub Message
subscriptions =
    Port.receiveKeys UpdateKeys
