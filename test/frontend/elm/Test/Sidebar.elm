module Test.Sidebar exposing (tests)

import Expect
import Port
import Sidebar exposing (Message(..), WalletStatus(..), initModel, update)
import Test exposing (..)
import View.Notification


tests : Test
tests =
    describe "Wallet module"
        [ describe "update"
            [ describe "UpdateWalletStatus"
                [ test "authenticated" <|
                    \() ->
                        let
                            msg =
                                UpdateWalletStatus
                                    { status = "WALLET_STATUS_AUTHENTICATED"
                                    , account = "ACCOUNT"
                                    , authority = "AUTHORITY"
                                    }

                            expectedModel =
                                { initModel
                                    | wallet =
                                        { status = Authenticated
                                        , account = "ACCOUNT"
                                        , authority = "AUTHORITY"
                                        }
                                }
                        in
                            Expect.equal ( expectedModel, Cmd.none ) (update msg initModel)
                , test "loaded" <|
                    \() ->
                        let
                            msg =
                                UpdateWalletStatus
                                    { status = "WALLET_STATUS_LOADED"
                                    , account = "acc"
                                    , authority = "auth"
                                    }

                            expectedModel =
                                { initModel
                                    | wallet =
                                        { status = Loaded
                                        , account = ""
                                        , authority = ""
                                        }
                                }
                        in
                            Expect.equal ( expectedModel, Cmd.none ) (update msg initModel)
                , test "not found" <|
                    \() ->
                        let
                            msg =
                                UpdateWalletStatus
                                    { status = "WALLET_STATUS_NOT_FOUND"
                                    , account = "acc"
                                    , authority = "auth"
                                    }

                            expectedModel =
                                { initModel
                                    | wallet =
                                        { status = NotFound
                                        , account = ""
                                        , authority = ""
                                        }
                                }
                        in
                            Expect.equal ( expectedModel, Cmd.none ) (update msg initModel)
                ]
            , describe "Other Messages"
                [ test "CheckWalletStatus" <|
                    \() ->
                        Expect.equal
                            ( initModel, Port.checkWalletStatus () )
                            (update CheckWalletStatus initModel)
                , test "AuthenticateAccount" <|
                    \() ->
                        Expect.equal
                            ( initModel, Port.authenticateAccount () )
                            (update AuthenticateAccount initModel)
                , test "InvalidateAccount" <|
                    \() ->
                        Expect.equal
                            ( initModel, Port.invalidateAccount () )
                            (update InvalidateAccount initModel)
                , test "UpdateScatterResponse" <|
                    \() ->
                        let
                            expectedModel =
                                { initModel | notification = View.Notification.Ok }

                            scatterResponse =
                                { code = 200
                                , type_ = ""
                                , message = ""
                                }
                        in
                            Expect.equal
                                ( expectedModel, Cmd.none )
                                (update (UpdateScatterResponse scatterResponse) initModel)
                ]
            ]
        ]
