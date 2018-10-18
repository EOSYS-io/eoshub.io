module Component.Account.Page.EventCreation exposing
    ( Message(..)
    , Model
    , createEosAccountBodyParams
    , initCmd
    , initModel
    , sendCodeBodyParams
    , subscriptions
    , update
    , view
    )

import Data.Account exposing (Account)
import Data.Json exposing (RailsResponse, railsResponseDecoder)
import Data.RailsErrorResponse exposing (decodeRailsErrorResponse)
import Html
    exposing
        ( Html
        , a
        , article
        , br
        , button
        , dd
        , div
        , dl
        , dt
        , form
        , h2
        , h3
        , img
        , input
        , label
        , li
        , main_
        , ol
        , p
        , section
        , span
        , strong
        , text
        , textarea
        , time
        , ul
        )
import Html.Attributes
    exposing
        ( action
        , alt
        , attribute
        , checked
        , class
        , disabled
        , for
        , href
        , id
        , name
        , placeholder
        , src
        , style
        , target
        , title
        , type_
        , value
        )
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
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
            , AccountCreationKeypairCopiedToClipboard
            , AccountCreationKeypairGeneration
            , AccountCreationKeypairRegenerate
            , AccountCreationLoginLink
            , AccountCreationNameAlreadyExist
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
            , EosConstitutionLink
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
import Util.HttpRequest exposing (getAccount)
import Util.Urls as Urls
import Util.Validation
    exposing
        ( AccountStatus(..)
        , VerificationRequestStatus(..)
        , checkConfirmToken
        , validateAccountForCreation
        )
import Validate exposing (isValidEmail)
import View.I18nViews exposing (textViewI18n)
import View.Notification as Notification



-- MODEL


type alias Model =
    { accountName : String
    , accountValidation : AccountStatus
    , accountRequestSuccess : Bool
    , keys : KeyPair
    , email : String
    , emailRequested : Bool
    , emailValid : Bool
    , confirmToken : String
    , confirmTokenValid : Bool
    , emailConfirmationRequested : Bool
    , emailConfirmed : Bool
    , agreeEosConstitution : Bool
    , notification : Notification.Model
    }


initModel : Model
initModel =
    { accountName = ""
    , accountValidation = EmptyAccount
    , accountRequestSuccess = False
    , keys = { privateKey = "", publicKey = "" }
    , email = ""
    , emailRequested = False
    , emailValid = False
    , confirmToken = ""
    , confirmTokenValid = False
    , emailConfirmationRequested = False
    , emailConfirmed = False
    , agreeEosConstitution = False
    , notification = Notification.initModel
    }


initCmd : Cmd Message
initCmd =
    Port.generateKeys ()



-- UPDATES


type Message
    = ValidateAccountNameInput String
    | OnFetchAccountToVerify (Result Http.Error Account)
    | CreateEosAccount
    | NewEosAccount (Result Http.Error RailsResponse)
    | GenerateKeys
    | UpdateKeys KeyPair
    | Copy
    | ValidateEmail String
    | SendCode
    | SendCodeResponse (Result Http.Error RailsResponse)
    | ValidateConfirmToken String
    | ConfirmEmail
    | EmailConfirmationResponse (Result Http.Error RailsResponse)
    | ToggleAgreeEosConstitution
    | NotificationMessage Notification.Message
    | ChangeUrl String


