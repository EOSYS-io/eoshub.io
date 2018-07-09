module Test.Wallet exposing (..)

import Test exposing (..)
import Expect
import Wallet exposing (Status(..), decodeWalletStatus)


suite : Test
suite =
    describe "Wallet module"
        [ describe "decodeWalletStatus"
            [ test "returns Authenticated wallet status with account and authority" <|
                \_ ->
                    let
                        msg =
                            { status = "WALLET_STATUS_AUTHENTICATED"
                            , account = "ACCOUNT"
                            , authority = "AUTHORITY"
                            }

                        authenticatedWalletStatus =
                            { status = Authenticated
                            , account = "ACCOUNT"
                            , authority = "AUTHORITY"
                            }
                    in
                        Expect.equal (decodeWalletStatus msg) authenticatedWalletStatus
            , test "returns Loaded wallet status with empty account and authority" <|
                \_ ->
                    let
                        msg =
                            { status = "WALLET_STATUS_LOADED"
                            , account = ""
                            , authority = ""
                            }

                        loadedWalletStatus =
                            { status = Loaded
                            , account = ""
                            , authority = ""
                            }
                    in
                        Expect.equal (decodeWalletStatus msg) loadedWalletStatus
            , test "returns NotFound wallet status with empty account and authority" <|
                \_ ->
                    let
                        msg =
                            { status = "WALLET_STATUS_NOT_FOUND"
                            , account = ""
                            , authority = ""
                            }

                        notFoundWalletStatus =
                            { status = NotFound
                            , account = ""
                            , authority = ""
                            }
                    in
                        Expect.equal (decodeWalletStatus msg) notFoundWalletStatus
            ]
        ]
