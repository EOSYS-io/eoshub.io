module Test.Component.Main.Page.Rammarket exposing (tests)

import Component.Main.Page.Rammarket exposing (calculateEosRamPrice, calculateEosRamYield)
import Data.Table exposing (initGlobalFields, initRammarketFields)
import Expect
import Test exposing (..)


tests : Test
tests =
    describe "Transfer page module"
        [ describe "validation"
            [ describe "CalculateEosRamPrice"
                [ test "default value." <|
                    \() ->
                        Expect.equal
                            "Loading..."
                            (calculateEosRamPrice initRammarketFields)
                , test "calculate ram price." <|
                    \() ->
                        Expect.equal "0.10358351 EOS/KB"
                            (calculateEosRamPrice
                                { initRammarketFields
                                    | base =
                                        { balance = "32404086104 RAM"
                                        , weight = "0.50000000000000000"
                                        }
                                    , quote =
                                        { balance = "3277860.4027 EOS"
                                        , weight = "0.50000000000000000"
                                        }
                                }
                            )
                ]
            , describe "CalculateEosRamYield"
                [ test "default value." <|
                    \() ->
                        Expect.equal
                            "Loading..."
                            (calculateEosRamYield initGlobalFields)
                , test "calculate ram yield." <|
                    \() ->
                        Expect.equal "43.29/73.47GB (58.92%)"
                            (calculateEosRamYield
                                { initGlobalFields
                                    | maxRamSize = "78887812096"
                                    , totalRamBytesReserved = "46483229140"
                                }
                            )
                ]
            ]
        ]
