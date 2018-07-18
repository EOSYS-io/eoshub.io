module Main exposing (..)

import Header
import Html
import Html.Attributes exposing (class)
import Navigation exposing (Location)
import Page
import Sidebar
import Util.Flags exposing (Flags)


-- MODEL


type alias Model =
    { header : Header.Model
    , sidebar : Sidebar.Model
    , page : Page.Model
    , flags : Flags
    }



-- MESSAGE


type Message
    = HeaderMessage Header.Message
    | PageMessage Page.Message
    | SidebarMessage Sidebar.Message



-- INIT


init : Flags -> Location -> ( Model, Cmd Message )
init flags location =
    ( { header = Header.initModel
      , sidebar = Sidebar.initModel
      , page = Page.initModel location
      , flags = flags
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
subscriptions model =
    Sub.batch
        [ Sub.map SidebarMessage (Sidebar.subscriptions model.sidebar)
        , Sub.map PageMessage (Page.subscriptions model.page)
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
