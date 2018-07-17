module Page exposing (..)

import ExternalMessage
import Html exposing (Html)
import Navigation exposing (Location)
import Page.Index as Index
import Page.NotFound as NotFound
import Page.Search as Search
import Page.Transfer as Transfer
import Page.Voting as Voting
import Port
import Route exposing (Route(..), parseLocation)
import Translation exposing (Language)
import Util.WalletDecoder exposing (ScatterResponse, decodeScatterResponse)
import View.Notification


-- MODEL


type Page
    = IndexPage
    | SearchPage Search.Model
    | TransferPage Transfer.Model
    | VotingPage Voting.Model
    | NotFoundPage


type alias Model =
    { page : Page
    , notification : View.Notification.Message
    }


initModel : Location -> Model
initModel location =
    { page = location |> getPage
    , notification = View.Notification.None
    }



-- MESSAGE


type Message
    = SearchMessage Search.Message
    | VotingMessage Voting.Message
    | TransferMessage Transfer.Message
    | IndexMessage ExternalMessage.Message
    | UpdateScatterResponse ScatterResponse
    | OnLocationChange Location



-- VIEW


view : Language -> Model -> Html Message
view language { page } =
    case page of
        SearchPage subModel ->
            Html.map SearchMessage (Search.view language subModel)

        VotingPage subModel ->
            Html.map VotingMessage (Voting.view language subModel)

        TransferPage subModel ->
            Html.map TransferMessage (Transfer.view language subModel)

        IndexPage ->
            Html.map IndexMessage (Index.view language)

        _ ->
            NotFound.view language



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message ({ page } as model) =
    case ( message, page ) of
        ( SearchMessage subMessage, SearchPage subModel ) ->
            let
                newPage =
                    Search.update subMessage subModel
            in
                ( { model | page = newPage |> SearchPage }, Cmd.none )

        ( TransferMessage subMessage, TransferPage subModel ) ->
            let
                ( newPage, subCmd ) =
                    (Transfer.update subMessage subModel)
            in
                ( { model | page = newPage |> TransferPage }, Cmd.map TransferMessage subCmd )

        ( VotingMessage subMessage, VotingPage subModel ) ->
            let
                newPage =
                    Voting.update subMessage subModel
            in
                ( { model | page = newPage |> VotingPage }, Cmd.none )

        ( IndexMessage (ExternalMessage.ChangeUrl url), _ ) ->
            ( model, Navigation.newUrl url )

        ( UpdateScatterResponse resp, _ ) ->
            ( { model | notification = resp |> decodeScatterResponse }, Cmd.none )

        ( OnLocationChange location, _ ) ->
            ( { model | page = location |> getPage }, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS --


subscriptions : Model -> Sub Message
subscriptions _ =
    Port.receiveScatterResponse UpdateScatterResponse



-- Utility functions


getPage : Location -> Page
getPage location =
    let
        route =
            location |> parseLocation
    in
        case route of
            SearchRoute ->
                SearchPage Search.initModel

            VotingRoute ->
                VotingPage Voting.initModel

            TransferRoute ->
                TransferPage Transfer.initModel

            IndexRoute ->
                IndexPage

            NotFoundRoute ->
                NotFoundPage
