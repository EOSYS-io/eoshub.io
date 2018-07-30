module Component.Account.Page.ConfirmEmail exposing (Message(..), Model, createUserBodyParams, initModel, update, view)

import Html exposing (Html, button, div, input, li, p, text, ul, ol, article, h1, img, a, form, span, node)
import Html.Attributes exposing (placeholder, class, alt, src, action, href, attribute, type_, rel)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Json.Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Util.Flags exposing (Flags)
import Util.Urls as Urls
import Validate exposing (Validator, ifInvalidEmail, ifBlank, validate)
import Array.Hamt as Array exposing (Array)
import View.Notification as Notification
import Translation exposing (Language, toLocale, I18n(EmptyMessage, ConfirmEmailSent, AlreadyExistEmail, DebugMessage))
import Navigation as Navigation


-- MODEL


type alias Model =
    { email : String
    , validationMsg : String
    , requested : Bool
    , emailValid : Bool
    , inputValid : String
    , notification : Notification.Model
    }


initModel : Model
initModel =
    { email = ""
    , validationMsg = "Please enter an email address."
    , requested = False
    , emailValid = False
    , inputValid = "invalid"
    , notification = Notification.initModel
    }



-- UPDATES


type Message
    = ValidateEmail String
    | CreateUser
    | NewUser (Result Http.Error Response)
    | NotificationMessage Notification.Message
    | ChangeUrl String


update : Message -> Model -> Flags -> Language -> ( Model, Cmd Message )
update msg ({ notification } as model) flags language =
    case msg of
        ValidateEmail email ->
            let
                newModel =
                    { model | email = email }

                ( validationMsg, emailValid ) =
                    validation newModel

                inputValid =
                    if emailValid then
                        "valid"
                    else
                        "invalid"
            in
                ( { newModel | validationMsg = validationMsg, emailValid = emailValid, inputValid = inputValid }, Cmd.none )

        CreateUser ->
            ( { model | requested = True }, createUserRequest model flags language )

        NewUser (Ok res) ->
            ( { model
                | notification =
                    { content = Notification.Ok { message = ConfirmEmailSent, detail = EmptyMessage }
                    , open = True
                    }
              }
            , Cmd.none
            )

        NewUser (Err error) ->
            case error of
                Http.BadStatus response ->
                    ( { model
                        | requested = False
                        , notification =
                            { content = Notification.Error { message = AlreadyExistEmail, detail = EmptyMessage }
                            , open = True
                            }
                      }
                    , Cmd.none
                    )

                Http.BadPayload debugMsg response ->
                    ( { model
                        | requested = False
                        , notification =
                            { content = Notification.Error { message = AlreadyExistEmail, detail = DebugMessage ("debugMsg: " ++ debugMsg ++ ", body: " ++ response.body) }
                            , open = True
                            }
                      }
                    , Cmd.none
                    )

                _ ->
                    ( { model
                        | requested = False
                        , notification =
                            { content = Notification.Error { message = AlreadyExistEmail, detail = DebugMessage (toString error) }
                            , open = True
                            }
                      }
                    , Cmd.none
                    )

        NotificationMessage Notification.CloseNotification ->
            ( { model
                | notification =
                    { notification | open = False }
              }
            , Cmd.none
            )

        ChangeUrl url ->
            ( model, Navigation.newUrl url )



-- VIEW


view : Model -> Language -> Html Message
view { validationMsg, requested, emailValid, inputValid, notification } language =
    div [ class "container join" ]
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
                [ text "새로운 계정을 만들기 위해 이메일을 인증하세요!    " ]
            , p []
                [ text "받으신 메일의 링크를 클릭해주세요." ]
            , form [ onSubmit CreateUser ]
                [ input
                    [ placeholder "example@email.com"
                    , attribute "required" ""
                    , type_ "email"
                    , attribute inputValid ""
                    , onInput ValidateEmail
                    ]
                    []
                , span [ class "validate" ]
                    [ text validationMsg ]
                ]
            ]
        , div [ class "btn_area" ]
            [ button
                [ class "middle white_blue send_email button"
                , attribute
                    (if not requested && emailValid then
                        "enabled"
                     else
                        "disabled"
                    )
                    ""
                , type_ "button"
                , onClick CreateUser
                ]
                [ text "링크 보내기" ]
            ]
        , p [ class "exist_account" ]
            [ text "이미 이오스 계정이 있으신가요?"
            , a [ onClick (ChangeUrl "/") ]
                [ text "로그인하기" ]
            ]
        , Html.map NotificationMessage (Notification.view notification language)
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


postUsers : Model -> Flags -> Language -> Http.Request Response
postUsers model flags language =
    Http.post (Urls.usersApiUrl flags (toLocale language)) (createUserBodyParams model) responseDecoder


createUserRequest : Model -> Flags -> Language -> Cmd Message
createUserRequest model flags language =
    Http.send NewUser <| postUsers model flags language



-- VALIDATION


modelValidator : Validator String Model
modelValidator =
    Validate.all
        [ Validate.firstError
            [ ifBlank .email "이메일을 입력해주세요."
            , ifInvalidEmail .email (\_ -> "잘못된 이메일 주소입니다.")
            ]
        ]


validation : Model -> ( String, Bool )
validation model =
    case Array.get 0 (Array.fromList (validate modelValidator model)) of
        Nothing ->
            ( "올바른 이메일 주소입니다.", True )

        Just msg ->
            ( msg, False )
