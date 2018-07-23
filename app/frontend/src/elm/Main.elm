module Main exposing (..)

import Html
import Html.Attributes exposing (class)
import Navigation exposing (Location)
import DefaultPageGroup
import AccountPageGroup
import Sidebar
import Util.Flags exposing (Flags)
import Route exposing (getPageGroupRoute)
import Dict exposing (Dict)
import Util.WalletDecoder exposing (Wallet)


-- MODEL


type PageGroup
    = DefaultPageGroup DefaultPageGroup.Model
    | AccountPageGroup AccountPageGroup.Model


type alias Model =
    { sidebar : Sidebar.Model
    , currentPageGroup : PageGroup
    , flags : Flags
    , pageGroups : Dict String PageGroup
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
        ( newPageGroup, cmd, newPageGroups ) =
            initPageGroup location
    in
        ( { sidebar = Sidebar.initModel
          , currentPageGroup = newPageGroup
          , flags = flags
          , pageGroups = newPageGroups
          }
        , cmd
        )



-- VIEW


view : Model -> Html.Html Message
view { sidebar, currentPageGroup } =
    case currentPageGroup of
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
update message ({ currentPageGroup, flags, sidebar, pageGroups } as model) =
    case ( message, currentPageGroup ) of
        ( DefaultPageGroupMessage defaultPageGroupMessage, DefaultPageGroup subModel ) ->
            let
                ( newPageGroupModel, newCmd ) =
                    DefaultPageGroup.update defaultPageGroupMessage subModel sidebar.wallet

                newPageGroup =
                    DefaultPageGroup newPageGroupModel
            in
                ( { model | currentPageGroup = newPageGroup }, Cmd.map DefaultPageGroupMessage newCmd )

        ( AccountPageGroupMessage accountPageGroupMessage, AccountPageGroup subModel ) ->
            let
                ( newPageGroupModel, newCmd ) =
                    AccountPageGroup.update accountPageGroupMessage subModel flags

                newPageGroup =
                    AccountPageGroup newPageGroupModel
            in
                ( { model | currentPageGroup = newPageGroup }, Cmd.map AccountPageGroupMessage newCmd )

        ( SidebarMessage sidebarMessage, _ ) ->
            let
                ( newSidebar, newCmd ) =
                    Sidebar.update sidebarMessage sidebar
            in
                ( { model | sidebar = newSidebar }, Cmd.map SidebarMessage newCmd )

        ( OnLocationChange location, _ ) ->
            let
                ( newPageGroup, cmd, newPageGroups ) =
                    updatePageGroup pageGroups location flags sidebar.wallet
            in
                ( { model | currentPageGroup = newPageGroup }, cmd )

        ( _, _ ) ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions { sidebar, currentPageGroup } =
    case currentPageGroup of
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


initPageGroup : Location -> ( PageGroup, Cmd Message, Dict String PageGroup )
initPageGroup location =
    let
        pageGroupRoute =
            getPageGroupRoute location
    in
        case pageGroupRoute of
            Route.DefaultPageGroupRoute ->
                let
                    pageGroupModel =
                        DefaultPageGroup.initModel location

                    pageGroup =
                        DefaultPageGroup pageGroupModel

                    pageGroupCmd =
                        Cmd.map DefaultPageGroupMessage (DefaultPageGroup.initCmd location)
                in
                    ( pageGroup, pageGroupCmd, Dict.insert "DefaultPageGroup" pageGroup Dict.empty )

            Route.AccountPageGroupRoute ->
                let
                    pageGroupModel =
                        AccountPageGroup.initModel location

                    pageGroup =
                        AccountPageGroup pageGroupModel

                    pageGroupCmd =
                        Cmd.map AccountPageGroupMessage (AccountPageGroup.initCmd pageGroupModel)
                in
                    ( pageGroup, pageGroupCmd, Dict.insert "AccountPageGroup" pageGroup Dict.empty )


updatePageGroup : Dict String PageGroup -> Location -> Flags -> Wallet -> ( PageGroup, Cmd Message, Dict String PageGroup )
updatePageGroup pageGroups location flags wallet =
    let
        pageGroupRoute =
            getPageGroupRoute location
    in
        case pageGroupRoute of
            Route.DefaultPageGroupRoute ->
                let
                    maybePageGroup =
                        Dict.get "DefaultPageGroupModel" pageGroups

                    pageGroupModel =
                        case maybePageGroup of
                            Just (DefaultPageGroup subModel) ->
                                subModel

                            _ ->
                                DefaultPageGroup.initModel location

                    ( newPageGroupModel, newCmd ) =
                        DefaultPageGroup.update (DefaultPageGroup.OnLocationChange location) pageGroupModel wallet

                    pageGroup =
                        DefaultPageGroup newPageGroupModel
                in
                    ( pageGroup, Cmd.map DefaultPageGroupMessage newCmd, Dict.insert "DefaultPageGroup" pageGroup pageGroups )

            Route.AccountPageGroupRoute ->
                let
                    maybePageGroup =
                        Dict.get "AccountPageGroup" pageGroups

                    pageGroupModel =
                        case maybePageGroup of
                            Just (AccountPageGroup subModel) ->
                                subModel

                            _ ->
                                AccountPageGroup.initModel location

                    ( newPageGroupModel, newCmd ) =
                        AccountPageGroup.update (AccountPageGroup.OnLocationChange location) pageGroupModel flags

                    pageGroup =
                        AccountPageGroup newPageGroupModel
                in
                    ( pageGroup, Cmd.map AccountPageGroupMessage newCmd, Dict.insert "AccountPageGroup" pageGroup pageGroups )
