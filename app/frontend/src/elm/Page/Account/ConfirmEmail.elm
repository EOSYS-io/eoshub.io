module Page.Account.ConfirmEmail exposing (Message(..), Model, createUserBodyParams, initModel, update, view)

import Html exposing (Html, button, div, input, li, p, text, ul, ol, article, h1, img, a, form, span, node)
import Html.Attributes exposing (placeholder, class, alt, src, action, href, attribute, type_, rel)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Util.Flags exposing (Flags)
import Util.Urls as Urls
import Validate exposing (Validator, ifInvalidEmail, ifBlank, validate)
import Array.Hamt as Array exposing (Array)


-- MODEL


type alias Model =
    { email : String
    , validationMsg : String
    , sendEnable : Bool
    , requestStatus : Response
    , requestSuccess : Bool }


initModel : Model
initModel =
    { email = ""
    , validationMsg = "Please enter an email address."
    , sendEnable = False
    , requestStatus = { msg = "" }
    , requestSuccess = False }



-- UPDATES


type Message
    = ValidateEmail String
    | CreateUser
    | NewUser (Result Http.Error Response)


update : Message -> Model -> Flags -> ( Model, Cmd Message )
update msg model flags =
    case msg of
        ValidateEmail email ->
            let
                ( validateMsg, sendEnable ) =
                    case Array.get 0 (Array.fromList (validation model)) of
                        Nothing ->
                            ( "", True )

                        Just msg ->
                            ( msg, False )
            in
                ( { model | email = email, validationMsg = validateMsg, sendEnable = sendEnable }, Cmd.none )

        CreateUser ->
            ( { model | sendEnable = False }, createUserRequest model flags )

        NewUser (Ok res) ->
            ( { model | validationMsg = "이메일을 확인해주세요!", requestStatus = res, requestSuccess = True, sendEnable = True }, Cmd.none )

        NewUser (Err error) ->
            ( { model | validationMsg = "이미 존재하는 이메일입니다.", requestStatus = { msg = toString error }, requestSuccess = False, sendEnable = True }, Cmd.none )



-- VIEW


view : Model -> Html Message
view model =
    div []
        [ ol [ class "progress bar" ]
            [ li [ class "ing" ]
                [ text "인증하기" ]
            , li []
                [ text "키 생성" ]
            , li []
                [ text "계정생성" ]
            ]
        , article [ attribute "data-step" "1" ]
            [ h1 []
                [ img [ alt "", src "./image/symbol-smile.svg" ]
                    []
                , text "새로운 계정을 만들기 위해 이메일을 인증하세요!    "
                ]
            , p []
                [ text "받으신 메일의 링크를 클릭해주세요." ]
            , form [ action "" ]
                [ text "        "
                , input [ placeholder "example@email.com", attribute "required" "", type_ "email", attribute (if model.requestSuccess then "valid" else "invalid") "", onInput ValidateEmail ]
                    []
                , span [ class "validate" ]
                    [ text model.validationMsg ]
                ]
            ]
        , div [ class "btn_area" ]
            [ button [ class "middle white_blue send_email button", attribute (if model.sendEnable then
                            "enabled"
                        else
                            "disabled"
                        ) "", type_ "button" ]
                [ text "링크 보내기" ]
            ]
        , p [ class "exist_account" ]
            [ text "이미 이오스 계정이 있으신가요?    "
            , a [ href "#" ]
                [ text "로그인하기" ]
            ]
        ]



-- HTTP


type alias Response =
    { msg : String }


responseDecoder : Decoder Response
responseDecoder =
    decode Response
        |> required "msg" string


createUserBodyParams : Model -> Http.Body
createUserBodyParams model =
    Encode.object [ ( "email", Encode.string model.email ) ]
        |> Http.jsonBody


postUsers : Model -> Flags -> Http.Request Response
postUsers model flags =
    Http.post (Urls.usersApiUrl flags) (createUserBodyParams model) responseDecoder


createUserRequest : Model -> Flags -> Cmd Message
createUserRequest model flags =
    Http.send NewUser <| postUsers model flags



-- VALIDATION


modelValidator : Validator String Model
modelValidator =
    Validate.all
        [ Validate.firstError
            [ ifBlank .email "Please enter an email address."
            , ifInvalidEmail .email (\_ -> "Please enter a valid email address.")
            ]
        ]


validation : Model -> List String
validation model =
    validate modelValidator model
