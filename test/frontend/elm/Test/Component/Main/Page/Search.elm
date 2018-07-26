module Test.Component.Main.Page.Search exposing (..)

import Data.Account exposing (..)
import Expect
import Json.Decode as JD
import Component.Main.Page.Search exposing (..)
import Test exposing (..)


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
            , describe "larimerToEos"
                [ test "10000 larimer == 1.0 EOS" <|
                    \() ->
                        Expect.equal 1.0 (larimerToEos 10000)
                ]
            , describe "eosFloatToString"
                [ test "0.1 -> \"0.1000 EOS\"" <|
                    \() ->
                        Expect.equal "0.1000 EOS" (eosFloatToString 0.1)
                ]
            , describe "eosStringToFloat"
                [ test "\"0.1 EOS\" -> 0.1" <|
                    \() ->
                        Expect.equal 0.1 (eosStringToFloat "0.1 EOS")
                ]
            , describe "getTotalAmount"
                [ test "arguments \"9159.2669 EOS\" 28348132 \"2.0000 EOS\" \"2.0000 EOS\"" <|
                    \() ->
                        Expect.equal "11998.0801 EOS" (getTotalAmount "9159.2669 EOS" 28348132 "2.0000 EOS" "2.0000 EOS")
                ]
            , describe "getUnstakingAmount"
                [ test "arguments \"2.0002 EOS\" \"3.0003 EOS\"" <|
                    \() ->
                        Expect.equal "5.0005 EOS" (getUnstakingAmount "2.0002 EOS" "3.0003 EOS")
                ]
            , describe "getResource"
                [ test "net max < 1024, percentage = 0%" <|
                    \() ->
                        let
                            expected =
                                ( "1000 bytes", "0.00%", "hell" )

                            resourceType =
                                "net"

                            used =
                                1000

                            available =
                                0

                            max =
                                1000
                        in
                            Expect.equal expected (getResource resourceType used available max)
                , test "net max < 1024, 0% < percentage < 25% " <|
                    \() ->
                        let
                            expected =
                                ( "1000 bytes", "20.00%", "hell" )

                            resourceType =
                                "net"

                            used =
                                800

                            available =
                                200

                            max =
                                1000
                        in
                            Expect.equal expected (getResource resourceType used available max)
                , test "net max < 1024, 25% <= percentage < 50%" <|
                    \() ->
                        let
                            expected =
                                ( "1000 bytes", "40.00%", "bad" )

                            resourceType =
                                "net"

                            used =
                                600

                            available =
                                400

                            max =
                                1000
                        in
                            Expect.equal expected (getResource resourceType used available max)
                , test "net max < 1024, 50% <= percentage < 75%" <|
                    \() ->
                        let
                            expected =
                                ( "1000 bytes", "70.00%", "good" )

                            resourceType =
                                "net"

                            used =
                                300

                            available =
                                700

                            max =
                                1000
                        in
                            Expect.equal expected (getResource resourceType used available max)
                , test "net max < 1024, 75% <= percentage < 100%" <|
                    \() ->
                        let
                            expected =
                                ( "1000 bytes", "90.00%", "fine" )

                            resourceType =
                                "net"

                            used =
                                100

                            available =
                                900

                            max =
                                1000
                        in
                            Expect.equal expected (getResource resourceType used available max)
                , test "net 1KB <= max < 1MB, 0%" <|
                    \() ->
                        let
                            expected =
                                ( "1.0000 KB", "0.00%", "hell" )

                            resourceType =
                                "net"

                            used =
                                1024

                            available =
                                0

                            max =
                                1024
                        in
                            Expect.equal expected (getResource resourceType used available max)
                , test "net 1MB <= max < 1GB, 0%" <|
                    \() ->
                        let
                            expected =
                                ( "1.0000 MB", "0.00%", "hell" )

                            resourceType =
                                "net"

                            used =
                                1024 * 1024

                            available =
                                0

                            max =
                                1024 * 1024
                        in
                            Expect.equal expected (getResource resourceType used available max)
                , test "net 1GB <= max < 1TB, 0%" <|
                    \() ->
                        let
                            expected =
                                ( "1.0000 GB", "0.00%", "hell" )

                            resourceType =
                                "net"

                            used =
                                1024 * 1024 * 1024

                            available =
                                0

                            max =
                                1024 * 1024 * 1024
                        in
                            Expect.equal expected (getResource resourceType used available max)
                , test "net max >= 1TB, 0%" <|
                    \() ->
                        let
                            expected =
                                ( "1.0000 TB", "0.00%", "hell" )

                            resourceType =
                                "net"

                            used =
                                1024 * 1024 * 1024 * 1024

                            available =
                                0

                            max =
                                1024 * 1024 * 1024 * 1024
                        in
                            Expect.equal expected (getResource resourceType used available max)
                , test "cpu,  max < 1 s, percentage = 0%" <|
                    \() ->
                        let
                            expected =
                                ( "430 ms", "0.00%", "hell" )

                            resourceType =
                                "cpu"

                            used =
                                430

                            available =
                                0

                            max =
                                430
                        in
                            Expect.equal expected (getResource resourceType used available max)
                , test "cpu, 1 s <= max < 1 min, percentage = 0%" <|
                    \() ->
                        let
                            expected =
                                ( "4.3000 s", "0.00%", "hell" )

                            resourceType =
                                "cpu"

                            used =
                                4300

                            available =
                                0

                            max =
                                4300
                        in
                            Expect.equal expected (getResource resourceType used available max)
                , test "cpu, 1 min <= max < 1 hour, percentage = 0%" <|
                    \() ->
                        let
                            expected =
                                ( "7.1667 min", "0.00%", "hell" )

                            resourceType =
                                "cpu"

                            used =
                                430000

                            available =
                                0

                            max =
                                430000
                        in
                            Expect.equal expected (getResource resourceType used available max)
                , test "cpu, 1 hour <= max < 1 day, percentage = 0%" <|
                    \() ->
                        let
                            expected =
                                ( "1.1944 hour", "0.00%", "hell" )

                            resourceType =
                                "cpu"

                            used =
                                4300000

                            available =
                                0

                            max =
                                4300000
                        in
                            Expect.equal expected (getResource resourceType used available max)
                , test "cpu, max >= 1 day, percentage = 0%" <|
                    \() ->
                        let
                            expected =
                                ( "4.9769 day", "0.00%", "hell" )

                            resourceType =
                                "cpu"

                            used =
                                430000000

                            available =
                                0

                            max =
                                430000000
                        in
                            Expect.equal expected (getResource resourceType used available max)
                , test "ram max < 1024, percentage = 0%" <|
                    \() ->
                        let
                            expected =
                                ( "1000 bytes", "0.00%", "hell" )

                            resourceType =
                                "ram"

                            used =
                                1000

                            available =
                                0

                            max =
                                1000
                        in
                            Expect.equal expected (getResource resourceType used available max)
                , test "ram max < 1024, 0% < percentage < 25% " <|
                    \() ->
                        let
                            expected =
                                ( "1000 bytes", "20.00%", "hell" )

                            resourceType =
                                "ram"

                            used =
                                800

                            available =
                                200

                            max =
                                1000
                        in
                            Expect.equal expected (getResource resourceType used available max)
                , test "ram max < 1024, 25% <= percentage < 50%" <|
                    \() ->
                        let
                            expected =
                                ( "1000 bytes", "40.00%", "bad" )

                            resourceType =
                                "ram"

                            used =
                                600

                            available =
                                400

                            max =
                                1000
                        in
                            Expect.equal expected (getResource resourceType used available max)
                , test "ram max < 1024, 50% <= percentage < 75%" <|
                    \() ->
                        let
                            expected =
                                ( "1000 bytes", "70.00%", "good" )

                            resourceType =
                                "ram"

                            used =
                                300

                            available =
                                700

                            max =
                                1000
                        in
                            Expect.equal expected (getResource resourceType used available max)
                , test "ram max < 1024, 75% <= percentage < 100%" <|
                    \() ->
                        let
                            expected =
                                ( "1000 bytes", "90.00%", "fine" )

                            resourceType =
                                "ram"

                            used =
                                100

                            available =
                                900

                            max =
                                1000
                        in
                            Expect.equal expected (getResource resourceType used available max)
                , test "ram 1KB <= max < 1MB, 0%" <|
                    \() ->
                        let
                            expected =
                                ( "1.0000 KB", "0.00%", "hell" )

                            resourceType =
                                "ram"

                            used =
                                1024

                            available =
                                0

                            max =
                                1024
                        in
                            Expect.equal expected (getResource resourceType used available max)
                , test "ram 1MB <= max < 1GB, 0%" <|
                    \() ->
                        let
                            expected =
                                ( "1.0000 MB", "0.00%", "hell" )

                            resourceType =
                                "ram"

                            used =
                                1024 * 1024

                            available =
                                0

                            max =
                                1024 * 1024
                        in
                            Expect.equal expected (getResource resourceType used available max)
                , test "ram 1GB <= max < 1TB, 0%" <|
                    \() ->
                        let
                            expected =
                                ( "1.0000 GB", "0.00%", "hell" )

                            resourceType =
                                "ram"

                            used =
                                1024 * 1024 * 1024

                            available =
                                0

                            max =
                                1024 * 1024 * 1024
                        in
                            Expect.equal expected (getResource resourceType used available max)
                , test "ram max >= 1TB, 0%" <|
                    \() ->
                        let
                            expected =
                                ( "1.0000 TB", "0.00%", "hell" )

                            resourceType =
                                "ram"

                            used =
                                1024 * 1024 * 1024 * 1024

                            available =
                                0

                            max =
                                1024 * 1024 * 1024 * 1024
                        in
                            Expect.equal expected (getResource resourceType used available max)
                ]
            ]
