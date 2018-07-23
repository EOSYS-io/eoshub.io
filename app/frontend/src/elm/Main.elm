module Main exposing (..)

import Html
import Html.Attributes exposing (class)
import Navigation exposing (Location)
import DefaultPageGroup
import AccountPageGroup
import Sidebar
import Util.Flags exposing (Flags)
import Route exposing (getPageGroupRoute)


-- MODEL


type PageGroup
    = DefaultPageGroup DefaultPageGroup.Model
    | AccountPageGroup AccountPageGroup.Model


type alias Model =
    { sidebar : Sidebar.Model
    , pageGroup : PageGroup
    , flags : Flags
    }


-- MESSAGE


type Message
    = DefaultPageGroupMessage DefaultPageGroup.Message
    | AccountPageGroupMessage AccountPageGroup.Message
    | SidebarMessage Sidebar.Message
    | OnLocationChange Location



-- INIT


init : Flags -> Location -> ( Model, Cmd Message )
init flags location =
    let
        ( pageGroup, cmd ) =
            getPageGroup location
    in
        ( { sidebar = Sidebar.initModel
          , pageGroup = pageGroup
          , flags = flags
          }
        , cmd
        )



-- VIEW


view : Model -> Html.Html Message
view { sidebar, pageGroup } =
    case pageGroup of
        DefaultPageGroup subModel ->
            Html.div [ class "container" ]
                [ Html.map SidebarMessage (Html.div [ Sidebar.foldClass sidebar.fold ] (Sidebar.view sidebar))
                , Html.div [ class "wrapper" ]
                    (List.map (Html.map DefaultPageGroupMessage) (DefaultPageGroup.view sidebar.language subModel))
                ]

        AccountPageGroup subModel ->
            Html.div []
                (List.map (Html.map AccountPageGroupMessage) (AccountPageGroup.view sidebar.language subModel))


-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message ({ pageGroup, flags, sidebar } as model) =
    case ( message, pageGroup ) of
        ( DefaultPageGroupMessage defaultPageGroupMessage, DefaultPageGroup subModel ) ->
            let
                ( newPageGroupModel, newCmd ) =
                    DefaultPageGroup.update defaultPageGroupMessage subModel flags sidebar.wallet

                newPageGroup =
                    DefaultPageGroup newPageGroupModel
            in
                ( { model | pageGroup = newPageGroup }, Cmd.map DefaultPageGroupMessage newCmd )

        ( AccountPageGroupMessage accountPageGroupMessage, AccountPageGroup subModel ) ->
            let
                ( newPageGroupModel, newCmd ) =
                    AccountPageGroup.update accountPageGroupMessage subModel flags sidebar.wallet

                newPageGroup =
                    AccountPageGroup newPageGroupModel
            in
                ( { model | pageGroup = newPageGroup }, Cmd.map AccountPageGroupMessage newCmd )

        ( SidebarMessage sidebarMessage, _ ) ->
            let
                ( newSidebar, newCmd ) =
                    Sidebar.update sidebarMessage sidebar
            in
                ( { model | sidebar = newSidebar }, Cmd.map SidebarMessage newCmd )

        ( OnLocationChange location, _ ) ->
            let
                (newPageGroup, cmd) =
                    getPageGroup location
            in
                ( { model | pageGroup = newPageGroup }, cmd )

        ( _, _ ) ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions { sidebar, pageGroup } =
    case pageGroup of
        DefaultPageGroup subModel ->
            Sub.batch
                [ Sub.map SidebarMessage (Sidebar.subscriptions sidebar) ]

        AccountPageGroup subModel ->
            Sub.batch
                [ Sub.map AccountPageGroupMessage (AccountPageGroup.subscriptions subModel) ]


-- MAIN


main : Program Flags Model Message
main =
    Navigation.programWithFlags OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


-- UTILS


getPageGroup : Location -> ( PageGroup, Cmd Message )
getPageGroup location =
    let
        pageGroupRoute =
            getPageGroupRoute location
    in
    case pageGroupRoute of
        Route.DefaultPageGroupRoute ->
            let
                pageGroupModel =
                    DefaultPageGroup.initModel location

                pageGroupCmd =
                    DefaultPageGroup.initCmd location pageGroupModel.page
            in
            ( DefaultPageGroup pageGroupModel, Cmd.map DefaultPageGroupMessage pageGroupCmd )
        
        Route.AccountPageGroupRoute ->
            let
                pageGroupModel =
                    AccountPageGroup.initModel location

                pageGroupCmd =
                    AccountPageGroup.initCmd pageGroupModel.page
            in
            ( AccountPageGroup pageGroupModel, Cmd.map AccountPageGroupMessage pageGroupCmd )