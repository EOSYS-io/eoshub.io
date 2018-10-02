module Test.Util.Validation exposing (tests)

import Expect
import Test exposing (..)
import Util.Validation exposing (..)


balance : Float
balance =
    300.0


validateQuantityWithBalance : String -> QuantityStatus
validateQuantityWithBalance quantity =
    validateQuantity quantity balance


tests : Test
tests =
    describe "Validation module"
        [ describe "isAccount"
            [ test "a-z.1-5 True" <|
                \() ->
                    Expect.equal True (isAccount "abc.xyz12345")
            , test "a-z.1-5 False" <|
                \() ->
                    Expect.equal False (isAccount "ABC!@#$67890")
            , test "{1,12} True" <|
                \() ->
                    Expect.equal True (isAccount "eosio.ram")
            , test "{1,12} False" <|
                \() ->
                    Expect.equal False (isAccount "eosio.ram.eosio.system")
            ]
        , describe "isPublicKey"
            [ test "start with EOS True" <|
                \() ->
                    Expect.equal True (isPublicKey "EOS5uxjV3FYZvwqyAM2StkFEvUvf43F7gSrZcBpunuuTxiYkKqb6d")
            , test "start with EOS False" <|
                \() ->
                    Expect.equal False (isPublicKey "eos5uxjV3FYZvwqyAM2StkFEvUvf43F7gSrZcBpunuuTxiYkKqb6d")
            , test "length 53 False" <|
                \() ->
                    Expect.equal False (isAccount "EOS5uxjV3FYZvwqyAM2StkFEvUvf43F7")
            ]
        , describe "validateAccount"
            [ test "EmptyAccount" <|
                \() -> Expect.equal EmptyAccount (validateAccount "" NotSent)
            , test "AccountToBeVerified" <|
                \() -> Expect.equal AccountToBeVerified (validateAccount "validacc" NotSent)
            , test "ValidAccount" <|
                \() -> Expect.equal ValidAccount (validateAccount "validacc" Succeed)
            , test "InexistentAccount" <|
                \() -> Expect.equal InexistentAccount (validateAccount "validacc" Fail)
            , test "InvalidAccount" <|
                \() -> Expect.equal InvalidAccount (validateAccount "INVALIDACC" NotSent)
            ]
        , describe "validateQuantity"
            [ test "EmptyQuantity" <|
                \() ->
                    Expect.equal
                        EmptyQuantity
                        (validateQuantityWithBalance
                            ""
                        )
            , test "InvalidQuantity" <|
                \() ->
                    Expect.equal
                        InvalidQuantity
                        (validateQuantityWithBalance
                            "-1.0"
                        )
            , test "OverValidQuantity" <|
                \() ->
                    Expect.equal
                        OverValidQuantity
                        (validateQuantityWithBalance
                            "301.0"
                        )
            , test "ValidQuantity" <|
                \() ->
                    Expect.equal
                        ValidQuantity
                        (validateQuantityWithBalance
                            "299.9999"
                        )
            ]
        , describe "memo"
            [ test "EmptyMemo" <|
                \() ->
                    Expect.equal
                        ValidMemo
                        (validateMemo
                            ""
                        )
            , test "ValidMemo" <|
                \() ->
                    Expect.equal
                        ValidMemo
                        (validateMemo
                            "hi~"
                        )
            , test "InvalidMemo" <|
                \() ->
                    Expect.equal
                        MemoTooLong
                        (validateMemo "This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes.")
            ]
        ]
