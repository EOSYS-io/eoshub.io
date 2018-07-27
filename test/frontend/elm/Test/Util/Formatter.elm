module Test.Util.Formatter exposing (..)

import Util.Formatter exposing (..)
import Util.Constant exposing (..)
import Expect
import Test exposing (..)


tests : Test
tests =
    describe "Util.Formatter module"
        [ describe "larimerToEos"
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
        , describe "unitConverterRound4"
            [ test "1024 -> 1k" <|
                \() ->
                    Expect.equal "1.0000" (unitConverterRound4 1024 kilo)
            ]
        , describe "percentageConverter"
            [ test "1/100 * 100 = 1%" <|
                \() ->
                    Expect.equal 1.0 (percentageConverter 1 100)
            ]
        ]
