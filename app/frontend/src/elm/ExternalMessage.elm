-- This module defines intermodule messages.
-- Note(heejae): I don't think this is a good solution.
-- Consider using elm-route-url package and refactor Main.


module ExternalMessage exposing (Message(..))


type Message
    = ChangeUrl String
