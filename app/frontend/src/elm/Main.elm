module Main exposing (..)

import Html
import Html.Attributes exposing (class)
import Navigation exposing (Location)
import Component.MainComponent as MainComponent
import Component.AccountComponent as AccountComponent
import Component.SidebarComponent as SidebarComponent
import Util.Flags exposing (Flags)
import Route exposing (getComponentRoute)
import Dict exposing (Dict)
import Util.WalletDecoder exposing (Wallet)


-- MODEL


type Component
    = MainComponent MainComponent.Model
    | AccountComponent AccountComponent.Model


type alias Model =
    { sidebarComponent : SidebarComponent.Model
    , currentComponent : Component
    , flags : Flags
    }



-- MESSAGE


type Message
    = MainComponentMessage MainComponent.Message
    | AccountComponentMessage AccountComponent.Message
    | SidebarComponentMessage SidebarComponent.Message
    | OnLocationChange Location



-- INIT


init : Flags -> Location -> ( Model, Cmd Message )
init flags location =
    let
        ( newComponent, cmd ) =
            initComponent location
    in
        ( { sidebarComponent = SidebarComponent.initModel
          , currentComponent = newComponent
          , flags = flags
          }
        , cmd
        )



-- VIEW


view : Model -> Html.Html Message
view { sidebarComponent, currentComponent } =
    case currentComponent of
        MainComponent subModel ->
            Html.div [ class "container" ]
                [ Html.map SidebarComponentMessage (Html.div [ SidebarComponent.foldClass sidebarComponent.fold ] (SidebarComponent.view sidebarComponent))
                , Html.div [ class "wrapper" ]
                    (List.map (Html.map MainComponentMessage) (MainComponent.view sidebarComponent.language subModel))
                ]

        AccountComponent subModel ->
            Html.div []
                (List.map (Html.map AccountComponentMessage) (AccountComponent.view sidebarComponent.language subModel))



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message ({ currentComponent, flags, sidebarComponent } as model) =
    case ( message, currentComponent ) of
        ( MainComponentMessage mainComponentMessage, MainComponent subModel ) ->
            let
                ( newComponentModel, newCmd ) =
                    MainComponent.update mainComponentMessage subModel sidebarComponent.wallet

                newComponent =
                    MainComponent newComponentModel
            in
                ( { model | currentComponent = newComponent }, Cmd.map MainComponentMessage newCmd )

        ( AccountComponentMessage accountComponentMessage, AccountComponent subModel ) ->
            let
                ( newComponentModel, newCmd ) =
                    AccountComponent.update accountComponentMessage subModel flags

                newComponent =
                    AccountComponent newComponentModel
            in
                ( { model | currentComponent = newComponent }, Cmd.map AccountComponentMessage newCmd )

        ( SidebarComponentMessage sidebarComponentMessage, _ ) ->
            let
                ( newSidebarComponent, newCmd ) =
                    SidebarComponent.update sidebarComponentMessage sidebarComponent
            in
                ( { model | sidebarComponent = newSidebarComponent }, Cmd.map SidebarComponentMessage newCmd )

        ( OnLocationChange location, _ ) ->
            let
                ( newComponent, cmd ) =
                    updateComponent currentComponent location flags sidebarComponent.wallet
            in
                ( { model | currentComponent = newComponent }, cmd )

        ( _, _ ) ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions { sidebarComponent, currentComponent } =
    case currentComponent of
        MainComponent subModel ->
            Sub.batch
                [ Sub.map SidebarComponentMessage (SidebarComponent.subscriptions sidebarComponent) ]

        AccountComponent subModel ->
            Sub.batch
                [ Sub.map AccountComponentMessage (AccountComponent.subscriptions subModel) ]



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


initComponent : Location -> ( Component, Cmd Message )
initComponent location =
    let
        componentRoute =
            getComponentRoute location
    in
        case componentRoute of
            Route.MainComponentRoute ->
                let
                    componentModel =
                        MainComponent.initModel location

                    componentCmd =
                        MainComponent.initCmd location
                in
                    ( MainComponent componentModel, Cmd.map MainComponentMessage componentCmd )

            Route.AccountComponentRoute ->
                let
                    componentModel =
                        AccountComponent.initModel location

                    componentCmd =
                        AccountComponent.initCmd componentModel
                in
                    ( AccountComponent componentModel, Cmd.map AccountComponentMessage componentCmd )


updateComponent : Component -> Location -> Flags -> Wallet -> ( Component, Cmd Message )
updateComponent currentComponent location flags wallet =
    let
        componentRoute =
            getComponentRoute location
    in
        case componentRoute of
            Route.MainComponentRoute ->
                let
                    componentModel =
                        case currentComponent of
                            MainComponent subModel ->
                                subModel

                            _ ->
                                MainComponent.initModel location

                    ( newComponentModel, componentCmd ) =
                        MainComponent.update (MainComponent.OnLocationChange location) componentModel wallet
                in
                    ( MainComponent newComponentModel, Cmd.map MainComponentMessage componentCmd )

            Route.AccountComponentRoute ->
                let
                    componentModel =
                        case currentComponent of
                            AccountComponent subModel ->
                                subModel

                            _ ->
                                AccountComponent.initModel location

                    ( newComponentModel, componentCmd ) =
                        AccountComponent.update (AccountComponent.OnLocationChange location) componentModel flags
                in
                    ( AccountComponent newComponentModel, Cmd.map AccountComponentMessage componentCmd )
