module Test.Util.Validation exposing (..)

import Expect
import Util.Validation exposing (..)
import Test exposing (..)


tests : Test
tests =
    describe "Validation module"
        [ describe "isAccount"
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
        ]
