module Component.Account.AccountComponent exposing (Message(..), Model, Page(..), getPage, initCmd, initModel, subscriptions, toLanguage, update, view)

import Component.Account.Page.Created as Created
import Component.Account.Page.EventCreation as EventCreation
import Component.Main.Page.NotFound as NotFound
import Html
    exposing
        ( Attribute
        , Html
        , button
        , div
        , form
        , input
        , li
        , section
        , span
        , text
        , ul
        )
import Html.Attributes exposing (class)
import Navigation exposing (Location)
import Route exposing (Route(..), parseLocation)
import Translation exposing (Language)
import Util.Flags exposing (Flags)



-- MODEL


type Page
    = CreatedPage Created.Model
    | EventCreationPage EventCreation.Model
    | NotFoundPage


type alias Model =
    { page : Page
    , language : Language
    , flags : Flags
    }


toLanguage : Maybe String -> Language
toLanguage maybeLocale =
    case maybeLocale of
        Just locale ->
            Translation.toLanguage locale

        Nothing ->
            Translation.Korean


initModel : Location -> Flags -> Model
initModel location flags =
    let
        route =
            location |> parseLocation

        page =
            getPage route
    in
    case route of
        EventCreationRoute maybeLocale ->
            { page = page
            , language = toLanguage maybeLocale
            , flags = flags
            }

        _ ->
            { page = page
            , language = Translation.Korean
            , flags = flags
            }



-- MESSAGE


type Message
    = CreatedMessage Created.Message
    | EventCreationMessage EventCreation.Message
    | OnLocationChange Location


initCmd : Model -> Cmd Message
initCmd { page, flags, language } =
    case page of
        EventCreationPage subModel ->
            let
                ( _, subCmd ) =
                    EventCreation.update EventCreation.GenerateKeys subModel flags language

                cmd =
                    Cmd.map EventCreationMessage subCmd
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
                CreatedPage subModel ->
                    Html.map CreatedMessage (Created.view subModel language)

                EventCreationPage subModel ->
                    Html.map EventCreationMessage (EventCreation.view subModel language)

                _ ->
                    NotFound.view language
    in
    section [ class "content" ]
        [ newContentHtml ]



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message ({ page, language, flags } as model) =
    case ( message, page ) of
        ( CreatedMessage subMessage, CreatedPage subModel ) ->
            let
                ( newPage, subCmd ) =
                    Created.update subMessage subModel
            in
            ( { model | page = newPage |> CreatedPage }, Cmd.map CreatedMessage subCmd )

        ( EventCreationMessage subMessage, EventCreationPage subModel ) ->
            let
                ( newPage, subCmd ) =
                    EventCreation.update subMessage subModel flags language
            in
            ( { model | page = newPage |> EventCreationPage }, Cmd.map EventCreationMessage subCmd )

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
        [ Sub.map EventCreationMessage EventCreation.subscriptions
        ]



-- Utility functions


getPage : Route -> Page
getPage route =
    case route of
        CreatedRoute maybeEosAccount maybePublicKey ->
            CreatedPage (Created.initModel maybeEosAccount maybePublicKey)

        EventCreationRoute maybeLocale ->
            EventCreationPage EventCreation.initModel

        _ ->
            NotFoundPage
