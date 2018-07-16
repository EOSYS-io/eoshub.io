module Test.Header exposing (tests)

import Expect
import Header exposing (..)
import Test exposing (..)
import Json.Decode as JD


tests : Test
tests =
    describe "Header module"
        [ describe "update"
            -- TODO:(boseok): update function test
            []
        , describe "parseQuery"
            [ test "account" <|
                \() ->
                    Expect.equal (Ok AccountQuery) (parseQuery "123412341234")
            , test "public key" <|
                \() ->
                    Expect.equal (Ok PublicKeyQuery) (parseQuery "EOS5uxjV3FYZvwqyAM2StkFEvUvf43F7gSrZcBpunuuTxiYkKqb6d")
            , test "not both" <|
                \() ->
                    Expect.equal (Err "invalid input") (parseQuery "123")
            ]
        , describe "accountDecoder"
            [ test "Account parsing (core_ram_liquid field doesn't exist)" <|
                \() ->
                    let
                        accountJson =
                            "{\"account_name\":\"123412341234\",\"head_block_num\":5992161,\"head_block_time\":\"2018-07-15T10:04:48.000\",\"privileged\":false,\"last_code_update\":\"1970-01-01T00:00:00.000\",\"created\":\"2018-06-10T13:27:46.500\",\"ram_quota\":3050,\"net_weight\":0,\"cpu_weight\":0,\"net_limit\":{\"used\":0,\"available\":0,\"max\":0},\"cpu_limit\":{\"used\":0,\"available\":0,\"max\":0},\"ram_usage\":2996,\"permissions\":[{\"perm_name\":\"active\",\"parent\":\"owner\",\"required_auth\":{\"threshold\":1,\"keys\":[{\"key\":\"EOS7hctUrtLvTBR2W1aHbTpDV7py5DGSvsqXasr3eSY9vmjonJCpE\",\"weight\":1}],\"accounts\":[],\"waits\":[]}},{\"perm_name\":\"owner\",\"parent\":\"\",\"required_auth\":{\"threshold\":1,\"keys\":[{\"key\":\"EOS7hctUrtLvTBR2W1aHbTpDV7py5DGSvsqXasr3eSY9vmjonJCpE\",\"weight\":1}],\"accounts\":[],\"waits\":[]}}],\"total_resources\":{\"owner\":\"123412341234\",\"net_weight\":\"0.0000 EOS\",\"cpu_weight\":\"0.0000 EOS\",\"ram_bytes\":3050},\"self_delegated_bandwidth\":null,\"refund_request\":null,\"voter_info\":null}"

                        expectedAccount =
                            Account "123412341234" Nothing (Resource "0.0000 EOS" "0.0000 EOS" 3050)
                    in
                        Expect.equal (Ok expectedAccount) (JD.decodeString accountDecoder accountJson)
            , test "Account parsing (core_ram_liquild field exists)" <|
                \() ->
                    let
                        accountJson =
                            "{\"account_name\":\"eosyskoreabp\",\"head_block_num\":6014531,\"head_block_time\":\"2018-07-15T13:12:56.000\",\"privileged\":false,\"last_code_update\":\"1970-01-01T00:00:00.000\",\"created\":\"2018-06-10T13:04:24.500\",\"core_liquid_balance\":\"9159.2669 EOS\",\"ram_quota\":65741,\"net_weight\":14199066,\"cpu_weight\":14199066,\"net_limit\":{\"used\":105,\"available\":778970655,\"max\":778970760},\"cpu_limit\":{\"used\":11533,\"available\":148290056,\"max\":148301589},\"ram_usage\":4223,\"permissions\":[{\"perm_name\":\"active\",\"parent\":\"owner\",\"required_auth\":{\"threshold\":1,\"keys\":[{\"key\":\"EOS6eFyNhE7d387tnKpQEKXR9MQ1c9hsJ28Ddyi5Cism1JHJiDauX\",\"weight\":1}],\"accounts\":[],\"waits\":[]}},{\"perm_name\":\"owner\",\"parent\":\"\",\"required_auth\":{\"threshold\":1,\"keys\":[{\"key\":\"EOS5pBCbpmN3raABMhUa36CxXWBP3rty9wioCNTCtr3zmC5z7rwYk\",\"weight\":1}],\"accounts\":[],\"waits\":[]}}],\"total_resources\":{\"owner\":\"eosyskoreabp\",\"net_weight\":\"1419.9066 EOS\",\"cpu_weight\":\"1419.9066 EOS\",\"ram_bytes\":65741},\"self_delegated_bandwidth\":{\"from\":\"eosyskoreabp\",\"to\":\"eosyskoreabp\",\"net_weight\":\"1416.9066 EOS\",\"cpu_weight\":\"1416.9066 EOS\"},\"refund_request\":null,\"voter_info\":{\"owner\":\"eosyskoreabp\",\"proxy\":\"\",\"producers\":[\"eosyskoreabp\"],\"staked\":28348132,\"last_vote_weight\":\"10650460953284.50585937500000000\",\"proxied_vote_weight\":\"0.00000000000000000\",\"is_proxy\":0}}"

                        expectedAccount =
                            Account "eosyskoreabp" (Just "9159.2669 EOS") (Resource "1419.9066 EOS" "1419.9066 EOS" 65741)
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
