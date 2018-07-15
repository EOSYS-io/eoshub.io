module Main exposing (..)

import Html
import Html.Attributes exposing (class)
import Message exposing (Message(..))
import Navigation exposing (Location)
import Page exposing (Page(..), getPage)
import Route exposing (Route(..), parseLocation)
import Sidebar


-- MODEL


type alias Model =
    { sidebar : Sidebar.Model
    , page : Page
    }



-- INIT


init : Location -> ( Model, Cmd Message )
init location =
    ( { sidebar = Sidebar.initModel
      , page = location |> parseLocation |> getPage
      }
    , Cmd.none
    )



-- VIEW


view : Model -> Html.Html Message
view { sidebar, page } =
    Html.div [ class "container" ]
        [ Html.map SidebarMessage (Html.div [ class "sidebar" ] (Sidebar.view sidebar))
        , Html.div [ class "wrapper" ] [ Html.map PageMessage (Page.view page) ]
        ]



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        OnLocationChange location ->
            ( { model | page = location |> parseLocation |> getPage }, Cmd.none )

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


main : Program Never Model Message
main =
    Navigation.program OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
