module Component.Account.Page.Create exposing
    ( Message(..)
    , Model
    , initCmd
    , initModel
    , subscriptions
    , update
    , view
    )

import Data.Account exposing (Account)
import Data.Json
    exposing
        ( Product
        , RequestPaymentResponse
        , initProduct
        , requestPaymentResposeDecoder
        )
import Data.RailsResponse exposing (handleRailsErrorResponse)
import Data.WindowOpen as WindowOpen
import Html
    exposing
        ( Html
        , a
        , article
        , button
        , dd
        , div
        , dl
        , dt
        , h2
        , h3
        , input
        , label
        , main_
        , p
        , section
        , span
        , strong
        , text
        , textarea
        )
import Html.Attributes
    exposing
        ( attribute
        , checked
        , class
        , disabled
        , for
        , href
        , id
        , placeholder
        , style
        , target
        , type_
        )
import Html.Events exposing (onClick, onInput)
import Http
import Json.Encode as Encode
import Navigation
import Port exposing (KeyPair)
import Round
import Translation
    exposing
        ( I18n(..)
        , Language
        , toLocale
        , translate
        )
import Util.Flags exposing (Flags)
import Util.HttpRequest exposing (getAccount, getEosAccountProduct)
import Util.Urls as Urls
import Util.Validation
    exposing
        ( AccountStatus(..)
        , VerificationRequestStatus(..)
        , validateAccountForCreation
        )
import View.I18nViews exposing (textViewI18n)
import View.Notification as Notification



-- MODEL


type alias Model =
    { accountName : String
    , accountValidation : AccountStatus
    , accountRequestSuccess : Bool
    , keys : KeyPair
    , product : Product
    , agreeEosConstitution : Bool
    , notification : Notification.Model
    }


initModel : Model
initModel =
    { accountName = ""
    , accountValidation = EmptyAccount
    , accountRequestSuccess = False
    , keys = { privateKey = "", publicKey = "" }
    , product = initProduct
    , agreeEosConstitution = False
    , notification = Notification.initModel
    }


initCmd : Flags -> Language -> Cmd Message
initCmd flags language =
    Cmd.batch
        [ Port.generateKeys ()
        , getEosAccountProduct flags language |> Http.send ResultEosAccountProduct
        ]



-- UPDATES


type Message
    = ValidateAccountNameInput String
    | OnFetchAccountToVerify (Result Http.Error Account)
    | RequestPayment
    | ResultRequestPayment (Result Http.Error RequestPaymentResponse)
    | GenerateKeys
    | UpdateKeys KeyPair
    | Copy
    | ToggleAgreeEosConstitution
    | NotificationMessage Notification.Message
    | ChangeUrl String
    | ResultEosAccountProduct (Result Http.Error Product)


update : Message -> Model -> Flags -> Language -> ( Model, Cmd Message )
update msg ({ notification } as model) flags language =
    case msg of
        GenerateKeys ->
            ( model, Port.generateKeys () )

        ResultEosAccountProduct (Ok product) ->
            let
                cmd =
                    if product.eventActivation then
                        Navigation.modifyUrl ("/account/event_creation?locale=" ++ toLocale language)

                    else
                        Cmd.none
            in
            ( { model | product = product }, cmd )

        ResultEosAccountProduct (Err error) ->
            let
                ( errorMessage, errorDetail ) =
                    handleRailsErrorResponse error AccountCreationFailure
            in
            ( { model
                | notification =
                    { content = Notification.Error { message = errorMessage, detail = errorDetail }
                    , open = True
                    }
              }
            , Cmd.none
            )

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
            validateAccountName { model | accountName = accountName } NotSent

        OnFetchAccountToVerify (Ok _) ->
            validateAccountName model Succeed

        OnFetchAccountToVerify (Err _) ->
            validateAccountName model Fail

        RequestPayment ->
            ( model, requestPayment model flags language )

        ResultRequestPayment (Ok res) ->
            let
                openWindowParams =
                    WindowOpen.windowOpenParametersToValue <|
                        { url = res.onlineUrl, width = 452, height = 560 }
            in
            ( { model | accountRequestSuccess = True }
            , Cmd.batch
                [ Navigation.newUrl ("/account/wait_payment?order_no=" ++ res.orderNo)
                , Port.openWindow openWindowParams
                ]
            )

        ResultRequestPayment (Err error) ->
            let
                ( errorMessage, errorDetail ) =
                    handleRailsErrorResponse error AccountCreationFailure
            in
            ( { model
                | accountRequestSuccess = False
                , notification =
                    { content = Notification.Error { message = errorMessage, detail = errorDetail }
                    , open = True
                    }
              }
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
accountInputViews { accountValidation } language =
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


paymentView : Model -> Language -> Html Message
paymentView { product } language =
    let
        cpu =
            toString product.cpu ++ " EOS"

        net =
            toString product.net ++ " EOS"

        ram =
            (toFloat product.ram / 1024.0 |> Round.round 3) ++ " KB"
    in
    if product.active then
        div [ class "container" ]
            [ h3 []
                [ textViewI18n language AccountCreationPayment ]
            , dl [ class "invoice" ]
                [ dt []
                    [ text "CPU" ]
                , dd []
                    [ text cpu ]
                , dt []
                    [ text "NET" ]
                , dd []
                    [ text net ]
                , dt []
                    [ text "RAM" ]
                , dd []
                    [ text ram ]
                ]
            , div [ class "select_payment_type area" ]
                [ button [ class "choice ing button", type_ "button" ]
                    [ textViewI18n language PaymentVirtualAccount ]
                , p [ class "amount" ]
                    [ textViewI18n language PaymentTotalAmount
                    , strong []
                        [ text (toString product.price) ]
                    , text "₩"
                    ]
                ]
            ]

    else
        div [] []


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
okButton { accountValidation, agreeEosConstitution, product } language =
    let
        enabled =
            (accountValidation == InexistentAccount)
                && product.active
                && agreeEosConstitution
    in
    button
        [ class "ok button"
        , disabled (not enabled)
        , type_ "button"
        , onClick RequestPayment
        ]
        [ textViewI18n language AccountCreationButton ]


view : Model -> Language -> Html Message
view ({ notification } as model) language =
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
            , paymentView model language
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


requestPaymentBodyParams : Model -> Http.Body
requestPaymentBodyParams { accountName, keys, product } =
    Encode.object
        [ ( "eos_account", Encode.string accountName )
        , ( "public_key", Encode.string keys.publicKey )
        , ( "product_id", Encode.int product.id )
        , ( "pgcode", Encode.string "virtualaccount" )
        ]
        |> Http.jsonBody


postRequestPayment : Model -> Flags -> Language -> Http.Request RequestPaymentResponse
postRequestPayment model flags language =
    let
        url =
            Urls.requestPaymentUrl flags (toLocale language)

        params =
            requestPaymentBodyParams model
    in
    Http.post url params requestPaymentResposeDecoder


requestPayment : Model -> Flags -> Language -> Cmd Message
requestPayment model flags language =
    Http.send ResultRequestPayment <| postRequestPayment model flags language



-- Util


validateAccountName : Model -> VerificationRequestStatus -> ( Model, Cmd Message )
validateAccountName ({ accountName } as model) requestStatus =
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


subscriptions : Model -> Sub Message
subscriptions _ =
    Port.receiveKeys UpdateKeys
