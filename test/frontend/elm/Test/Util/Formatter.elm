module Test.Util.Formatter exposing (tests)

import Expect
import Test exposing (..)
import Translation exposing (Language(..))
import Util.Constant exposing (..)
import Util.Formatter exposing (..)


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
            , describe "timeForƒmatter"
                [ test "English, AM, Ok" <|
                    \() ->
                        Expect.equal "2:16:21 AM, August 17, 2018" (timeFormatter English "2018-08-17T02:16:21.500")
                , test "English, PM, Ok" <|
                    \() ->
                        Expect.equal "5:16:21 PM, August 17, 2018" (timeFormatter English "2018-08-17T17:16:21.500")
                , test "Korean, AM, Ok" <|
                    \() ->
                        Expect.equal "2018년, 8월 17일, 2:16:21 AM" (timeFormatter Korean "2018-08-17T02:16:21.500")
                , test "Korean, PM, Ok" <|
                    \() ->
                        Expect.equal "2018년, 8월 17일, 5:16:21 PM" (timeFormatter Korean "2018-08-17T17:16:21.500")
                , test "invalid time, Err" <|
                    \() ->
                        Expect.equal "Failed to create a Date from string '2018-108-17T17:16:21.500': Invalid ISO 8601 format" (timeFormatter English "2018-108-17T17:16:21.500")
                , test "no time, Err" <|
                    \() ->
                        Expect.equal "Failed to create a Date from string '': Invalid ISO 8601 format" (timeFormatter English "")
                ]
            ]
        ]
