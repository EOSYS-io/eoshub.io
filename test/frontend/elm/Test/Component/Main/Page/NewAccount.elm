module Test.Component.Main.Page.NewAccount exposing (tests)

import Component.Main.Page.NewAccount
    exposing
        ( initModel
        , validateAccountName
        , validateKey
        )
import Expect
import Test exposing (..)
import Util.Validation
    exposing
        ( AccountStatus(..)
        , PublicKeyStatus(..)
        , VerificationRequestStatus(..)
        )


tests : Test
tests =
    describe "validate"
        [ describe "account"
            [ test "AccountToBeVerified" <|
                \() ->
                    Expect.equal
                        { initModel
                            | account = "eosyskoreabp"
                            , accountValidation = AccountToBeVerified
                            , isValid = False
                        }
                        (Tuple.first
                            (validateAccountName
                                { initModel
                                    | account = "eosyskoreabp"
                                }
                                NotSent
                            )
                        )
            , test "ValidAccount" <|
                \() ->
                    Expect.equal
                        { initModel
                            | account = "eosyskoreabp"
                            , accountValidation = ValidAccount
                            , isValid = False
                        }
                        (Tuple.first
                            (validateAccountName
                                { initModel
                                    | account = "eosyskoreabp"
                                }
                                Succeed
                            )
                        )
            , test "InexistentAccount" <|
                \() ->
                    Expect.equal
                        { initModel
                            | account = "eosyskoreabp"
                            , accountValidation = InexistentAccount
                            , isValid = False
                        }
                        (Tuple.first
                            (validateAccountName
                                { initModel
                                    | account = "eosyskoreabp"
                                }
                                Fail
                            )
                        )
            , test "InvalidAccount" <|
                \() ->
                    Expect.equal
                        { initModel
                            | account = "eosyskoreap"
                            , accountValidation = InvalidAccount
                            , isValid = False
                        }
                        (Tuple.first
                            (validateAccountName
                                { initModel
                                    | account = "eosyskoreap"
                                }
                                NotSent
                            )
                        )
            , test "EmptyAccount" <|
                \() ->
                    Expect.equal
                        { initModel
                            | account = ""
                            , accountValidation = EmptyAccount
                            , isValid = False
                        }
                        (Tuple.first
                            (validateAccountName
                                { initModel
                                    | account = ""
                                }
                                NotSent
                            )
                        )
            ]
        , describe "active key"
            [ test "valid" <|
                \() ->
                    Expect.equal
                        { initModel
                            | activeKey = "EOS7Wac71taGZKyuf6RmbY67Rc168xSmyD5cUR8xFR1qaGM1i2Ukd"
                            , activeKeyValidation = ValidPublicKey
                            , isValid = False
                        }
                        (validateKey
                            { initModel
                                | activeKey = "EOS7Wac71taGZKyuf6RmbY67Rc168xSmyD5cUR8xFR1qaGM1i2Ukd"
                            }
                        )
            , test "invalid" <|
                \() ->
                    Expect.equal
                        { initModel
                            | activeKey = "INVALID"
                            , activeKeyValidation = InvalidPublicKey
                            , isValid = False
                        }
                        (validateKey
                            { initModel
                                | activeKey = "INVALID"
                            }
                        )
            , test "empty" <|
                \() ->
                    Expect.equal
                        { initModel
                            | activeKey = ""
                            , activeKeyValidation = EmptyPublicKey
                            , isValid = False
                        }
                        (validateKey
                            { initModel
                                | activeKey = ""
                            }
                        )
            ]
        , describe "owner key"
            [ test "valid" <|
                \() ->
                    Expect.equal
                        { initModel
                            | ownerKey = "EOS7Wac71taGZKyuf6RmbY67Rc168xSmyD5cUR8xFR1qaGM1i2Ukd"
                            , ownerKeyValidation = ValidPublicKey
                            , isValid = False
                        }
                        (validateKey
                            { initModel
                                | ownerKey = "EOS7Wac71taGZKyuf6RmbY67Rc168xSmyD5cUR8xFR1qaGM1i2Ukd"
                            }
                        )
            , test "invalid" <|
                \() ->
                    Expect.equal
                        { initModel
                            | ownerKey = "INVALID"
                            , ownerKeyValidation = InvalidPublicKey
                            , isValid = False
                        }
                        (validateKey
                            { initModel
                                | ownerKey = "INVALID"
                            }
                        )
            , test "empty" <|
                \() ->
                    Expect.equal
                        { initModel
                            | ownerKey = ""
                            , ownerKeyValidation = EmptyPublicKey
                            , isValid = False
                        }
                        (validateKey
                            { initModel
                                | ownerKey = ""
                            }
                        )
            ]
        , let
            validModel =
                { initModel
                    | ownerKey = "EOS7Wac71taGZKyuf6RmbY67Rc168xSmyD5cUR8xFR1qaGM1i2Ukd"
                    , ownerKeyValidation = ValidPublicKey
                    , activeKey = "EOS7Wac71taGZKyuf6RmbY67Rc168xSmyD5cUR8xFR1qaGM1i2Ukd"
                    , activeKeyValidation = ValidPublicKey
                    , account = "eosyskoreabp"
                    , accountValidation = InexistentAccount
                    , isValid = True
                }

            testModel ownerKey activeKey account reqStatus =
                Tuple.first
                    (validateAccountName
                        (validateKey
                            { initModel
                                | ownerKey = ownerKey
                                , activeKey = activeKey
                                , account = account
                            }
                        )
                        reqStatus
                    )
          in
          describe "form validaton"
            [ test "valid form" <|
                \() ->
                    Expect.equal
                        validModel
                        (testModel
                            "EOS7Wac71taGZKyuf6RmbY67Rc168xSmyD5cUR8xFR1qaGM1i2Ukd"
                            "EOS7Wac71taGZKyuf6RmbY67Rc168xSmyD5cUR8xFR1qaGM1i2Ukd"
                            "eosyskoreabp"
                            Fail
                        )
            , test "account exist" <|
                \() ->
                    Expect.equal
                        { validModel
                            | accountValidation = ValidAccount
                            , isValid = False
                        }
                        (testModel
                            "EOS7Wac71taGZKyuf6RmbY67Rc168xSmyD5cUR8xFR1qaGM1i2Ukd"
                            "EOS7Wac71taGZKyuf6RmbY67Rc168xSmyD5cUR8xFR1qaGM1i2Ukd"
                            "eosyskoreabp"
                            Succeed
                        )
            , test "invalid account" <|
                \() ->
                    Expect.equal
                        { validModel
                            | account = "INVALID"
                            , accountValidation = InvalidAccount
                            , isValid = False
                        }
                        (testModel
                            "EOS7Wac71taGZKyuf6RmbY67Rc168xSmyD5cUR8xFR1qaGM1i2Ukd"
                            "EOS7Wac71taGZKyuf6RmbY67Rc168xSmyD5cUR8xFR1qaGM1i2Ukd"
                            "INVALID"
                            Fail
                        )
            , test "invalid active key" <|
                \() ->
                    Expect.equal
                        { validModel
                            | activeKey = "INVALID"
                            , activeKeyValidation = InvalidPublicKey
                            , isValid = False
                        }
                        (testModel
                            "EOS7Wac71taGZKyuf6RmbY67Rc168xSmyD5cUR8xFR1qaGM1i2Ukd"
                            "INVALID"
                            "eosyskoreabp"
                            Fail
                        )
            , test "invalid owner key" <|
                \() ->
                    Expect.equal
                        { validModel
                            | ownerKey = "INVALID"
                            , ownerKeyValidation = InvalidPublicKey
                            , isValid = False
                        }
                        (testModel
                            "INVALID"
                            "EOS7Wac71taGZKyuf6RmbY67Rc168xSmyD5cUR8xFR1qaGM1i2Ukd"
                            "eosyskoreabp"
                            Fail
                        )
            ]
        ]
