module Test.Page exposing (..)

import Expect
import Navigation exposing (Location)
import Page exposing (..)
import Page.Search as Search
import Page.Transfer as Transfer
import Page.Voting as Voting
import Test exposing (..)
import View.Notification
import Data.Account exposing (..)
import Json.Decode as JD


location : Location
location =
    { href = ""
    , host = ""
    , hostname = ""
    , protocol = ""
    , origin = ""
    , port_ = ""
    , pathname = "/none"
    , search = ""
    , hash = ""
    , username = ""
    , password = ""
    }


tests : Test
tests =
    let
        confirmToken =
            "test"
    in
    describe "Page module"
        [ describe "getPage"
            [ test "IndexRoute" <|
                \() -> Expect.equal IndexPage (getPage { location | pathname = "/" } confirmToken)
            , test "VotingRoute" <|
                \() -> Expect.equal (VotingPage Voting.initModel) (getPage { location | pathname = "/voting" } confirmToken)
            , test "TransferRoute" <|
                \() -> Expect.equal (TransferPage Transfer.initModel) (getPage { location | pathname = "/transfer" } confirmToken)
            , test "SearchRoute" <|
                \() -> Expect.equal (SearchPage Search.initModel) (getPage { location | pathname = "/search" } confirmToken)
            , test "NotFoundRoute" <|
                \() -> Expect.equal NotFoundPage (getPage location confirmToken)
            ]
        , describe "update"
            [ test "UpdateScatterResponse" <|
                \() ->
                    let
                        model =
                            initModel location

                        expectedModel =
                            { model | notification = View.Notification.Ok { code = 200, message = "\n" } }

                        scatterResponse =
                            { code = 200
                            , type_ = ""
                            , message = ""
                            }

                        flags =
                            { node_env = "test" }
                    in
                    Expect.equal
                        ( expectedModel, Cmd.none )
                        (update (UpdateScatterResponse scatterResponse) model flags)
            ]
        , describe
            "getFullPath"
            [ test "get_account" <|
                \() ->
                    Expect.equal (apiUrl ++ "/v1/chain/get_account") (getFullPath "/v1/chain/get_account")
            , test "get_key_accounts" <|
                \() ->
                    Expect.equal (apiUrl ++ "/v1/history/get_key_accounts") (getFullPath "/v1/history/get_key_accounts")
            ]
        , describe "parseQuery"
            [ test "account" <|
                \() ->
                    Expect.equal (Ok AccountQuery) (parseQuery "123412341234")
            , test "public key" <|
                \() ->
                    Expect.equal (Ok PublicKeyQuery) (parseQuery "EOS5uxjV3FYZvwqyAM2StkFEvUvf43F7gSrZcBpunuuTxiYkKqb6d")
            , test "public key, does not start with 'EOS' " <|
                \() ->
                    Expect.equal (Err "invalid input") (parseQuery "eos5uxjV3FYZvwqyAM2StkFEvUvf43F7gSrZcBpunuuTxiYkKqb6d")
            , test "not both" <|
                \() ->
                    Expect.equal (Err "invalid input") (parseQuery "12345678901234567890")
            ]
        , describe "isAccount"
            [ test "a-z.1-5 True" <|
                \() ->
                    Expect.equal (True) (isAccount "abc.xyz12345")
            , test "a-z.1-5 False" <|
                \() ->
                    Expect.equal (False) (isAccount "ABC!@#$67890")
            , test "{1,12} True" <|
                \() ->
                    Expect.equal (True) (isAccount "eosio.ram")
            , test "{1,12} False" <|
                \() ->
                    Expect.equal (False) (isAccount "eosio.ram.eosio.system")
            ]
        , describe "isPublicKey"
            [ test "start with EOS True" <|
                \() ->
                    Expect.equal (True) (isPublicKey "EOS5uxjV3FYZvwqyAM2StkFEvUvf43F7gSrZcBpunuuTxiYkKqb6d")
            , test "start with EOS False" <|
                \() ->
                    Expect.equal (False) (isPublicKey "eos5uxjV3FYZvwqyAM2StkFEvUvf43F7gSrZcBpunuuTxiYkKqb6d")
            , test "length 53 False" <|
                \() ->
                    Expect.equal (False) (isAccount "EOS5uxjV3FYZvwqyAM2StkFEvUvf43F7")
            ]
        , describe "accountDecoder"
            [ test "Account parsing (core_liquid_balance field doesn't exist)" <|
                \() ->
                    let
                        accountJson =
                            "{\"account_name\":\"123412341234\",\"head_block_num\":5992161,\"head_block_time\":\"2018-07-15T10:04:48.000\",\"privileged\":false,\"last_code_update\":\"1970-01-01T00:00:00.000\",\"created\":\"2018-06-10T13:27:46.500\",\"ram_quota\":3050,\"net_weight\":0,\"cpu_weight\":0,\"net_limit\":{\"used\":0,\"available\":0,\"max\":0},\"cpu_limit\":{\"used\":0,\"available\":0,\"max\":0},\"ram_usage\":2996,\"permissions\":[{\"perm_name\":\"active\",\"parent\":\"owner\",\"required_auth\":{\"threshold\":1,\"keys\":[{\"key\":\"EOS7hctUrtLvTBR2W1aHbTpDV7py5DGSvsqXasr3eSY9vmjonJCpE\",\"weight\":1}],\"accounts\":[],\"waits\":[]}},{\"perm_name\":\"owner\",\"parent\":\"\",\"required_auth\":{\"threshold\":1,\"keys\":[{\"key\":\"EOS7hctUrtLvTBR2W1aHbTpDV7py5DGSvsqXasr3eSY9vmjonJCpE\",\"weight\":1}],\"accounts\":[],\"waits\":[]}}],\"total_resources\":{\"owner\":\"123412341234\",\"net_weight\":\"0.0000 EOS\",\"cpu_weight\":\"0.0000 EOS\",\"ram_bytes\":3050},\"self_delegated_bandwidth\":null,\"refund_request\":null,\"voter_info\":null}"

                        expectedAccount =
                            Account
                                "123412341234"
                                "0 EOS"
                                3050
                                2996
                                (Resource 0 0 0)
                                (Resource 0 0 0)
                                (ResourceInEos "0.0000 EOS" "0.0000 EOS" (Just 3050))
                                (Nothing)
                                (Nothing)
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
                                65741
                                4223
                                (Resource 105 778970655 778970760)
                                (Resource 11533 148290056 148301589)
                                (ResourceInEos "1419.9066 EOS" "1419.9066 EOS" (Just 65741))
                                (Just (ResourceInEos "1416.9066 EOS" "1416.9066 EOS" Nothing))
                                (Nothing)
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
