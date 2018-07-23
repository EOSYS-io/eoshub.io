module AccountPageGroup exposing (..)

import ExternalMessage
import Html
    exposing
        ( Html
        , Attribute
        , div
        , section
        , form
        , ul
        , li
        , span
        , input
        , button
        , text
        )
import Html.Events exposing (on, onInput, onClick, keyCode)
import Navigation exposing (Location)
import Page.Account.ConfirmEmail as ConfirmEmail
import Page.Account.Create as Create
import Page.Account.CreateKeys as CreateKeys
import Page.Account.Created as Created
import Page.Account.EmailConfirmFailure as EmailConfirmFailure
import Page.Account.EmailConfirmed as EmailConfirmed
import Page.NotFound as NotFound
import Route exposing (Route(..), parseLocation)
import Translation exposing (Language)
import Util.Flags exposing (Flags)
import Json.Decode as JD exposing (Decoder)
import View.Notification as Notification


-- MODEL


type Page
    = ConfirmEmailPage ConfirmEmail.Model
    | EmailConfirmedPage EmailConfirmed.Model
    | EmailConfirmFailurePage EmailConfirmFailure.Model
    | CreatedPage Created.Model
    | CreateKeysPage CreateKeys.Model
    | CreatePage Create.Model
    | NotFoundPage


type alias Model =
    { page : Page
    , notification : Notification.Model
    , confirmToken : String
    }


initModel : Location -> Model
initModel location =
    let
        route =
            location |> parseLocation

        page =
            getPage route
    in
        case route of
            EmailConfirmedRoute confirmToken email ->
                { page = page
                , notification = Notification.initModel
                , confirmToken = confirmToken
                }

            _ ->
                { page = page
                , notification = Notification.initModel
                , confirmToken = ""
                }



-- MESSAGE


type Message
    = ConfirmEmailMessage ConfirmEmail.Message
    | EmailConfirmedMessage EmailConfirmed.Message
    | EmailConfirmFailureMessage EmailConfirmFailure.Message
    | CreateKeysMessage CreateKeys.Message
    | CreatedMessage Created.Message
    | CreateMessage Create.Message
    | IndexMessage ExternalMessage.Message
    | OnLocationChange Location
    | NotificationMessage Notification.Message


initCmd : Model -> Cmd Message
initCmd { page, confirmToken } =
    case page of
        CreateKeysPage subModel ->
            let
                ( _, subCmd ) =
                    CreateKeys.update CreateKeys.GenerateKeys subModel |> Debug.log confirmToken

                cmd =
                    Cmd.map CreateKeysMessage subCmd
            in
                cmd

        _ ->
            Cmd.none



-- VIEW


view : Language -> Model -> List (Html Message)
view language { page, notification } =
    let
        newContentHtml =
            case page of
                ConfirmEmailPage subModel ->
                    Html.map ConfirmEmailMessage (ConfirmEmail.view subModel)

                EmailConfirmedPage subModel ->
                    Html.map EmailConfirmedMessage (EmailConfirmed.view subModel)

                EmailConfirmFailurePage subModel ->
                    Html.map EmailConfirmFailureMessage (EmailConfirmFailure.view subModel)

                CreateKeysPage subModel ->
                    Html.map CreateKeysMessage (CreateKeys.view subModel)

                CreatedPage subModel ->
                    Html.map CreatedMessage (Created.view subModel)

                CreatePage subModel ->
                    Html.map CreateMessage (Create.view subModel)

                _ ->
                    NotFound.view language

        notificationParameter =
            case page of
                _ ->
                    ""
    in
        [ newContentHtml
        , Html.map NotificationMessage
            (Notification.view
                notification
                notificationParameter
                language
            )
        ]


onEnter : Message -> Attribute Message
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                JD.succeed msg
            else
                JD.fail "not ENTER"
    in
        on "keydown" (JD.andThen isEnter keyCode)



-- UPDATE


update : Message -> Model -> Flags -> ( Model, Cmd Message )
update message ({ page, notification, confirmToken } as model) flags =
    case ( message, page ) of
        ( ConfirmEmailMessage subMessage, ConfirmEmailPage subModel ) ->
            let
                ( newPage, subCmd ) =
                    ConfirmEmail.update subMessage subModel flags
            in
                ( { model | page = newPage |> ConfirmEmailPage }, Cmd.map ConfirmEmailMessage subCmd )

        ( EmailConfirmedMessage subMessage, EmailConfirmedPage subModel ) ->
            let
                ( newPage, subCmd ) =
                    EmailConfirmed.update subMessage subModel confirmToken
            in
                ( { model | page = newPage |> EmailConfirmedPage }, Cmd.map EmailConfirmedMessage subCmd )

        ( EmailConfirmFailureMessage subMessage, EmailConfirmFailurePage subModel ) ->
            let
                newPage =
                    EmailConfirmFailure.update subMessage subModel
            in
                ( { model | page = newPage |> EmailConfirmFailurePage }, Cmd.none )

        ( CreateKeysMessage subMessage, CreateKeysPage subModel ) ->
            let
                ( newPage, subCmd ) =
                    CreateKeys.update subMessage subModel
            in
                ( { model | page = newPage |> CreateKeysPage }, Cmd.map CreateKeysMessage subCmd )

        ( CreatedMessage subMessage, CreatedPage subModel ) ->
            let
                ( newPage, subCmd ) =
                    Created.update subMessage subModel
            in
                ( { model | page = newPage |> CreatedPage }, Cmd.map CreatedMessage subCmd )

        ( CreateMessage subMessage, CreatePage subModel ) ->
            let
                ( newPage, subCmd ) =
                    Create.update subMessage subModel flags confirmToken
            in
                ( { model | page = newPage |> CreatePage }, Cmd.map CreateMessage subCmd )

        ( OnLocationChange location, _ ) ->
            let
                route =
                    location |> parseLocation

                newPage =
                    getPage route

                newModel =
                    { model | page = newPage }

                cmd =
                    initCmd newModel
            in
                case route of
                    EmailConfirmedRoute confirmToken email ->
                        ( { newModel | confirmToken = confirmToken }, cmd )

                    _ ->
                        ( newModel, cmd )

        ( NotificationMessage Notification.CloseNotification, _ ) ->
            ( { model
                | notification =
                    { notification | open = False }
              }
            , Cmd.none
            )

        ( _, _ ) ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.batch
        [ Sub.map CreateKeysMessage CreateKeys.subscriptions ]



-- Utility functions


getPage : Route -> Page
getPage route =
    case route of
        ConfirmEmailRoute ->
            ConfirmEmailPage ConfirmEmail.initModel

        EmailConfirmedRoute confirmToken email ->
            EmailConfirmedPage (EmailConfirmed.initModel email)

        EmailConfirmFailureRoute ->
            EmailConfirmFailurePage EmailConfirmFailure.initModel

        CreateKeysRoute ->
            let
                createKeysModel =
                    CreateKeys.initModel
            in
                CreateKeysPage createKeysModel

        CreatedRoute ->
            CreatedPage Created.initModel

        CreateRoute pubkey ->
            CreatePage (Create.initModel pubkey)

        _ ->
            NotFoundPage
