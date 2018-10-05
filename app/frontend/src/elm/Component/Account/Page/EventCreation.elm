module Component.Account.Page.EventCreation exposing (Message(..), Model, createEosAccountBodyParams, initModel, subscriptions, update, view)

import Html exposing (Html, a, article, br, button, dd, div, dl, dt, form, h2, h3, img, input, label, li, main_, ol, p, section, span, strong, text, textarea, time, ul)
import Html.Attributes exposing (action, alt, attribute, checked, class, for, href, id, name, pattern, placeholder, src, style, title, type_, value)
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
            , AccountCreationAgreeEosConstitution
            , AccountCreationAlreadyHaveAccount
            , AccountCreationButton
            , AccountCreationConfirmEmail
            , AccountCreationEmailConfirmFailure
            , AccountCreationEmailConfirmed
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
    , emailConfirmationRequested : Bool
    , emailConfirmed : Bool
    , emailConfirmationMsg : I18n
    , agreeEosConstitution : Bool
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
    , emailConfirmationRequested = False
    , emailConfirmed = False
    , emailConfirmationMsg = EmptyMessage
    , agreeEosConstitution = False
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
    | ConfirmEmail
    | EmailConfirmationResponse (Result Http.Error Response)
    | ToggleAgreeEosConstitution
    | NotificationMessage Notification.Message
    | ChangeUrl String


update : Message -> Model -> Flags -> Language -> ( Model, Cmd Message )
update msg ({ notification } as model) flags language =
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
            ( model, createEosAccountRequest model flags language )

        NewEosAccount (Ok res) ->
            ( { model | accountRequestSuccess = True }, Navigation.newUrl "/account/created" )

        NewEosAccount (Err error) ->
            case error of
                Http.BadStatus response ->
                    ( { model
                        | accountRequestSuccess = False
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

        ConfirmEmail ->
            ( { model | emailConfirmationRequested = False }, confirmEmailRequest model flags language )

        EmailConfirmationResponse response ->
            case response of
                Ok res ->
                    ( { model | emailConfirmationRequested = True, emailConfirmed = True, emailConfirmationMsg = AccountCreationEmailConfirmed }, Cmd.none )

                Err error ->
                    ( { model | emailConfirmationRequested = True, emailConfirmed = False, emailConfirmationMsg = AccountCreationEmailConfirmFailure }, Cmd.none )

        ToggleAgreeEosConstitution ->
            ( { model | agreeEosConstitution = not model.agreeEosConstitution }, Cmd.none )

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


accountInputViews : Model -> Language -> List (Html Message)
accountInputViews { accountName, accountValidation, accountValidationMsg } language =
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


keypairGenerationViews : Model -> Language -> List (Html Message)
keypairGenerationViews { keys } language =
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


emailConfirmSection : Model -> Language -> Html Message
emailConfirmSection { emailValid, confirmTokenValid } language =
    section [ class "email verification" ]
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
            , onClick ConfirmEmail
            ]
            [ textViewI18n language Confirm ]
        ]


emailConfirmationMsgView : Model -> Language -> Html Message
emailConfirmationMsgView { emailConfirmationRequested, emailConfirmed, emailConfirmationMsg } language =
    div
        [ class
            (if emailConfirmationRequested then
                "validation bunch viewing"

             else
                "validation bunch"
            )
        ]
        [ span
            [ class
                (if emailConfirmed then
                    "true validate description"

                 else
                    "false validate description"
                )
            ]
            [ textViewI18n language emailConfirmationMsg ]
        ]


agreeEosConstitutionSection : Model -> Language -> Html Message
agreeEosConstitutionSection { agreeEosConstitution } language =
    section []
        [ input
            [ id "agreeContract"
            , type_ "checkbox"
            , checked agreeEosConstitution
            , onClick ToggleAgreeEosConstitution
            ]
            []
        , label [ for "agreeContract" ]
            [ textViewI18n language AccountCreationAgreeEosConstitution ]
        ]


okButton : Model -> Language -> Html Message
okButton { accountValidation, keyCopied, emailRequested, emailConfirmed, agreeEosConstitution } language =
    button
        [ class "ok button"
        , attribute
            (if accountValidation && keyCopied && emailRequested && emailConfirmed && agreeEosConstitution then
                "enabled"

             else
                "disabled"
            )
            ""
        , type_ "button"
        , onClick CreateEosAccount
        ]
        [ textViewI18n language AccountCreationButton ]


view : Model -> Language -> Html Message
view ({ agreeEosConstitution, notification } as model) language =
    main_ [ class "join" ]
        [ article []
            [ h2 []
                [ textViewI18n language AccountCreation ]
            , p []
                [ textViewI18n language AccountCreationNameCondition ]
            , div [ class "container" ]
                (accountInputViews model language)
            , div [ class "container" ]
                (keypairGenerationViews model language)
            , h3 []
                [ textViewI18n language AccountCreationConfirmEmail ]
            , div [ class "container" ]
                [ emailConfirmSection model language
                , emailConfirmationMsgView model language
                ]
            , div [ class "confirm area" ]
                [ agreeEosConstitutionSection model language
                , okButton model language
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
    { message : String }


decodeResponseBodyMsg : Http.Response String -> String
decodeResponseBodyMsg response =
    case decodeString responseDecoder response.body of
        Ok body ->
            body.message

        Err body ->
            body


responseDecoder : Decoder Response
responseDecoder =
    decode Response
        |> required "message" string


confirmEmailRequest : Model -> Flags -> Language -> Cmd Message
confirmEmailRequest { confirmToken } flags language =
    let
        url =
            Urls.confirmEmailUrl flags confirmToken (toLocale language)
    in
    Http.send EmailConfirmationResponse <|
        Http.post url Http.emptyBody responseDecoder


createEosAccountBodyParams : Model -> Http.Body
createEosAccountBodyParams { accountName, keys } =
    Encode.object
        [ ( "account_name", Encode.string accountName )
        , ( "pubkey", Encode.string keys.publicKey )
        ]
        |> Http.jsonBody


postCreateEosAccount : Model -> Flags -> Language -> Http.Request Response
postCreateEosAccount ({ confirmToken } as model) flags language =
    let
        url =
            Urls.createEosAccountUrl flags confirmToken (toLocale language)

        params =
            createEosAccountBodyParams model
    in
    Http.post url params responseDecoder


createEosAccountRequest : Model -> Flags -> Language -> Cmd Message
createEosAccountRequest model flags language =
    Http.send NewEosAccount <| postCreateEosAccount model flags language


createUserBodyParams : Model -> Http.Body
createUserBodyParams { email } =
    Encode.object [ ( "email", Encode.string email ) ]
        |> Http.jsonBody


postUsers : Model -> Flags -> Language -> Http.Request Response
postUsers model flags language =
    Http.post (Urls.usersApiUrl flags (toLocale language)) (createUserBodyParams model) responseDecoder


createUserRequest : Model -> Flags -> Language -> Cmd Message
createUserRequest model flags language =
    Http.send NewUser <| postUsers model flags language



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
