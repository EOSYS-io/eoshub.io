module Main exposing (..)

import Html
import Navigation exposing (Location)
import Component.Main.MainComponent as MainComponent
import Component.Account.AccountComponent as AccountComponent
import Util.Flags exposing (Flags)
import Route exposing (getComponentRoute)


-- MODEL


type Component
    = MainComponent MainComponent.Model
    | AccountComponent AccountComponent.Model


type alias Model =
    { currentComponent : Component
    , flags : Flags
    }



-- MESSAGE


type Message
    = MainComponentMessage MainComponent.Message
    | AccountComponentMessage AccountComponent.Message
    | OnLocationChange Location



-- INIT


init : Flags -> Location -> ( Model, Cmd Message )
init flags location =
    let
        ( newComponent, cmd ) =
            initComponent location
    in
        ( { currentComponent = newComponent
          , flags = flags
          }
        , cmd
        )



-- VIEW


view : Model -> Html.Html Message
view { currentComponent } =
    case currentComponent of
        MainComponent subModel ->
            Html.map MainComponentMessage (MainComponent.view subModel)

        AccountComponent subModel ->
            Html.map AccountComponentMessage (AccountComponent.view subModel)



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message ({ currentComponent, flags } as model) =
    case ( message, currentComponent ) of
        ( MainComponentMessage mainComponentMessage, MainComponent subModel ) ->
            let
                ( newComponentModel, newCmd ) =
                    MainComponent.update mainComponentMessage subModel

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

        ( OnLocationChange location, _ ) ->
            let
                ( newComponent, cmd ) =
                    updateComponent currentComponent location flags
            in
                ( { model | currentComponent = newComponent }, cmd )

        ( _, _ ) ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions { currentComponent } =
    case currentComponent of
        MainComponent subModel ->
            Sub.batch
                [ Sub.map MainComponentMessage (MainComponent.subscriptions subModel) ]

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
                        MainComponent.initCmd componentModel location
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


updateComponent : Component -> Location -> Flags -> ( Component, Cmd Message )
updateComponent currentComponent location flags =
    let
        componentRoute =
            getComponentRoute location
    in
        case componentRoute of
            Route.MainComponentRoute ->
                let
                    ( newComponentModel, componentCmd ) =
                        case currentComponent of
                            MainComponent subModel ->
                                subModel |> MainComponent.update (MainComponent.OnLocationChange location False)

                            _ ->
                                MainComponent.initModel location |> MainComponent.update (MainComponent.OnLocationChange location True)
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
