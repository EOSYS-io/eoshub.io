module Component.Account.Page.ConfirmEmail exposing (Message(..), Model, createUserBodyParams, initModel, update, view)

import Html exposing (Html, a, article, button, div, form, h2, img, input, li, main_, node, ol, p, span, text, ul)
import Html.Attributes exposing (action, alt, attribute, class, href, placeholder, rel, src, type_)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Json.Decode exposing (Decoder, decodeString, string)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Navigation as Navigation
import Translation
    exposing
        ( I18n
            ( AccountCreationAlreadyHaveAccount
            , AccountCreationClickConfirmLink
            , AccountCreationConfirmEmail
            , AccountCreationEmailInvalid
            , AccountCreationEmailValid
            , AccountCreationLoginLink
            , AccountCreationProgressCreateNew
            , AccountCreationProgressEmail
            , AccountCreationProgressKeypair
            , AccountCreationSendEmail
            , ConfirmEmailSent
            , DebugMessage
            , EmptyMessage
            , UnknownError
            )
        , Language
        , toLocale
        )
import Util.Flags exposing (Flags)
import Util.Urls as Urls
import Validate exposing (isValidEmail)
import View.I18nViews exposing (textViewI18n)
import View.Notification as Notification



-- MODEL


type alias Model =
    { email : String
    , validationMsg : I18n
    , requested : Bool
    , emailValid : Bool
    , inputValid : String
    , notification : Notification.Model
    }


initModel : Model
initModel =
    { email = ""
    , validationMsg = EmptyMessage
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
                    if String.isEmpty email then
                        ( EmptyMessage, False )

                    else
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
                            { content =
                                Notification.Error
                                    { message = DebugMessage (decodeResponseBodyMsg response)
                                    , detail = EmptyMessage
                                    }
                            , open = True
                            }
                      }
                    , Cmd.none
                    )

                Http.BadPayload debugMsg response ->
                    ( { model
                        | requested = False
                        , notification =
                            { content =
                                Notification.Error
                                    { message = DebugMessage (decodeResponseBodyMsg response)
                                    , detail = DebugMessage ("debugMsg: " ++ debugMsg ++ ", body: " ++ response.body)
                                    }
                            , open = True
                            }
                      }
                    , Cmd.none
                    )

                _ ->
                    ( { model
                        | requested = False
                        , notification =
                            { content =
                                Notification.Error
                                    { message = UnknownError
                                    , detail = DebugMessage (toString error)
                                    }
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


decodeResponseBodyMsg : Http.Response String -> String
decodeResponseBodyMsg response =
    case decodeString responseDecoder response.body of
        Ok body ->
            body.msg

        Err body ->
            body



-- VIEW


emailInput : Model -> Html Message
emailInput { inputValid } =
    input
        [ placeholder "example@email.com"
        , attribute "required" ""
        , type_ "email"
        , attribute inputValid ""
        , onInput ValidateEmail
        ]
        []


emailForm : Model -> Language -> List (Html Message)
emailForm ({ inputValid, validationMsg } as model) language =
    if validationMsg == EmptyMessage then
        [ emailInput model ]

    else
        [ emailInput model
        , span [ class "validate" ]
            [ textViewI18n language validationMsg ]
        ]


view : Model -> Language -> Html Message
view ({ validationMsg, requested, emailValid, inputValid, notification } as model) language =
    main_ [ class "join" ]
        [ article [ attribute "data-step" "validate-email" ]
            [ h2 []
                [ textViewI18n language AccountCreationConfirmEmail ]
            , p []
                [ textViewI18n language AccountCreationClickConfirmLink ]
            , form [ onSubmit CreateUser ]
                (emailForm model language)
            , div [ class "btn_area" ]
                [ button
                    [ type_ "button"
                    , class "send_email ok button"
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
                    [ textViewI18n language AccountCreationSendEmail ]
                ]
            , p [ class "exist_account" ]
                [ textViewI18n language AccountCreationAlreadyHaveAccount
                , a [ onClick (ChangeUrl "/") ]
                    [ textViewI18n language AccountCreationLoginLink ]
                ]
            , Html.map NotificationMessage (Notification.view notification language)
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


postUsers : Model -> Flags -> Language -> Http.Request Response
postUsers model flags language =
    Http.post (Urls.usersApiUrl flags (toLocale language)) (createUserBodyParams model) responseDecoder


createUserRequest : Model -> Flags -> Language -> Cmd Message
createUserRequest model flags language =
    Http.send NewUser <| postUsers model flags language



-- VALIDATION


validation : Model -> ( I18n, Bool )
validation { email } =
    if isValidEmail email then
        ( AccountCreationEmailValid, True )

    else
        ( AccountCreationEmailInvalid, False )
