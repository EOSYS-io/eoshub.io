module Message exposing (Message(..))

import Navigation exposing (Location)
import Page
import Sidebar


-- MESSAGE


type Message
    = OnLocationChange Location
    | PageMessage Page.Message
    | SidebarMessage Sidebar.Message
