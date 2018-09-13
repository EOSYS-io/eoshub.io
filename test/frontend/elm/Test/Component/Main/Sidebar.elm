module Test.Component.Main.Sidebar exposing (tests)

import Component.Main.Sidebar exposing (Message(..), State(..), initModel, update)
import Expect
import Navigation
import Port
import Test exposing (..)
import Util.WalletDecoder exposing (WalletStatus(..))


tests : Test
tests =
    describe "Wallet module"
        [ describe "update"
            [ describe "UpdateWalletStatus"
                [ test "authenticated should change wallet, state and account" <|
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

                            {- TODO(heejae): Find a way to properly compare Http request commands.
                               For now, this test handles only expected model
                            -}
                        in
                        Expect.equal expectedModel (Tuple.first (update message initModel))
                , test "loaded should change state to SignIn" <|
                    \() ->
                        let
                            message =
                                UpdateWalletStatus
                                    { status = "WALLET_STATUS_LOADED"
                                    , account = ""
                                    , authority = ""
                                    }

                            expectedModel =
                                { initModel
                                    | wallet =
                                        { status = Loaded
                                        , account = ""
                                        , authority = ""
                                        }
                                    , state = SignIn
                                }
                        in
                        Expect.equal ( expectedModel, Cmd.none ) (update message initModel)
                , test "notfound should change state to SignIn" <|
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
                                    , state = SignIn
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
                        let
                            cmds =
                                Cmd.batch
                                    [ Port.invalidateAccount ()
                                    , Navigation.reload
                                    ]
                        in
                        Expect.equal
                            ( initModel, cmds )
                            (update InvalidateAccount initModel)
                , test "UpdateState" <|
                    \() ->
                        Expect.equal
                            ( { initModel | state = PairWallet }, Cmd.none )
                            (update (UpdateState PairWallet) initModel)
                , test "ToggleSidebar" <|
                    \() ->
                        Expect.equal
                            ( { initModel | fold = True }, Cmd.none )
                            (update ToggleSidebar initModel)
                , test "ChangeUrl" <|
                    \() ->
                        let
                            url =
                                "transfer"
                        in
                        Expect.equal
                            ( initModel, Navigation.newUrl url )
                            (update (ChangeUrl url) initModel)
                , test "SetConfigPanel" <|
                    \() ->
                        Expect.equal
                            ( { initModel | configPanelOpen = False }, Cmd.none )
                            (update (OpenConfigPanel False) initModel)
                , test "AndThen" <|
                    \() ->
                        Expect.equal
                            ( { initModel | configPanelOpen = False, fold = True }
                            , Cmd.batch [ Cmd.none, Cmd.none ]
                            )
                            (update (AndThen ToggleSidebar (OpenConfigPanel False)) initModel)
                ]
            ]
        ]
