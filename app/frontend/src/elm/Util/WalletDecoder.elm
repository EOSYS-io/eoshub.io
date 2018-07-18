module Util.WalletDecoder
    exposing
        ( PushActionResponse
        , Wallet
        , WalletStatus(..)
        , WalletResponse
        , decodePushActionResponse
        , decodeWalletResponse
        )

import Dict exposing (Dict, fromList)
import Translation exposing (I18n(TransferSucceeded, TransferFailed, UnknownError))
import View.Notification


-- This type should be expanded as Wallet Response.


type alias PushActionResponse =
    { code : Int
    , type_ : String
    , message : String
    , action : String
    }


type WalletStatus
    = Authenticated
    | Loaded
    | NotFound


type alias WalletResponse =
    { status : String
    , account : String
    , authority : String
    }


type alias Wallet =
    { status : WalletStatus
    , account : String
    , authority : String
    }


actionSuccessMessages : Dict String (String -> I18n)
actionSuccessMessages =
    fromList [ ( "transfer", TransferSucceeded ) ]


actionFailMessages : Dict String (String -> I18n)
actionFailMessages =
    fromList [ ( "transfer", TransferFailed ) ]


decodePushActionResponse : PushActionResponse -> View.Notification.Content
decodePushActionResponse { code, type_, message, action } =
    case code of
        200 ->
            let
                value =
                    Dict.get action actionSuccessMessages
            in
                case value of
                    Just messageFunction ->
                        View.Notification.Ok messageFunction

                    -- This case should not happen!
                    Nothing ->
                        View.Notification.Error
                            { message = UnknownError
                            , detail = ""
                            }

        _ ->
            let
                value =
                    Dict.get action actionFailMessages
            in
                case value of
                    Just messageFunction ->
                        View.Notification.Error
                            { message = messageFunction (toString code)
                            , detail = type_ ++ "\n" ++ message
                            }

                    Nothing ->
                        View.Notification.Error
                            { message = UnknownError
                            , detail = ""
                            }


walletStatuses : Dict String WalletStatus
walletStatuses =
    fromList
        [ ( "WALLET_STATUS_AUTHENTICATED", Authenticated )
        , ( "WALLET_STATUS_LOADED", Loaded )
        ]


decodeWalletResponse : WalletResponse -> Wallet
decodeWalletResponse { status, account, authority } =
    let
        value =
            Dict.get status walletStatuses
    in
        case value of
            Just walletStatus ->
                { status = walletStatus
                , account = account
                , authority = authority
                }

            Nothing ->
                { status = NotFound
                , account = ""
                , authority = ""
                }
