module Test.Page.SearchKey exposing (..)

import Expect
import Test exposing (..)
import Data.Account exposing (..)
import Json.Decode as JD


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



-- TODO(boseok): getTotalAmount getUnstakingAmount getResource larimerToEos eosFloatToString eosStringToFloat
