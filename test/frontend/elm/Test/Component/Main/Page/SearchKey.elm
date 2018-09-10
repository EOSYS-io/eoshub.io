module Test.Component.Main.Page.SearchKey exposing (tests)

import Data.Account exposing (..)
import Expect
import Json.Decode as JD
import Test exposing (..)


tests : Test
tests =
    let
        flags =
            { node_env = "test" }
    in
    describe "Page.SearchKey module"
        [ describe "keyAccountsDecoder"
            [ test "Accounts List parsing" <|
                \() ->
                    let
                        keyAccountsJson =
                            "{\"account_names\":[\"eosswedenorg\"]}"

                        expectedAccountsList =
                            [ "eosswedenorg" ]
                    in
                    Expect.equal (Ok expectedAccountsList) (JD.decodeString keyAccountsDecoder keyAccountsJson)
            ]
        ]
