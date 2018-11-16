module Test.Component.Main.Page.ChangeKey exposing (tests)

import Component.Main.Page.ChangeKey
    exposing
        ( initModel
        , validate
        )
import Expect
import Test exposing (..)
import Util.Validation exposing (PublicKeyStatus(..))


tests : Test
tests =
    describe "validate"
        [ test "empty, empty" <|
            \() -> Expect.equal (validate initModel) initModel
        , test "empty, invalid" <|
            \() ->
                Expect.equal
                    { initModel
                        | ownerKey = "INVALID"
                        , ownerKeyValidation = InvalidPublicKey
                    }
                    (validate
                        { initModel
                            | ownerKey = "INVALID"
                        }
                    )
        , test "empty, valid" <|
            \() ->
                Expect.equal
                    { initModel
                        | ownerKey = "EOS8bJciFsT2VbLYuba8YdL6K2WjA9j5383eXEZc5GDvhcdveGs41"
                        , ownerKeyValidation = ValidPublicKey
                        , isValid = True
                    }
                    (validate
                        { initModel
                            | ownerKey = "EOS8bJciFsT2VbLYuba8YdL6K2WjA9j5383eXEZc5GDvhcdveGs41"
                        }
                    )
        , test "invalid, empty" <|
            \() ->
                Expect.equal
                    { initModel
                        | activeKey = "INVALID"
                        , activeKeyValidation = InvalidPublicKey
                    }
                    (validate
                        { initModel
                            | activeKey = "INVALID"
                        }
                    )
        , test "invalid, invalid" <|
            \() ->
                Expect.equal
                    { initModel
                        | activeKey = "INVALID"
                        , ownerKey = "INVALID"
                        , activeKeyValidation = InvalidPublicKey
                        , ownerKeyValidation = InvalidPublicKey
                    }
                    (validate
                        { initModel
                            | activeKey = "INVALID"
                            , ownerKey = "INVALID"
                        }
                    )
        , test "invalid, valid" <|
            \() ->
                Expect.equal
                    { initModel
                        | activeKey = "INVALID"
                        , ownerKey = "EOS8bJciFsT2VbLYuba8YdL6K2WjA9j5383eXEZc5GDvhcdveGs41"
                        , activeKeyValidation = InvalidPublicKey
                        , ownerKeyValidation = ValidPublicKey
                    }
                    (validate
                        { initModel
                            | activeKey = "INVALID"
                            , ownerKey = "EOS8bJciFsT2VbLYuba8YdL6K2WjA9j5383eXEZc5GDvhcdveGs41"
                        }
                    )
        , test "valid, empty" <|
            \() ->
                Expect.equal
                    { initModel
                        | activeKey = "EOS8bJciFsT2VbLYuba8YdL6K2WjA9j5383eXEZc5GDvhcdveGs41"
                        , activeKeyValidation = ValidPublicKey
                        , isValid = True
                    }
                    (validate
                        { initModel
                            | activeKey = "EOS8bJciFsT2VbLYuba8YdL6K2WjA9j5383eXEZc5GDvhcdveGs41"
                        }
                    )
        , test "valid, invalid" <|
            \() ->
                Expect.equal
                    { initModel
                        | activeKey = "EOS8bJciFsT2VbLYuba8YdL6K2WjA9j5383eXEZc5GDvhcdveGs41"
                        , activeKeyValidation = ValidPublicKey
                        , ownerKey = "INVALID"
                        , ownerKeyValidation = InvalidPublicKey
                    }
                    (validate
                        { initModel
                            | activeKey = "EOS8bJciFsT2VbLYuba8YdL6K2WjA9j5383eXEZc5GDvhcdveGs41"
                            , ownerKey = "INVALID"
                        }
                    )
        , test "valid, valid" <|
            \() ->
                Expect.equal
                    { initModel
                        | activeKey = "EOS8bJciFsT2VbLYuba8YdL6K2WjA9j5383eXEZc5GDvhcdveGs41"
                        , activeKeyValidation = ValidPublicKey
                        , ownerKey = "EOS8bJciFsT2VbLYuba8YdL6K2WjA9j5383eXEZc5GDvhcdveGs41"
                        , ownerKeyValidation = ValidPublicKey
                        , isValid = True
                    }
                    (validate
                        { initModel
                            | activeKey = "EOS8bJciFsT2VbLYuba8YdL6K2WjA9j5383eXEZc5GDvhcdveGs41"
                            , ownerKey = "EOS8bJciFsT2VbLYuba8YdL6K2WjA9j5383eXEZc5GDvhcdveGs41"
                        }
                    )
        ]
