module Page.SearchKey exposing (..)

import Html exposing (Html, div)
import Http


-- MODEL


type alias Model =
    { accounts : List String
    }


initModel : Model
initModel =
    { accounts = []
    }


initCmd : String -> Cmd Message
initCmd query =
    let
        newCmd =
            Cmd.none
    in
        newCmd



-- UPDATE


type Message
    = OnFetchKeyAccounts (Result Http.Error (List String))



-- VIEW


view : Model -> Html Message
view model =
    div [] []
