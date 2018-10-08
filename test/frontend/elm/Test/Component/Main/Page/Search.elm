module Test.Component.Main.Page.Search exposing (tests)

import Component.Main.Page.Search exposing (filterDelbandTableSelf, sumStakedToList)
import Data.Account exposing (..)
import Data.Table exposing (..)
import Expect
import Test exposing (..)


tests : Test
tests =
    let
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
            [ test "filterDelbandTableSelf" <|
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
                    Expect.equal expected (filterDelbandTableSelf defaultFilter defaultDelbandTable)
            , test "sumStakedToList" <|
                \() ->
                    Expect.equal "0.2004 EOS" (sumStakedToList defaultDelbandTable defaultFilter)
            ]
        ]
