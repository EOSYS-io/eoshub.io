module Message exposing (Message(..))

import Navigation exposing (Location)
import Header
import Page
import Sidebar


-- MESSAGE


type Message
    = OnLocationChange Location
    | HeaderMessage Header.Message
    | PageMessage Page.Message
    | SidebarMessage Sidebar.Message
