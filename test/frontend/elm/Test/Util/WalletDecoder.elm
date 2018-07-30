module Test.Util.WalletDecoder exposing (tests)

import Expect
import Test exposing (..)
import Translation exposing (I18n(TransferSucceeded, TransferFailed, UnknownError, CheckDetail, CheckError, DebugMessage))
import Util.WalletDecoder exposing (..)
import View.Notification


response : PushActionResponse
response =
    { code = 200
    , type_ = ""
    , message = ""
    , action = "transfer"
    }


tests : Test
tests =
    let
        transfer =
            { from = "from"
            , to = "to"
            , quantity = "300"
            , memo = "memo"
            }
    in
        describe "Util.WalletDecoder module"
            [ describe "decodePushActionResponse"
                [ describe "transfer"
                    [ test "200" <|
                        \() ->
                            Expect.equal
                                (View.Notification.Ok { message = TransferSucceeded transfer.to, detail = CheckDetail })
                                (decodePushActionResponse response transfer.to)
                    , test "500 on unknownAction" <|
                        \() ->
                            Expect.equal
                                (View.Notification.Error { message = UnknownError, detail = CheckError })
                                (decodePushActionResponse { response | action = "unknown" } transfer.to)
                    , test "402" <|
                        \() ->
                            Expect.equal
                                (View.Notification.Error
                                    { message = TransferFailed "402"
                                    , detail = DebugMessage "account_missing\nMissing required accounts, repull the identity"
                                    }
                                )
                                (decodePushActionResponse
                                    { response
                                        | code = 402
                                        , type_ = "account_missing"
                                        , message = "Missing required accounts, repull the identity"
                                    }
                                    transfer.to
                                )
                    ]
                ]
            , describe "decodeWalletResponse"
                [ test "authenticated" <|
                    \() ->
                        Expect.equal
                            { status = Authenticated
                            , account = "ACCOUNT"
                            , authority = "AUTHORITY"
                            }
                            (decodeWalletResponse
                                { status = "WALLET_STATUS_AUTHENTICATED"
                                , account = "ACCOUNT"
                                , authority = "AUTHORITY"
                                }
                            )
                , test "loaded" <|
                    \() ->
                        Expect.equal
                            { status = Loaded
                            , account = ""
                            , authority = ""
                            }
                            (decodeWalletResponse
                                { status = "WALLET_STATUS_LOADED"
                                , account = ""
                                , authority = ""
                                }
                            )
                , test "notFound" <|
                    \() ->
                        Expect.equal
                            { status = NotFound
                            , account = ""
                            , authority = ""
                            }
                            (decodeWalletResponse
                                { status = "WALLET_STATUS_NOT_FOUND"
                                , account = ""
                                , authority = ""
                                }
                            )
                ]
            ]
