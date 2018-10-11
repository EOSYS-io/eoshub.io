module Component.Account.Page.WaitPayment exposing
    ( Message(..)
    , Model
    , initModel
    , update
    , view
    )

import Data.Json
    exposing
        ( CreateEosAccountResponse
        , RailsResponse
        , createEosAccountResponseDecoder
        , decodeRailsResponseBodyMsg
        , railsResponseDecoder
        )
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
            , DebugMessage
            , EmptyMessage
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
            case maybeOrderNo of
                Just string ->
                    string

                Nothing ->
                    ""
    in
    { orderNo = orderNo
    , notification = Notification.initModel
    }



-- UPDATES


type Message
    = CreateEosAccount
    | NewEosAccount (Result Http.Error CreateEosAccountResponse)
    | NotificationMessage Notification.Message
    | ChangeUrl String


update : Message -> Model -> Flags -> Language -> ( Model, Cmd Message )
update msg ({ notification } as model) flags language =
    case msg of
        CreateEosAccount ->
            ( model, createEosAccountRequest model flags language )

        NewEosAccount (Ok res) ->
            ( model
            , Navigation.newUrl ("/account/created?eos_account=" ++ res.eosAccount ++ "&public_key=" ++ res.publicKey)
            )

        NewEosAccount (Err error) ->
            case error of
                Http.BadStatus response ->
                    ( { model
                        | notification =
                            { content =
                                Notification.Error
                                    { message = DebugMessage (decodeRailsResponseBodyMsg response)
                                    , detail = EmptyMessage
                                    }
                            , open = True
                            }
                      }
                    , Cmd.none
                    )

                Http.BadPayload debugMsg response ->
                    ( { model
                        | notification =
                            { content =
                                Notification.Error
                                    { message = AccountCreationFailure
                                    , detail = DebugMessage ("debugMsg: " ++ debugMsg ++ ", body: " ++ response.body)
                                    }
                            , open = True
                            }
                      }
                    , Cmd.none
                    )

                _ ->
                    ( { model
                        | notification =
                            { content =
                                Notification.Error
                                    { message = AccountCreationFailure
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



-- VIEW


view : Model -> Language -> Html Message
view { notification } language =
    main_ [ class "join" ]
        [ article [ attribute "data-step" "validate-email-ok" ]
            [ h2 []
                [ text "입금 후 결제완료 버튼을 눌러주세요." ]
            , p []
                [ text "입금을 하셨는지 다시 한번 확인하고 결제완료를 눌러주세요." ]
            , div [ class "btn_area" ]
                [ button [ class "ok button", type_ "button", onClick CreateEosAccount ]
                    [ text "결제완료" ]
                ]
            , Html.map NotificationMessage (Notification.view notification language)
            ]
        ]



-- HTTP


postCreateEosAccount : Model -> Flags -> Language -> Http.Request CreateEosAccountResponse
postCreateEosAccount ({ orderNo } as model) flags language =
    let
        url =
            Urls.createEosAccountByOrderUrl flags orderNo (toLocale language)
    in
    Http.post url Http.emptyBody createEosAccountResponseDecoder


createEosAccountRequest : Model -> Flags -> Language -> Cmd Message
createEosAccountRequest model flags language =
    Http.send NewEosAccount <| postCreateEosAccount model flags language
