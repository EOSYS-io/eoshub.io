module Model exposing (Model, updatePage)

import Message exposing (Message(..))
import Page exposing (Page(..))
import Page.Search as Search
import Page.Transfer as Transfer
import Page.Voting as Voting
import View.Notification
import Wallet


-- MODEL


type alias Model =
    { walletStatus : Wallet.WalletStatus
    , page : Page
    , notification : View.Notification.Msg
    }



-- Utility Function


updatePage : Message -> Page -> Model -> ( Model, Cmd Message )
updatePage msg page model =
    case ( msg, page ) of
        ( SearchMessage subMsg, SearchPage subModel ) ->
            let
                newModel =
                    Search.update subMsg subModel
            in
                ( { model | page = newModel |> SearchPage }, Cmd.none )

        ( TransferMessage subMsg, TransferPage subModel ) ->
            let
                ( newModel, subCmd ) =
                    (Transfer.update subMsg subModel)
            in
                ( { model | page = newModel |> TransferPage }, Cmd.map TransferMessage subCmd )

        ( VotingMessage subMsg, VotingPage subModel ) ->
            let
                newModel =
                    Voting.update subMsg subModel
            in
                ( { model | page = newModel |> VotingPage }, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )
