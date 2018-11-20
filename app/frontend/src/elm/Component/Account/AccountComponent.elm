module Component.Account.AccountComponent exposing (Message(..), Model, Page(..), getPage, initCmd, initModel, subscriptions, toLanguage, update, view)

import Component.Account.Page.Create as Create
import Component.Account.Page.Created as Created
import Component.Account.Page.EventCreation as EventCreation
import Component.Account.Page.WaitPayment as WaitPayment
import Component.Main.Page.NotFound as NotFound
import Data.Common exposing (ApplicationState, initApplicationState)
import Data.Json exposing (Product)
import Html exposing (Html, a, button, div, h1, section, text)
import Html.Attributes exposing (attribute, class, type_)
import Html.Events exposing (onClick)
import Http
import Navigation exposing (Location)
import Route exposing (Route(..), parseLocation)
import Translation exposing (Language(..))
import Util.Flags exposing (Flags)
import Util.HttpRequest exposing (getApplicationState)



-- MODEL


type Page
    = CreatePage Create.Model
    | WaitPaymentPage WaitPayment.Model
    | CreatedPage Created.Model
    | EventCreationPage EventCreation.Model
    | NotFoundPage


type alias Model =
    { page : Page
    , language : Language
    , flags : Flags
    , applicationState : ApplicationState
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

        language =
            case route of
                EventCreationRoute maybeLocale ->
                    toLanguage maybeLocale

                CreateRoute maybeLocale ->
                    toLanguage maybeLocale

                _ ->
                    Translation.Korean
    in
    { page = page
    , language = language
    , flags = flags
    , applicationState = initApplicationState
    }



-- MESSAGE


type Message
    = CreateMessage Create.Message
    | WaitPaymentMessage WaitPayment.Message
    | CreatedMessage Created.Message
    | EventCreationMessage EventCreation.Message
    | OnLocationChange Location
    | ChangeUrl String
    | UpdateLanguage Language
    | OnFetchApplicationState (Result Http.Error ApplicationState)


initCmd : Model -> Cmd Message
initCmd { page, flags, language } =
    let
        pageCmd =
            case page of
                CreatePage _ ->
                    let
                        subCmd =
                            Create.initCmd flags language
                    in
                    Cmd.map CreateMessage subCmd

                EventCreationPage _ ->
                    let
                        subCmd =
                            EventCreation.initCmd
                    in
                    Cmd.map EventCreationMessage subCmd

                _ ->
                    Cmd.none
    in
    Cmd.batch
        [ pageCmd
        , getApplicationState flags
            |> Http.send OnFetchApplicationState
        ]



-- VIEW


headerView : Language -> Html Message
headerView language =
    let
        getLanguageClass lang =
            if lang == language then
                class "selected"

            else
                class ""
    in
    Html.header []
        [ h1 []
            [ a [ onClick (ChangeUrl "/") ] [ text "eoshub" ]
            ]
        , div [ class "language" ]
            [ button
                [ type_ "button"
                , getLanguageClass Korean
                , attribute "data-lang" "ko"
                , onClick (UpdateLanguage Korean)
                ]
                [ text "한글" ]
            , button
                [ type_ "button"
                , getLanguageClass English
                , attribute "data-lang" "en"
                , onClick (UpdateLanguage English)
                ]
                [ text "ENG" ]
            , button
                [ type_ "button"
                , getLanguageClass Chinese
                , attribute "data-lang" "cn"
                , onClick (UpdateLanguage Chinese)
                ]
                [ text "中文" ]
            ]
        ]


view : Model -> Html Message
view { language, page, applicationState } =
    let
        newContentHtml =
            case page of
                CreatePage subModel ->
                    Html.map CreateMessage (Create.view subModel language)

                WaitPaymentPage subModel ->
                    Html.map WaitPaymentMessage (WaitPayment.view subModel language)

                CreatedPage subModel ->
                    Html.map CreatedMessage (Created.view subModel language applicationState.eventActivation)

                EventCreationPage subModel ->
                    Html.map EventCreationMessage (EventCreation.view subModel language)

                _ ->
                    NotFound.view language
    in
    div []
        [ headerView language
        , section [ class "content" ]
            [ newContentHtml ]
        ]



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message ({ page, language, flags, applicationState } as model) =
    case ( message, page ) of
        ( CreateMessage subMessage, CreatePage subModel ) ->
            let
                ( newPage, subCmd ) =
                    Create.update subMessage subModel flags language
            in
            ( { model | page = newPage |> CreatePage }, Cmd.map CreateMessage subCmd )

        ( WaitPaymentMessage subMessage, WaitPaymentPage subModel ) ->
            let
                ( newPage, subCmd ) =
                    WaitPayment.update subMessage subModel flags language
            in
            ( { model | page = newPage |> WaitPaymentPage }, Cmd.map WaitPaymentMessage subCmd )

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
                newPage =
                    getPage <| parseLocation <| location

                newModel =
                    { model | page = newPage }

                cmd =
                    initCmd newModel
            in
            ( newModel, cmd )

        ( ChangeUrl url, _ ) ->
            ( model, Navigation.newUrl url )

        ( UpdateLanguage newLanguage, _ ) ->
            ( { model | language = newLanguage }, Cmd.none )

        ( OnFetchApplicationState (Ok data), _ ) ->
            ( { model | applicationState = data }, Cmd.none )

        ( OnFetchApplicationState (Err _), _ ) ->
            ( model, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions { page } =
    case page of
        CreatePage subModel ->
            Sub.map CreateMessage (Create.subscriptions subModel)

        EventCreationPage subModel ->
            Sub.map EventCreationMessage (EventCreation.subscriptions subModel)

        _ ->
            Sub.none



-- Utility functions


getPage : Route -> Page
getPage route =
    case route of
        CreateRoute _ ->
            CreatePage Create.initModel

        WaitPaymentRoute maybeOrderNo ->
            WaitPaymentPage (WaitPayment.initModel maybeOrderNo)

        CreatedRoute maybeEosAccount maybePublicKey ->
            CreatedPage (Created.initModel maybeEosAccount maybePublicKey)

        EventCreationRoute _ ->
            EventCreationPage EventCreation.initModel

        _ ->
            NotFoundPage
