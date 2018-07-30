module Component.Account.Page.Create exposing (Message(..), Model, createEosAccountBodyParams, initModel, update, view)

import Html exposing (Html, button, div, input, li, p, text, ul, ol, h1, img, text, br, form, article, span)
import Html.Attributes exposing (placeholder, class, attribute, alt, src, type_, style, action)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Json.Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Util.Flags exposing (Flags)
import Util.Urls as Urls
import Navigation
import Util.Validation exposing (checkAccountName)
import View.Notification as Notification
import Translation exposing (Language, toLocale, I18n(EmptyMessage, DebugMessage, AccountCreationFailure))


-- MODEL


type alias Model =
    { accountName : String
    , pubkey : String
    , validation : Bool
    , validationMsg : String
    , requestSuccess : Bool
    , notification : Notification.Model
    }


initModel : String -> Model
initModel pubkey =
    { accountName = ""
    , pubkey = pubkey
    , validation = False
    , validationMsg = ""
    , requestSuccess = False
    , notification = Notification.initModel
    }



-- UPDATES


type Message
    = ValidateAccountName String
    | CreateEosAccount
    | NewUser (Result Http.Error Response)
    | NotificationMessage Notification.Message


update : Message -> Model -> Flags -> String -> Language -> ( Model, Cmd Message )
update msg ({ notification } as model) flags confirmToken language =
    case msg of
        ValidateAccountName accountName ->
            let
                newModel =
                    { model | accountName = accountName }

                ( validateMsg, validate ) =
                    if checkAccountName accountName then
                        ( "가능한 ID에요", True )
                    else
                        ( "불가능한 ID에요", False )
            in
                ( { newModel | validation = validate, validationMsg = validateMsg }, Cmd.none )

        CreateEosAccount ->
            ( model, createEosAccountRequest model flags confirmToken language )

        NewUser (Ok res) ->
            ( { model | requestSuccess = True }, Navigation.newUrl ("/account/created") )

        NewUser (Err error) ->
            case error of
                Http.BadStatus response ->
                    ( { model
                        | requestSuccess = False
                        , notification =
                            { content = Notification.Error { message = AccountCreationFailure, detail = EmptyMessage }
                            , open = True
                            }
                      }
                    , Cmd.none
                    )

                Http.BadPayload debugMsg response ->
                    ( { model
                        | requestSuccess = False
                        , notification =
                            { content = Notification.Error { message = AccountCreationFailure, detail = DebugMessage ("debugMsg: " ++ debugMsg ++ ", body: " ++ response.body) }
                            , open = True
                            }
                      }
                    , Cmd.none
                    )

                _ ->
                    ( { model
                        | requestSuccess = False
                        , notification =
                            { content = Notification.Error { message = AccountCreationFailure, detail = DebugMessage (toString error) }
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



-- VIEW


view : Model -> Language -> Html Message
view { validation, accountName, validationMsg, requestSuccess, notification } language =
    div [ class "container join" ]
        [ ol [ class "progress bar" ]
            [ li [ class "done" ]
                [ text "인증하기" ]
            , li [ class "done" ]
                [ text "키 생성" ]
            , li [ class "ing" ]
                [ text "계정생성" ]
            ]
        , article [ attribute "data-step" "4" ]
            [ h1 []
                [ text "원하는 계정의 이름을 입력해주세요!    " ]
            , p []
                [ text "계정명은 1~5 사이의 숫자와 영어 소문자의 조합으로 12글자만 가능합니다!"
                , br []
                    []
                , text "ex) eoshuby12345"
                ]
            , form [ onSubmit CreateEosAccount ]
                [ input
                    [ class "account_name"
                    , placeholder "계정이름은 반드시 12글자로 입력해주세요"
                    , attribute "required" ""
                    , attribute
                        (if validation then
                            "valid"
                         else
                            "invalid"
                        )
                        ""
                    , type_ "text"
                    , onInput ValidateAccountName
                    ]
                    []
                , span
                    [ style
                        [ ( "visibility"
                          , if String.isEmpty accountName then
                                "hidden"
                            else
                                "visible"
                          )
                        ]
                    ]
                    [ text validationMsg ]
                ]
            ]
        , div [ class "btn_area" ]
            [ button
                [ class "middle blue_white button"
                , attribute
                    (if validation && not requestSuccess then
                        "enabled"
                     else
                        "disabled"
                    )
                    ""
                , type_ "button"
                , onClick CreateEosAccount
                ]
                [ text "다음" ]
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


createEosAccountBodyParams : Model -> Http.Body
createEosAccountBodyParams model =
    Encode.object
        [ ( "account_name", Encode.string model.accountName )
        , ( "pubkey", Encode.string model.pubkey )
        ]
        |> Http.jsonBody


postCreateEosAccount : Model -> Flags -> String -> Language -> Http.Request Response
postCreateEosAccount model flags confirmToken language =
    let
        url =
            Urls.createEosAccountUrl flags confirmToken (toLocale language)

        params =
            createEosAccountBodyParams model
    in
        Http.post url params responseDecoder


createEosAccountRequest : Model -> Flags -> String -> Language -> Cmd Message
createEosAccountRequest model flags confirmToken language =
    Http.send NewUser <| postCreateEosAccount model flags confirmToken language
