module Component.Account.Page.WaitPayment exposing
    ( Message(..)
    , Model
    , initModel
    , update
    , view
    )

import Data.Json
    exposing
        ( CheckEosAccountCreatedResponse
        , checkEosAccountCreatedResponseDecoder
        )
import Data.RailsResponse exposing (RailsResponse, handleRailsErrorResponse, railsResponseDecoder)
import Html
    exposing
        ( Html
        , article
        , button
        , div
        , h2
        , main_
        , p
        , text
        )
import Html.Attributes
    exposing
        ( attribute
        , class
        , type_
        )
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Navigation
import Translation
    exposing
        ( I18n
            ( AccountCreationFailure
            , AccountCreationWaitPaymentMsg1
            , AccountCreationWaitPaymentMsg2
            , AccountCreationWaitPaymentMsg3
            , DebugMessage
            , EmptyMessage
            , PaymentComplete
            )
        , Language
        , toLocale
        , translate
        )
import Util.Flags exposing (Flags)
import Util.Urls as Urls
import View.I18nViews exposing (textViewI18n)
import View.Notification as Notification



-- MODEL


type alias Model =
    { orderNo : String
    , notification : Notification.Model
    }


initModel : Maybe String -> Model
initModel maybeOrderNo =
    let
        orderNo =
            Maybe.withDefault "" maybeOrderNo
    in
    { orderNo = orderNo
    , notification = Notification.initModel
    }



-- UPDATES


type Message
    = CheckEosAccountCreated
    | NewEosAccount (Result Http.Error CheckEosAccountCreatedResponse)
    | NotificationMessage Notification.Message
    | ChangeUrl String


update : Message -> Model -> Flags -> Language -> ( Model, Cmd Message )
update msg ({ notification } as model) flags language =
    case msg of
        CheckEosAccountCreated ->
            ( model, checkEosAccountCreatedRequest model flags language )

        NewEosAccount (Ok res) ->
            ( model
            , Navigation.newUrl ("/account/created?eos_account=" ++ res.eosAccount ++ "&public_key=" ++ res.publicKey)
            )

        NewEosAccount (Err error) ->
            let
                ( errorMessage, errorDetail ) =
                    handleRailsErrorResponse error AccountCreationFailure
            in
            ( { model
                | notification =
                    { content =
                        Notification.Error
                            { message = errorMessage, detail = errorDetail }
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

        _ ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Language -> Html Message
view { notification } language =
    main_ [ class "join" ]
        [ article [ attribute "data-step" "validate-email-ok" ]
            [ h2 []
                [ textViewI18n language AccountCreationWaitPaymentMsg1 ]
            , p []
                [ textViewI18n language AccountCreationWaitPaymentMsg2 ]
            , p [ class "important description" ]
                [ textViewI18n language AccountCreationWaitPaymentMsg3 ]
            , div [ class "btn_area" ]
                [ button [ class "ok button", type_ "button", onClick CheckEosAccountCreated ]
                    [ textViewI18n language PaymentComplete ]
                ]
            , Html.map NotificationMessage (Notification.view notification language)
            ]
        ]



-- HTTP


getCheckEosAccountCreated : Model -> Flags -> Language -> Http.Request CheckEosAccountCreatedResponse
getCheckEosAccountCreated ({ orderNo } as model) flags language =
    let
        url =
            Urls.checkeEosAccountCreatedUrl flags orderNo (toLocale language)
    in
    Http.get url checkEosAccountCreatedResponseDecoder


checkEosAccountCreatedRequest : Model -> Flags -> Language -> Cmd Message
checkEosAccountCreatedRequest model flags language =
    Http.send NewEosAccount <| getCheckEosAccountCreated model flags language