update : Message -> Model -> Flags -> Language -> ( Model, Cmd Message )
update msg ({ accountName, keys, notification } as model) flags language =
    case msg of
        GenerateKeys ->
            ( model, Port.generateKeys () )

        UpdateKeys keyPair ->
            ( { model | keys = keyPair }, Cmd.none )

        Copy ->
            ( { model
                | notification =
                    { content =
                        Notification.Ok
                            { message = AccountCreationKeypairCopiedToClipboard
                            , detail = EmptyMessage
                            }
                    , open = True
                    }
              }
            , Port.copy ()
            )

        ValidateAccountNameInput accountName ->
            validateAccountNameInput { model | accountName = accountName } NotSent

        OnFetchAccountToVerify (Ok _) ->
            validateAccountNameInput model Succeed

        OnFetchAccountToVerify (Err _) ->
            validateAccountNameInput model Fail

        CreateEosAccount ->
            ( model, createEosAccountRequest model flags language )

        NewEosAccount (Ok res) ->
            ( { model | accountRequestSuccess = True }
            , Navigation.newUrl ("/account/created?eos_account=" ++ accountName ++ "&public_key=" ++ keys.publicKey)
            )

        NewEosAccount (Err error) ->
            let
                ( errorMessage, errorDetail ) =
                    decodeRailsErrorResponse error AccountCreationFailure
            in
            ( { model
                | accountRequestSuccess = False
                , notification =
                    { content =
                        Notification.Error
                            { message = errorMessage, detail = errorDetail }
                    , open = True
                    }
              }
            , Cmd.none
            )

        ValidateEmail email ->
            let
                newModel =
                    { model | email = email }

                emailValid =
                    not (String.isEmpty email) && isValidEmail email
            in
            ( { newModel | emailValid = emailValid }, Cmd.none )

        SendCode ->
            ( { model | emailRequested = True }, sendCodeRequest model flags language )

        SendCodeResponse (Ok res) ->
            ( { model
                | notification =
                    { content = Notification.Ok { message = ConfirmEmailSent, detail = EmptyMessage }
                    , open = True
                    }
              }
            , Cmd.none
            )

        SendCodeResponse (Err error) ->
            let
                ( errorMessage, errorDetail ) =
                    decodeRailsErrorResponse error UnknownError
            in
            ( { model
                | emailRequested = False
                , notification =
                    { content =
                        Notification.Error
                            { message = errorMessage, detail = errorDetail }
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
            let
                emailConfirmed =
                    case response of
                        Ok res ->
                            True

                        Err error ->
                            False
            in
            ( { model | emailConfirmationRequested = True, emailConfirmed = emailConfirmed }
            , Cmd.none
            )

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

        _ ->
            ( model, Cmd.none )



-- VIEW


accountInputViews : Model -> Language -> List (Html Message)
accountInputViews { accountName, accountValidation } language =
    let
        ( accountValidationMsg, visibility, classAttr ) =
            case accountValidation of
                ValidAccount ->
                    ( AccountCreationNameAlreadyExist, "visible", "false validate" )

                InexistentAccount ->
                    ( AccountCreationNameValid, "visible", "true validate" )

                EmptyAccount ->
                    ( EmptyMessage, "hidden", "false validate" )

                _ ->
                    ( AccountCreationNameInvalid, "visible", "false validate" )
    in
    [ h3 []
        [ textViewI18n language AccountCreationInput ]
    , input
        [ class "account_name"
        , placeholder (translate language AccountCreationNamePlaceholder)
        , type_ "text"
        , attribute "maxlength" "12"
        , onInput ValidateAccountNameInput
        , attribute "maxlength" "12"
        ]
        []
    , span
        [ style [ ( "visibility", visibility ) ]
        , class classAttr
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
    , textarea [ class "hidden_copy_field", id "key" ]
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
            , placeholder (translate language AccountCreationEnterEmail)
            , type_ "email"
            , onInput ValidateEmail
            ]
            []
        , button
            [ class "action button"
            , type_ "button"
            , onClick SendCode
            , disabled (not emailValid)
            ]
            [ textViewI18n language AccountCreationSendEmail ]
        , input
            [ placeholder (translate language AccountCreationEnterVerificationCode)
            , type_ "text"
            , onInput ValidateConfirmToken
            ]
            []
        , button
            [ class "action button"
            , disabled (not confirmTokenValid)
            , type_ "button"
            , onClick ConfirmEmail
            ]
            [ textViewI18n language Confirm ]
        ]


emailConfirmationMsgView : Model -> Language -> Html Message
emailConfirmationMsgView { emailConfirmationRequested, emailConfirmed } language =
    let
        emailConfirmationMsg =
            if emailConfirmationRequested then
                if emailConfirmed then
                    AccountCreationEmailConfirmed

                else
                    AccountCreationEmailConfirmFailure

            else
                EmptyMessage
    in
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
        , a [ href Urls.eosConstitutionUrl, target "_blank" ]
            [ textViewI18n language EosConstitutionLink ]
        ]


okButton : Model -> Language -> Html Message
okButton { accountValidation, emailRequested, emailConfirmed, agreeEosConstitution } language =
    button
        [ class "ok button"
        , attribute
            (if (accountValidation == InexistentAccount) && emailRequested && emailConfirmed && agreeEosConstitution then
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


confirmEmailRequest : Model -> Flags -> Language -> Cmd Message
confirmEmailRequest { confirmToken } flags language =
    let
        url =
            Urls.confirmEmailUrl flags confirmToken (toLocale language)
    in
    Http.send EmailConfirmationResponse <|
        Http.post url Http.emptyBody railsResponseDecoder


createEosAccountBodyParams : Model -> Http.Body
createEosAccountBodyParams { accountName, keys } =
    Encode.object
        [ ( "account_name", Encode.string accountName )
        , ( "pubkey", Encode.string keys.publicKey )
        ]
        |> Http.jsonBody


postCreateEosAccount : Model -> Flags -> Language -> Http.Request RailsResponse
postCreateEosAccount ({ confirmToken } as model) flags language =
    let
        url =
            Urls.createEosAccountUrl flags confirmToken (toLocale language)

        params =
            createEosAccountBodyParams model
    in
    Http.post url params railsResponseDecoder


createEosAccountRequest : Model -> Flags -> Language -> Cmd Message
createEosAccountRequest model flags language =
    Http.send NewEosAccount <| postCreateEosAccount model flags language


sendCodeBodyParams : Model -> Http.Body
sendCodeBodyParams { email } =
    Encode.object [ ( "email", Encode.string email ) ]
        |> Http.jsonBody


postUsers : Model -> Flags -> Language -> Http.Request RailsResponse
postUsers model flags language =
    Http.post (Urls.usersApiUrl flags (toLocale language)) (sendCodeBodyParams model) railsResponseDecoder


sendCodeRequest : Model -> Flags -> Language -> Cmd Message
sendCodeRequest model flags language =
    Http.send SendCodeResponse <| postUsers model flags language



-- Util


validateAccountNameInput : Model -> VerificationRequestStatus -> ( Model, Cmd Message )
validateAccountNameInput ({ accountName } as model) requestStatus =
    let
        accountValidation =
            validateAccountForCreation accountName requestStatus

        accountCmd =
            if accountValidation == AccountToBeVerified then
                accountName
                    |> getAccount
                    |> Http.send OnFetchAccountToVerify

            else
                Cmd.none
    in
    ( { model | accountValidation = accountValidation }, accountCmd )



-- SUBSCRIPTIONS


subscriptions : Sub Message
subscriptions =
    Port.receiveKeys UpdateKeys
