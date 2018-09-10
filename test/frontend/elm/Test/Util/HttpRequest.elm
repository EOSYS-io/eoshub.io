module Test.Util.HttpRequest exposing (tests)

import Expect
import Test exposing (..)
import Util.HttpRequest exposing (..)
import Util.Urls exposing (mainnetRpcUrl)


tests : Test
tests =
    let
        flags =
            { node_env = "test" }
    in
    describe "Unit.HttpRequest module"
        [ describe "getFullPath"
            [ test "get_account" <|
                \() ->
                    Expect.equal (mainnetRpcUrl ++ "/v1/chain/get_account") (getFullPath "/v1/chain/get_account")
            , test "get_key_accounts" <|
                \() ->
                    Expect.equal (mainnetRpcUrl ++ "/v1/history/get_key_accounts") (getFullPath "/v1/history/get_key_accounts")
            ]
        ]
