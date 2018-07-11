module Message exposing (Message(..))

import Navigation exposing (Location)
import Page


-- MESSAGE


type Message
    = CheckWalletStatus
    | UpdateWalletStatus { status : String, account : String, authority : String }
    | AuthenticateAccount
    | InvalidateAccount
    | UpdateScatterResponse { code : Int, type_ : String, message : String }
    | OnLocationChange Location
    | PageMessage Page.Message
