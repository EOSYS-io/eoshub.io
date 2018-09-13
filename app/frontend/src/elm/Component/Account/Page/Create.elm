module Component.Account.Page.Create exposing (Message(..), Model, createEosAccountBodyParams, initModel, update, view)

import Html exposing (Html, article, br, button, div, form, h2, img, input, li, main_, ol, p, span, text, ul)
import Html.Attributes exposing (action, alt, attribute, class, placeholder, src, style, type_)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Json.Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Navigation
import Translation
    exposing
        ( I18n
            ( AccountCreationFailure
            , AccountCreationNameCondition
            , AccountCreationNameConditionExample
            , AccountCreationNameInvalid
            , AccountCreationNamePlaceholder
            , AccountCreationNameValid
            , AccountCreationProgressCreateNew
            , AccountCreationProgressEmail
            , AccountCreationProgressKeypair
            , AccountCreationTypeName
            , DebugMessage
            , EmptyMessage
            , Next
            )
        , Language
        , toLocale
        , translate
        )
import Util.Flags exposing (Flags)
import Util.Urls as Urls
import Util.Validation exposing (checkAccountName)
import View.I18nViews exposing (textViewI18n)
import View.Notification as Notification



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
            ( { model | requestSuccess = True }, Navigation.newUrl "/account/created" )

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
    main_ [ class "join" ]
        [ article [ attribute "data-step" "make-account" ]
            [ span [ class "progress", attribute "data-progress" "01" ]
                [ text "01" ]
            , h2 []
                [ textViewI18n language AccountCreationTypeName ]
            , p []
                [ textViewI18n language AccountCreationNameCondition ]
            , form []
                [ input
                    [ class "account_name"
                    , placeholder (translate language AccountCreationNameConditionExample)
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
                ]
            , div [ class "btn_area" ]
                [ button
                    [ class "ok button"
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
