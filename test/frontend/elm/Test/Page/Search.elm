module Test.Page.Search exposing (..)

import Expect
import Page.Search exposing (..)
import Test exposing (..)
import Data.Account exposing (..)
import Json.Decode as JD


tests : Test
tests =
    let
        flags =
            { node_env = "test" }
    in
        describe "Page.Search module"
            [ describe "accountDecoder"
                [ test "Account parsing (core_liquid_balance field doesn't exist)" <|
                    \() ->
                        let
                            accountJson =
                                "{\"account_name\":\"123412341234\",\"head_block_num\":5992161,\"head_block_time\":\"2018-07-15T10:04:48.000\",\"privileged\":false,\"last_code_update\":\"1970-01-01T00:00:00.000\",\"created\":\"2018-06-10T13:27:46.500\",\"ram_quota\":3050,\"net_weight\":0,\"cpu_weight\":0,\"net_limit\":{\"used\":0,\"available\":0,\"max\":0},\"cpu_limit\":{\"used\":0,\"available\":0,\"max\":0},\"ram_usage\":2996,\"permissions\":[{\"perm_name\":\"active\",\"parent\":\"owner\",\"required_auth\":{\"threshold\":1,\"keys\":[{\"key\":\"EOS7hctUrtLvTBR2W1aHbTpDV7py5DGSvsqXasr3eSY9vmjonJCpE\",\"weight\":1}],\"accounts\":[],\"waits\":[]}},{\"perm_name\":\"owner\",\"parent\":\"\",\"required_auth\":{\"threshold\":1,\"keys\":[{\"key\":\"EOS7hctUrtLvTBR2W1aHbTpDV7py5DGSvsqXasr3eSY9vmjonJCpE\",\"weight\":1}],\"accounts\":[],\"waits\":[]}}],\"total_resources\":{\"owner\":\"123412341234\",\"net_weight\":\"0.0000 EOS\",\"cpu_weight\":\"0.0000 EOS\",\"ram_bytes\":3050},\"self_delegated_bandwidth\":null,\"refund_request\":null,\"voter_info\":null}"

                            expectedAccount =
                                Account
                                    "123412341234"
                                    "0 EOS"
                                    (VoterInfo 0)
                                    3050
                                    2996
                                    (Resource 0 0 0)
                                    (Resource 0 0 0)
                                    (ResourceInEos "0.0000 EOS" "0.0000 EOS" (Just 3050))
                                    (ResourceInEos "0 EOS" "0 EOS" Nothing)
                                    (Refund "" "" "0 EOS" "0 EOS")
                        in
                            Expect.equal (Ok expectedAccount) (JD.decodeString accountDecoder accountJson)
                , test "Account parsing (core_liquid_balance field exists)" <|
                    \() ->
                        let
                            accountJson =
                                "{\"account_name\":\"eosyskoreabp\",\"head_block_num\":6014531,\"head_block_time\":\"2018-07-15T13:12:56.000\",\"privileged\":false,\"last_code_update\":\"1970-01-01T00:00:00.000\",\"created\":\"2018-06-10T13:04:24.500\",\"core_liquid_balance\":\"9159.2669 EOS\",\"ram_quota\":65741,\"net_weight\":14199066,\"cpu_weight\":14199066,\"net_limit\":{\"used\":105,\"available\":778970655,\"max\":778970760},\"cpu_limit\":{\"used\":11533,\"available\":148290056,\"max\":148301589},\"ram_usage\":4223,\"permissions\":[{\"perm_name\":\"active\",\"parent\":\"owner\",\"required_auth\":{\"threshold\":1,\"keys\":[{\"key\":\"EOS6eFyNhE7d387tnKpQEKXR9MQ1c9hsJ28Ddyi5Cism1JHJiDauX\",\"weight\":1}],\"accounts\":[],\"waits\":[]}},{\"perm_name\":\"owner\",\"parent\":\"\",\"required_auth\":{\"threshold\":1,\"keys\":[{\"key\":\"EOS5pBCbpmN3raABMhUa36CxXWBP3rty9wioCNTCtr3zmC5z7rwYk\",\"weight\":1}],\"accounts\":[],\"waits\":[]}}],\"total_resources\":{\"owner\":\"eosyskoreabp\",\"net_weight\":\"1419.9066 EOS\",\"cpu_weight\":\"1419.9066 EOS\",\"ram_bytes\":65741},\"self_delegated_bandwidth\":{\"from\":\"eosyskoreabp\",\"to\":\"eosyskoreabp\",\"net_weight\":\"1416.9066 EOS\",\"cpu_weight\":\"1416.9066 EOS\"},\"refund_request\":null,\"voter_info\":{\"owner\":\"eosyskoreabp\",\"proxy\":\"\",\"producers\":[\"eosyskoreabp\"],\"staked\":28348132,\"last_vote_weight\":\"10650460953284.50585937500000000\",\"proxied_vote_weight\":\"0.00000000000000000\",\"is_proxy\":0}}"

                            expectedAccount =
                                Account
                                    "eosyskoreabp"
                                    "9159.2669 EOS"
                                    (VoterInfo 28348132)
                                    65741
                                    4223
                                    (Resource 105 778970655 778970760)
                                    (Resource 11533 148290056 148301589)
                                    (ResourceInEos "1419.9066 EOS" "1419.9066 EOS" (Just 65741))
                                    (ResourceInEos "1416.9066 EOS" "1416.9066 EOS" Nothing)
                                    (Refund "" "" "0 EOS" "0 EOS")
                        in
                            Expect.equal (Ok expectedAccount) (JD.decodeString accountDecoder accountJson)
                ]
            , describe "keyAccountsDecoder"
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
