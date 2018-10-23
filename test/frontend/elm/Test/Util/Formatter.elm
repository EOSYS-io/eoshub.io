module Test.Util.Formatter exposing (tests)

import Expect
import Test exposing (..)
import Util.Constant exposing (..)
import Util.Formatter exposing (..)
import Util.Token exposing (Token)


tests : Test
tests =
    describe "Util.Formatter module"
        [ describe "larimerToEos"
            [ test "10000 larimer == 1.0 EOS" <|
                \() ->
                    Expect.equal 1.0 (larimerToEos 10000)
            ]
        , describe "floatToAsset"
            [ test "0.1 -> \"0.1000 EOS\"" <|
                \() ->
                    Expect.equal "0.1000 EOS" (floatToAsset 0.1)
            ]
        , describe "removeSymbolIfExists"
            [ test "\"0.1000 EOS\" -> \"0.1000\"" <|
                \() ->
                    Expect.equal "0.1000" (removeSymbolIfExists "0.1000 EOS")
            ]
        , describe "assetToFloat"
            [ test "\"0.1 EOS\" -> 0.1" <|
                \() ->
                    Expect.equal 0.1 (assetToFloat "0.1 EOS")
            ]
        , describe "assetAdd"
            [ test "\"0.5000 EOS\" + \"0.5000 EOS\"" <|
                \() ->
                    Expect.equal "1.0000 EOS" (assetAdd "0.5000 EOS" "0.5000 EOS")
            ]
        , describe "assetSubtract"
            [ test "\"1.0000 EOS\" - \"0.5000 EOS\"" <|
                \() ->
                    Expect.equal "0.5000 EOS" (assetSubtract "1.0000 EOS" "0.5000 EOS")
            ]
        , describe "unitConverterRound2"
            [ test "1024 -> 1k" <|
                \() ->
                    Expect.equal "1.00" (unitConverterRound2 1024 kilo)
            ]
        , describe "percentageConverter"
            [ test "1/100 * 100 = 1%" <|
                \() ->
                    Expect.equal 1.0 (percentageConverter 1 100)
            ]
        , describe "timeFormatter"
            [ test "AM, Ok" <|
                \() ->
                    Expect.equal "11:16:21 2018/08/17" (timeFormatter "2018-08-17T02:16:21.500")
            , test "PM, Ok" <|
                \() ->
                    Expect.equal "02:16:21 2018/08/18" (timeFormatter "2018-08-17T17:16:21.500")
            , test "invalid time, Err" <|
                \() ->
                    Expect.equal "Failed to create a Date from string '2018-108-17T17:16:21.500+00:00': Invalid ISO 8601 format" (timeFormatter "2018-108-17T17:16:21.500")
            , test "no time, Err" <|
                \() ->
                    Expect.equal "Failed to create a Date from string '+00:00': Invalid ISO 8601 format" (timeFormatter "")
            ]
        , describe "deleteFromBack"
            [ test "remove 4 characters." <|
                \() ->
                    Expect.equal "10.0000" (deleteFromBack 4 "10.0000 EOS")
            , test "remove characters more than string size" <|
                \() -> Expect.equal "" (deleteFromBack 4 "abc")
            ]
        , describe "numberWithinDigitLimit"
            (let
                digitLimit =
                    4
             in
             [ test "integer" <|
                \() -> Expect.equal True (numberWithinDigitLimit digitLimit "4")
             , test "digits not exceeding the limit" <|
                \() -> Expect.equal True (numberWithinDigitLimit digitLimit "400.0123")
             , test "digits exceeding the limit" <|
                \() -> Expect.equal False (numberWithinDigitLimit digitLimit "400.01243")
             ]
            )
        , describe "getDefaultAsset"
            [ test "BTC" <|
                \() ->
                    Expect.equal "0.00000000 BTC"
                        (getDefaultAsset
                            (Token "Bitcoin" "BTC" "" 8)
                        )
            ]
        , describe "getSymbolFromAsset"
            [ test "BTC" <|
                \() -> Expect.equal "BTC" ("1.0000 BTC" |> getSymbolFromAsset |> Maybe.withDefault "")
            , test "No symbol" <|
                \() -> Expect.equal "" ("1.0000" |> getSymbolFromAsset |> Maybe.withDefault "")
            ]
        ]
