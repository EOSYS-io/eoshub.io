module Test.Component.Main.Page.Search exposing (tests)

import Component.Main.Page.Search
    exposing
        ( actionHidden
        , filterDelbandWithAccountName
        , initModel
        , sumStakedToList
        )
import Data.Table exposing (..)
import Expect
import Test exposing (..)


tests : Test
tests =
    let
        defaultAccount =
            initModel "eosyscommuni"

        defaultDelbandTable =
            [ Delband
                { from = "eosyscommuni"
                , receiver = "eosyscommuni"
                , netWeight = "0.7515 EOS"
                , cpuWeight = "0.7520 EOS"
                }
            , Delband
                { from = "eosyscommuni"
                , receiver = "lievinkeosys"
                , netWeight = "0.1000 EOS"
                , cpuWeight = "0.1000 EOS"
                }
            , Delband
                { from = "eosyscommuni"
                , receiver = "podopodopodo"
                , netWeight = "0.0001 EOS"
                , cpuWeight = "0.0001 EOS"
                }
            , Delband
                { from = "eosyscommuni"
                , receiver = "ramfuturesio"
                , netWeight = "0.0001 EOS"
                , cpuWeight = "0.0001 EOS"
                }
            ]

        defaultFilter =
            "eosyscommuni"
    in
    describe "Page.Search module"
        [ describe "utility functions"
            [ test "filterDelbandWithAccountName" <|
                \() ->
                    let
                        expected =
                            [ Delband
                                { from = "eosyscommuni"
                                , receiver = "lievinkeosys"
                                , netWeight = "0.1000 EOS"
                                , cpuWeight = "0.1000 EOS"
                                }
                            , Delband
                                { from = "eosyscommuni"
                                , receiver = "podopodopodo"
                                , netWeight = "0.0001 EOS"
                                , cpuWeight = "0.0001 EOS"
                                }
                            , Delband
                                { from = "eosyscommuni"
                                , receiver = "ramfuturesio"
                                , netWeight = "0.0001 EOS"
                                , cpuWeight = "0.0001 EOS"
                                }
                            ]
                    in
                    Expect.equal expected (filterDelbandWithAccountName defaultFilter defaultDelbandTable)
            , test "sumStakedToList" <|
                \() ->
                    Expect.equal "0.2004 EOS" (sumStakedToList defaultDelbandTable defaultFilter)
            , describe "actionHidden"
                [ test "transfer, hidden False" <|
                    \() ->
                        Expect.equal False (actionHidden "transfer" defaultAccount.actionCategory "transfer")
                , test "transfer, hidden True" <|
                    \() ->
                        Expect.equal True (actionHidden "transfer" defaultAccount.actionCategory "not transfer")
                , test "claimrewards, hidden False" <|
                    \() ->
                        Expect.equal False (actionHidden "claimrewards" defaultAccount.actionCategory "claimrewards")
                , test "claimrewards, hidden True" <|
                    \() ->
                        Expect.equal True (actionHidden "claimrewards" defaultAccount.actionCategory "not claimrewards")
                , test "ram, buyram, hidden False" <|
                    \() ->
                        Expect.equal False (actionHidden "ram" defaultAccount.actionCategory "buyram")
                , test "ram, buyrambytes hidden False" <|
                    \() ->
                        Expect.equal False (actionHidden "ram" defaultAccount.actionCategory "buyrambytes")
                , test "ram, sellram hidden False" <|
                    \() ->
                        Expect.equal False (actionHidden "ram" defaultAccount.actionCategory "sellram")
                , test "ram, not ram, hidden True" <|
                    \() ->
                        Expect.equal True (actionHidden "ram" defaultAccount.actionCategory "not ram")
                , test "resource, delegatebw, hidden False" <|
                    \() ->
                        Expect.equal False (actionHidden "resource" defaultAccount.actionCategory "delegatebw")
                , test "resource, undelegatebw hidden False" <|
                    \() ->
                        Expect.equal False (actionHidden "resource" defaultAccount.actionCategory "undelegatebw")
                , test "resource, not resource, hidden True" <|
                    \() ->
                        Expect.equal True (actionHidden "resource" defaultAccount.actionCategory "not resource")
                , test "regproxy, hidden False" <|
                    \() ->
                        Expect.equal False (actionHidden "regproxy" defaultAccount.actionCategory "regproxy")
                , test "regproxy, hidden True" <|
                    \() ->
                        Expect.equal True (actionHidden "regproxy" defaultAccount.actionCategory "not regproxy")
                , test "voteproducer, hidden False" <|
                    \() ->
                        Expect.equal False (actionHidden "voteproducer" defaultAccount.actionCategory "voteproducer")
                , test "voteproducer, hidden True" <|
                    \() ->
                        Expect.equal True (actionHidden "voteproducer" defaultAccount.actionCategory "not voteproducer")
                , test "newaccount, hidden False" <|
                    \() ->
                        Expect.equal False (actionHidden "newaccount" defaultAccount.actionCategory "newaccount")
                , test "newaccount, hidden True" <|
                    \() ->
                        Expect.equal True (actionHidden "newaccount" defaultAccount.actionCategory "not newaccount")
                ]
            ]
        ]
