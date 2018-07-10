module Message exposing (..)

import Navigation exposing (Location)
import Page.Search as Search
import Page.Voting as Voting
import Page.Transfer as Transfer


-- MESSAGE


type Message
    = CheckWalletStatus -- TODO(heejae): Modify CheckWalletStatus to have a name of Wallet plugin(ex. Scatter).
    | UpdateWalletStatus { status : String, account : String, authority : String }
    | AuthenticateAccount
    | InvalidateAccount
    | UpdateScatterResponse { code : Int, type_ : String, message : String }
    | OnLocationChange Location
    | SearchMessage Search.Message
    | VotingMessage Voting.Message
    | TransferMessage Transfer.Message
