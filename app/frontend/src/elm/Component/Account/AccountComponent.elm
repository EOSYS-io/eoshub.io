module Component.Account.AccountComponent exposing (..)

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
import Navigation exposing (Location)
import Component.Account.Page.ConfirmEmail as ConfirmEmail
import Component.Account.Page.Create as Create
import Component.Account.Page.CreateKeys as CreateKeys
import Component.Account.Page.Created as Created
import Component.Account.Page.EmailConfirmFailure as EmailConfirmFailure
import Component.Account.Page.EmailConfirmed as EmailConfirmed
import Component.Main.Page.NotFound as NotFound
import Translation exposing (Language)
import Route exposing (Route(..), parseLocation)
import Translation exposing (Language, toLanguage)
import Util.Flags exposing (Flags)


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
    , confirmToken : String
    , language : Language
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
            ConfirmEmailRoute maybeLocale ->
                let
                    language =
                        case maybeLocale of
                            Just locale ->
                                toLanguage locale

                            Nothing ->
                                Translation.Korean
                in
                    { page = page
                    , confirmToken = ""
                    , language = language
                    }

            EmailConfirmedRoute confirmToken email maybeLocale ->
                let
                    language =
                        case maybeLocale of
                            Just locale ->
                                toLanguage locale

                            Nothing ->
                                Translation.Korean
                in
                    { page = page
                    , confirmToken = confirmToken
                    , language = language
                    }

            _ ->
                { page = page
                , confirmToken = ""
                , language = Translation.Korean
                }



-- MESSAGE


type Message
    = ConfirmEmailMessage ConfirmEmail.Message
    | EmailConfirmedMessage EmailConfirmed.Message
    | EmailConfirmFailureMessage EmailConfirmFailure.Message
    | CreateKeysMessage CreateKeys.Message
    | CreatedMessage Created.Message
    | CreateMessage Create.Message
    | OnLocationChange Location


initCmd : Model -> Cmd Message
initCmd { page, confirmToken } =
    case page of
        CreateKeysPage subModel ->
            let
                ( _, subCmd ) =
                    CreateKeys.update CreateKeys.GenerateKeys subModel

                cmd =
                    Cmd.map CreateKeysMessage subCmd
            in
                cmd

        _ ->
            Cmd.none



-- VIEW


view : Model -> Html Message
view { language, page } =
    let
        newContentHtml =
            case page of
                ConfirmEmailPage subModel ->
                    Html.map ConfirmEmailMessage (ConfirmEmail.view subModel language)

                EmailConfirmedPage subModel ->
                    Html.map EmailConfirmedMessage (EmailConfirmed.view subModel language)

                EmailConfirmFailurePage subModel ->
                    Html.map EmailConfirmFailureMessage (EmailConfirmFailure.view subModel language)

                CreateKeysPage subModel ->
                    Html.map CreateKeysMessage (CreateKeys.view subModel language)

                CreatedPage subModel ->
                    Html.map CreatedMessage (Created.view subModel language)

                CreatePage subModel ->
                    Html.map CreateMessage (Create.view subModel language)

                _ ->
                    NotFound.view language
    in
        newContentHtml



-- UPDATE


update : Message -> Model -> Flags -> ( Model, Cmd Message )
update message ({ page, confirmToken, language } as model) flags =
    case ( message, page ) of
        ( ConfirmEmailMessage subMessage, ConfirmEmailPage subModel ) ->
            let
                ( newPage, subCmd ) =
                    ConfirmEmail.update subMessage subModel flags language
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
                    Create.update subMessage subModel flags confirmToken language
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
                ( newModel, cmd )

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
        ConfirmEmailRoute maybeLocale ->
            ConfirmEmailPage ConfirmEmail.initModel

        EmailConfirmedRoute confirmToken email maybeLocale ->
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
