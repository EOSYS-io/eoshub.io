module Test.Sidebar exposing (tests)

import Expect
import Navigation
import Port
import Sidebar exposing (Message(..), State(..), initModel, update)
import Test exposing (..)
import Translation exposing (Language(Korean))
import Util.WalletDecoder exposing (WalletStatus(..))
import View.Notification


tests : Test
tests =
    describe "Wallet module"
        [ describe "update"
            [ describe "UpdateWalletStatus"
                [ test "authenticated should change both wallet and state" <|
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
                        Expect.equal
                            ( initModel, Port.invalidateAccount () )
                            (update InvalidateAccount initModel)
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
                            ( { initModel | configPanelOpen = True }, Cmd.none )
                            (update (OpenConfigPanel False) initModel)
                , test "AndThen" <|
                    \() ->
                        Expect.equal
                            ( { initModel | configPanelOpen = True, fold = True }
                            , Cmd.batch [ Cmd.none, Cmd.none ]
                            )
                            (update (AndThen ToggleSidebar (OpenConfigPanel False)) initModel)
                ]
            ]
        ]
