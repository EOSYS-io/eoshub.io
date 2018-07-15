module Test.Sidebar exposing (tests)

import Expect
import Port
import Sidebar exposing (Message(..), State(..), initModel, update)
import Response exposing (WalletStatus(..))
import Test exposing (..)
import Translation exposing (Language(Korean))
import View.Notification


tests : Test
tests =
    describe "Wallet module"
        [ describe "update"
            [ describe "UpdateWalletStatus"
                [ test "authenticated should both wallet and state" <|
                    \() ->
                        let
                            message =
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
                                    , state = AccountInfo
                                }
                        in
                            Expect.equal ( expectedModel, Cmd.none ) (update message initModel)
                , test "loaded" <|
                    \() ->
                        let
                            message =
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
                            Expect.equal ( expectedModel, Cmd.none ) (update message initModel)
                , test "not found" <|
                    \() ->
                        let
                            message =
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
                            Expect.equal ( expectedModel, Cmd.none ) (update message initModel)
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
                , test "UpdateLanguage" <|
                    \() ->
                        Expect.equal
                            ( { initModel | language = Korean }, Cmd.none )
                            (update (UpdateLanguage Korean) initModel)
                , test "UpdateState" <|
                    \() ->
                        Expect.equal
                            ( { initModel | state = PairWallet }, Cmd.none )
                            (update (UpdateState PairWallet) initModel)
                ]
            ]
        ]
