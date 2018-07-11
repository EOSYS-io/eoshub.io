module Message exposing (Message(..))

import Navigation exposing (Location)
import Page.AccountCreate as AccountCreate
import Page.Search as Search
import Page.Transfer as Transfer
import Page.Voting as Voting


-- MESSAGE


type Message
    = CheckWalletStatus
    | UpdateWalletStatus { status : String, account : String, authority : String }
    | AuthenticateAccount
    | InvalidateAccount
    | UpdateScatterResponse { code : Int, type_ : String, message : String }
    | OnLocationChange Location
    | AccountCreateMessage AccountCreate.Message
    | SearchMessage Search.Message
    | VotingMessage Voting.Message
    | TransferMessage Transfer.Message
