module Main exposing (..)

import Html
import Html.Attributes exposing (class)
import Navigation exposing (Location)
import Page
import Sidebar
import Util.Flags exposing (Flags)


-- MODEL


type alias Model =
    { sidebar : Sidebar.Model
    , page : Page.Model
    , flags : Flags
    }



-- MESSAGE


type Message
    = PageMessage Page.Message
    | SidebarMessage Sidebar.Message



-- INIT


init : Flags -> Location -> ( Model, Cmd Message )
init flags location =
    ( { sidebar = Sidebar.initModel
      , page = Page.initModel location
      , flags = flags
      }
    , Cmd.none
    )



-- VIEW


view : Model -> Html.Html Message
view { sidebar, page } =
    Html.div [ class "container" ]
        [ Html.map SidebarMessage (Html.div [ Sidebar.foldClass sidebar.fold ] (Sidebar.view sidebar))
        , Html.map PageMessage (Page.view sidebar.language page)
        ]



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        PageMessage pageMessage ->
            let
                ( newPage, newCmd ) =
                    Page.update pageMessage model.page model.flags
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
subscriptions { sidebar, page } =
    Sub.batch
        [ Sub.map SidebarMessage (Sidebar.subscriptions sidebar)
        , Sub.map PageMessage (Page.subscriptions page)
        ]



-- MAIN


main : Program Flags Model Message
main =
    Navigation.programWithFlags (PageMessage << Page.OnLocationChange)
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
