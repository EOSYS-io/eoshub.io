module Test.Util.Constant exposing (..)

import Util.Constant exposing (..)
import Expect
import Test exposing (..)


tests : Test
tests =
    describe "Util.Constant module"
        [ describe "time"
            [ test "second" <|
                \() ->
                    Expect.equal 1000 second
            , test "minute" <|
                \() ->
                    Expect.equal 60000 minute
            , test "hour" <|
                \() ->
                    Expect.equal 3600000 hour
            , test "day" <|
                \() ->
                    Expect.equal 86400000 day
            ]
        , describe "digital prefix"
            [ test "kilo" <|
                \() ->
                    Expect.equal 1024 kilo
            , test "mega" <|
                \() ->
                    Expect.equal (1024 * 1024) mega
            , test "giga" <|
                \() ->
                    Expect.equal (1024 * 1024 * 1024) giga
            , test "tera" <|
                \() ->
                    Expect.equal (1024 * 1024 * 1024 * 1024) tera
            ]
        ]
