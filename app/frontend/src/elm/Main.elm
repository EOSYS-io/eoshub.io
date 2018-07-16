module Main exposing (..)

import Html
import Message exposing (Message(..))
import Navigation exposing (Location)
import Page exposing (Page(..), getPage)
import Route exposing (Route(..), parseLocation)
import Sidebar
import Util.Flags exposing (Flags)


-- MODEL


type alias Model =
    { sidebar : Sidebar.Model
    , page : Page
    , flags : Flags
    }



-- INIT


init : Flags -> Location -> ( Model, Cmd Message )
init flags location =
    ( { sidebar = Sidebar.initModel
      , page = ( location |> parseLocation, flags ) |> getPage
      , flags = flags
      }
    , Cmd.none
    )



-- VIEW


view : Model -> Html.Html Message
view { sidebar, page } =
    Html.div []
        [ Html.map SidebarMessage (Sidebar.view sidebar)
        , Html.map PageMessage (Page.view page)
        ]



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        OnLocationChange location ->
            ( { model | page = ( location |> parseLocation, model.flags ) |> getPage }, Cmd.none )

        PageMessage pageMessage ->
            let
                ( newPage, newCmd ) =
                    Page.update pageMessage model.page
            in
            ( { model | page = newPage }, Cmd.map PageMessage newCmd )

        SidebarMessage sidebarMessage ->
            let
                ( newSidebar, newCmd ) =
                    Sidebar.update sidebarMessage model.sidebar
            in
            ( { model | sidebar = newSidebar }, Cmd.map SidebarMessage newCmd )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions { sidebar } =
    Sub.batch [ Sub.map SidebarMessage (Sidebar.subscriptions sidebar) ]



-- MAIN


main : Program Flags Model Message
main =
    Navigation.programWithFlags OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
