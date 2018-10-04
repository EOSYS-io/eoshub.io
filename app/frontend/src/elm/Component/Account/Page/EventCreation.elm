module Component.Account.Page.EventCreation exposing (Message(..), Model, createEosAccountBodyParams, initModel, subscriptions, update, view)

import Html exposing (Html, a, article, br, button, dd, div, dl, dt, form, h2, h3, img, input, label, li, main_, ol, p, section, span, strong, text, textarea, time, ul)
import Html.Attributes exposing (action, alt, attribute, class, for, href, id, name, pattern, placeholder, src, style, title, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Json.Decode exposing (Decoder, decodeString, string)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Navigation
import Port exposing (KeyPair)
import Translation
    exposing
        ( I18n
            ( AccountCreation
            , AccountCreationAlreadyHaveAccount
            , AccountCreationClickConfirmLink
            , AccountCreationConfirmEmail
            , AccountCreationEmailInvalid
            , AccountCreationEmailValid
            , AccountCreationEnterEmail
            , AccountCreationEnterVerificationCode
            , AccountCreationFailure
            , AccountCreationInput
            , AccountCreationKeypairCaution
            , AccountCreationKeypairGeneration
            , AccountCreationKeypairRegenerate
            , AccountCreationLoginLink
            , AccountCreationNameCondition
            , AccountCreationNameConditionExample
            , AccountCreationNameInvalid
            , AccountCreationNamePlaceholder
            , AccountCreationNameValid
            , AccountCreationProgressCreateNew
            , AccountCreationProgressEmail
            , AccountCreationProgressKeypair
            , AccountCreationSendEmail
            , Confirm
            , ConfirmEmailSent
            , CopyAll
            , DebugMessage
            , EmptyMessage
            , Next
            , PrivateKey
            , PublicKey
            , UnknownError
            )
        , Language
        , toLocale
        , translate
        )
import Util.Flags exposing (Flags)
import Util.Urls as Urls
import Util.Validation exposing (checkAccountName, checkConfirmToken)
import Validate exposing (isValidEmail)
import View.I18nViews exposing (textViewI18n)
import View.Notification as Notification



-- MODEL


type alias Model =
    { accountName : String
    , accountValidation : Bool
    , accountValidationMsg : I18n
    , accountRequestSuccess : Bool
    , keys : KeyPair
    , keyCopied : Bool
    , email : String
    , emailValidationMsg : I18n
    , emailRequested : Bool
    , emailValid : Bool
    , confirmToken : String
    , confirmTokenValid : Bool
    , notification : Notification.Model
    }


initModel : Model
initModel =
    { accountName = ""
    , accountValidation = False
    , accountValidationMsg = EmptyMessage
    , accountRequestSuccess = False
    , keys = { privateKey = "", publicKey = "" }
    , keyCopied = False
    , email = ""
    , emailValidationMsg = EmptyMessage
    , emailRequested = False
    , emailValid = False
    , confirmToken = ""
    , confirmTokenValid = False
    , notification = Notification.initModel
    }



-- UPDATES


type Message
    = ValidateAccountName String
    | CreateEosAccount
    | NewEosAccount (Result Http.Error Response)
    | GenerateKeys
    | UpdateKeys KeyPair
    | Copy
    | ValidateEmail String
    | CreateUser
    | NewUser (Result Http.Error Response)
    | ValidateConfirmToken String
    | NotificationMessage Notification.Message
    | ChangeUrl String


update : Message -> Model -> Flags -> Language -> ( Model, Cmd Message )
update msg ({ confirmToken, notification } as model) flags language =
    case msg of
        GenerateKeys ->
            ( model, Port.generateKeys () )

        UpdateKeys keyPair ->
            ( { model | keys = keyPair }, Cmd.none )

        Copy ->
            ( { model | keyCopied = True }, Port.copy () )

        ValidateAccountName accountName ->
            let
                newModel =
                    { model | accountName = accountName }

                ( validateMsg, validate ) =
                    if checkAccountName accountName then
                        ( AccountCreationNameValid, True )

                    else
                        ( AccountCreationNameInvalid, False )
            in
            ( { newModel | accountValidation = validate, accountValidationMsg = validateMsg }, Cmd.none )

        CreateEosAccount ->
            ( model, createEosAccountRequest model flags confirmToken language )

        NewEosAccount (Ok res) ->
            ( { model | accountRequestSuccess = True }, Navigation.newUrl "/account/created" )

        NewEosAccount (Err error) ->
            case error of
                Http.BadStatus response ->
                    ( { model
                        | accountRequestSuccess = False
                        , notification =
                            { content = Notification.Error { message = AccountCreationFailure, detail = EmptyMessage }
                            , open = True
                            }
                      }
                    , Cmd.none
                    )

                Http.BadPayload debugMsg response ->
                    ( { model
                        | accountRequestSuccess = False
                        , notification =
                            { content = Notification.Error { message = AccountCreationFailure, detail = DebugMessage ("debugMsg: " ++ debugMsg ++ ", body: " ++ response.body) }
                            , open = True
                            }
                      }
                    , Cmd.none
                    )

                _ ->
                    ( { model
                        | accountRequestSuccess = False
                        , notification =
                            { content = Notification.Error { message = AccountCreationFailure, detail = DebugMessage (toString error) }
                            , open = True
                            }
                      }
                    , Cmd.none
                    )

        ValidateEmail email ->
            let
                newModel =
                    { model | email = email }

                ( validationMsg, emailValid ) =
                    if String.isEmpty email then
                        ( EmptyMessage, False )

                    else
                        emailValidation newModel

                inputValid =
                    if emailValid then
                        "valid"

                    else
                        "invalid"
            in
            ( { newModel | emailValidationMsg = validationMsg, emailValid = emailValid }, Cmd.none )

        CreateUser ->
            ( { model | emailRequested = True }, createUserRequest model flags language )

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
                        | emailRequested = False
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
                        | emailRequested = False
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
                        | emailRequested = False
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

        ValidateConfirmToken confirmToken ->
            ( { model | confirmToken = confirmToken, confirmTokenValid = checkConfirmToken confirmToken }, Cmd.none )

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


accountInput : Model -> Language -> List (Html Message)
accountInput { accountName, accountValidation, accountValidationMsg } language =
    [ h3 []
        [ textViewI18n language AccountCreationInput ]
    , input
        [ class "account_name"
        , placeholder (translate language AccountCreationNamePlaceholder)
        , attribute "required" ""
        , attribute
            (if accountValidation then
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
        , class
            (if accountValidation then
                "true validate"

             else
                "false validate"
            )
        ]
        [ textViewI18n language accountValidationMsg ]
    ]


keypairGenerationView : Model -> Language -> List (Html Message)
keypairGenerationView { keys } language =
    [ h3 []
        [ textViewI18n language AccountCreationKeypairGeneration ]
    , dl [ class "keybox" ]
        [ dt []
            [ textViewI18n language PublicKey ]
        , dd []
            [ text keys.publicKey ]
        , dt []
            [ textViewI18n language PrivateKey ]
        , dd []
            [ text keys.privateKey ]
        ]
    , textarea [ class "hidden_copy_field", id "key", attribute "wai-aria" "hidden" ]
        [ text ("PublicKey:" ++ keys.publicKey ++ " \nPrivateKey:" ++ keys.privateKey) ]
    , button [ class "refresh button", type_ "button", onClick GenerateKeys ]
        [ textViewI18n language AccountCreationKeypairRegenerate ]
    , div [ class "btn_area" ]
        [ button [ class "copy button", id "copy", type_ "button", onClick Copy ]
            [ textViewI18n language CopyAll ]
        ]
    , p [ class "important description" ]
        [ textViewI18n language AccountCreationKeypairCaution ]
    ]


emailConfirmInput : Model -> Language -> List (Html Message)
emailConfirmInput { emailValid, confirmTokenValid } language =
    [ input
        [ name ""
        , pattern "[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,4}$"
        , placeholder (translate language AccountCreationEnterEmail)
        , type_ "email"
        , onInput ValidateEmail
        ]
        []
    , button
        [ class "action button"
        , id "sendCode"
        , type_ "button"
        , onClick CreateUser
        , attribute
            (if emailValid then
                "enabled"

             else
                "disabled"
            )
            ""
        ]
        [ textViewI18n language AccountCreationSendEmail ]
    , input
        [ id "inputCode"
        , name ""
        , placeholder (translate language AccountCreationEnterVerificationCode)
        , type_ "text"
        , onInput ValidateConfirmToken
        ]
        []
    , button
        [ class "action button"
        , attribute
            (if confirmTokenValid then
                "enabled"

             else
                "disabled"
            )
            ""
        , id "inputCodeValidate"
        , type_ "button"
        ]
        [ textViewI18n language Confirm ]
    ]


view : Model -> Language -> Html Message
view ({ accountValidation, accountName, accountValidationMsg, accountRequestSuccess, email, emailValid, emailValidationMsg, confirmToken, confirmTokenValid, notification } as model) language =
    main_ [ class "join" ]
        [ article []
            [ h2 []
                [ textViewI18n language AccountCreation ]
            , p []
                [ textViewI18n language AccountCreationNameCondition ]
            , div [ class "container" ]
                (accountInput model language)
            , div [ class "container" ]
                (keypairGenerationView model language)
            , h3 []
                [ textViewI18n language AccountCreationConfirmEmail ]
            , div [ class "container" ]
                [ section [ class "email verification" ]
                    (emailConfirmInput model language)
                , div [ class "validation bunch" ]
                    [ span [ class "description" ]
                        [ time []
                            [ text "3:00" ]
                        , text "안으로 코드를 입력해주세요.  "
                        ]
                    , span [ class "false validate description" ]
                        [ text "일치하지 않는 코드입니다." ]
                    , span [ class "true validate description" ]
                        [ text "이메일 인증이 완료됐습니다." ]
                    , button [ class "re_send button", type_ "button" ]
                        [ text "코드 재전송" ]
                    ]
                ]
            , div [ class "confirm area" ]
                [ section []
                    [ input [ id "agreeContract", type_ "checkbox" ]
                        []
                    , label [ for "agreeContract" ]
                        [ text "EOS Consitution에 동의합니다." ]
                    ]
                , button [ class "ok button", attribute "disabled" "", type_ "button" ]
                    [ text "생성하기" ]
                ]
            , p [ class "exist_account" ]
                [ textViewI18n language AccountCreationAlreadyHaveAccount
                , a [ onClick (ChangeUrl "/") ]
                    [ textViewI18n language AccountCreationLoginLink ]
                ]
            ]
        ]



-- HTTP


type alias Response =
    { msg : String }


accountResponseDecoder : Decoder Response
accountResponseDecoder =
    decode Response
        |> required "msg" string


createEosAccountBodyParams : Model -> Http.Body
createEosAccountBodyParams model =
    Encode.object
        [ ( "account_name", Encode.string model.accountName )
        , ( "pubkey", Encode.string model.keys.publicKey )
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
    Http.post url params accountResponseDecoder


createEosAccountRequest : Model -> Flags -> String -> Language -> Cmd Message
createEosAccountRequest model flags confirmToken language =
    Http.send NewEosAccount <| postCreateEosAccount model flags confirmToken language


emailResponseDecoder : Decoder Response
emailResponseDecoder =
    decode Response
        |> required "msg" string


createUserBodyParams : Model -> Http.Body
createUserBodyParams model =
    Encode.object [ ( "email", Encode.string model.email ) ]
        |> Http.jsonBody


postUsers : Model -> Flags -> Language -> Http.Request Response
postUsers model flags language =
    Http.post (Urls.usersApiUrl flags (toLocale language)) (createUserBodyParams model) emailResponseDecoder


createUserRequest : Model -> Flags -> Language -> Cmd Message
createUserRequest model flags language =
    Http.send NewUser <| postUsers model flags language


decodeResponseBodyMsg : Http.Response String -> String
decodeResponseBodyMsg response =
    case decodeString emailResponseDecoder response.body of
        Ok body ->
            body.msg

        Err body ->
            body



-- VALIDATION


emailValidation : Model -> ( I18n, Bool )
emailValidation { email } =
    if isValidEmail email then
        ( AccountCreationEmailValid, True )

    else
        ( AccountCreationEmailInvalid, False )



-- SUBSCRIPTIONS


subscriptions : Sub Message
subscriptions =
    Port.receiveKeys UpdateKeys
