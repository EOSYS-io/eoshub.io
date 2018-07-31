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
import Translation
    exposing
        ( Language
        , toLocale
        , translate
        , I18n
            ( EmptyMessage
            , DebugMessage
            , AccountCreationFailure
            , AccountCreationProgressEmail
            , AccountCreationProgressKeypair
            , AccountCreationProgressCreateNew
            , AccountCreationNameValid
            , AccountCreationNameInvalid
            , AccountCreationTypeName
            , AccountCreationNameCondition
            , AccountCreationNameConditionExample
            , AccountCreationNamePlaceholder
            )
        )
import View.I18nViews exposing (textViewI18n)


-- MODEL


type alias Model =
    { accountName : String
    , pubkey : String
    , validation : Bool
    , validationMsg : I18n
    , requestSuccess : Bool
    , notification : Notification.Model
    }


initModel : String -> Model
initModel pubkey =
    { accountName = ""
    , pubkey = pubkey
    , validation = False
    , validationMsg = EmptyMessage
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
                        ( AccountCreationNameValid, True )
                    else
                        ( AccountCreationNameInvalid, False )
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
                [ textViewI18n language AccountCreationProgressEmail ]
            , li [ class "done" ]
                [ textViewI18n language AccountCreationProgressKeypair ]
            , li [ class "ing" ]
                [ textViewI18n language AccountCreationProgressCreateNew ]
            ]
        , article [ attribute "data-step" "4" ]
            [ h1 []
                [ textViewI18n language AccountCreationTypeName ]
            , p []
                [ textViewI18n language AccountCreationNameCondition
                , br []
                    []
                , textViewI18n language AccountCreationNameConditionExample
                ]
            , form [ onSubmit CreateEosAccount ]
                [ input
                    [ class "account_name"
                    , placeholder (translate language AccountCreationNamePlaceholder)
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
                    [ textViewI18n language validationMsg ]
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
                [ textViewI18n language Translation.Next ]
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
