module Main exposing (..)

import Html
import Html.Attributes exposing (class)
import Navigation exposing (Location)
import Page
import Sidebar
import Header


-- MODEL


type alias Model =
    { header : Header.Model
    , sidebar : Sidebar.Model
    , page : Page.Model
    }



-- MESSAGE


type Message
    = HeaderMessage Header.Message
    | PageMessage Page.Message
    | SidebarMessage Sidebar.Message



-- INIT


init : Location -> ( Model, Cmd Message )
init location =
    ( { header = Header.initModel
      , sidebar = Sidebar.initModel
      , page = Page.initModel location
      }
    , Cmd.none
    )



-- VIEW


view : Model -> Html.Html Message
view { header, sidebar, page } =
    Html.div [ class "container" ]
        [ Html.map SidebarMessage (Html.div [ Sidebar.foldClass sidebar.fold ] (Sidebar.view sidebar))
        , Html.div [ class "wrapper" ]
            [ Html.map HeaderMessage (Header.view header)
            , Html.map PageMessage (Page.view sidebar.language page)
            ]
        ]



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        HeaderMessage headerMessage ->
            let
                ( newHeader, newCmd ) =
                    Header.update headerMessage model.header
            in
                ( { model | header = newHeader }, Cmd.map HeaderMessage newCmd )

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
subscriptions { sidebar, page } =
    Sub.batch
        [ Sub.map SidebarMessage (Sidebar.subscriptions sidebar)
        , Sub.map PageMessage (Page.subscriptions page)
        ]



-- MAIN


main : Program Never Model Message
main =
    Navigation.program (PageMessage << Page.OnLocationChange)
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
