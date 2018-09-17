module Util.WalletDecoder exposing
    ( PushActionResponse
    , Wallet
    , WalletResponse
    , WalletStatus(..)
    , decodePushActionResponse
    , decodeWalletResponse
    )

import Dict exposing (Dict, fromList)
import Translation
    exposing
        ( I18n
            ( CheckDetail
            , CheckError
            , DebugMessage
            , DelegatebwFailed
            , DelegatebwSucceeded
            , EmptyMessage
            , TransferFailed
            , TransferSucceeded
            , UndelegatebwFailed
            , UndelegatebwSucceeded
            , UnknownError
            )
        )
import View.Notification as Notification



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
    fromList
        [ ( "transfer", TransferSucceeded )
        , ( "delegatebw", DelegatebwSucceeded )
        , ( "undelegatebw", UndelegatebwSucceeded )
        ]


actionFailMessages : Dict String (String -> I18n)
actionFailMessages =
    fromList
        [ ( "transfer", TransferFailed )
        , ( "delegatebw", DelegatebwFailed )
        , ( "undelegatebw", UndelegatebwFailed )
        ]


decodePushActionResponse : PushActionResponse -> String -> Notification.Content
decodePushActionResponse { code, type_, message, action } i18nParam =
    case code of
        200 ->
            let
                value =
                    Dict.get action actionSuccessMessages
            in
            case value of
                Just messageFunction ->
                    Notification.Ok
                        { message = i18nParam |> messageFunction
                        , detail = CheckDetail
                        }

                -- This case should not happen!
                Nothing ->
                    Notification.Error
                        { message = UnknownError
                        , detail = CheckError
                        }

        _ ->
            let
                value =
                    Dict.get action actionFailMessages
            in
            case value of
                Just messageFunction ->
                    Notification.Error
                        { message = messageFunction (toString code)
                        , detail = DebugMessage (type_ ++ "\n" ++ message)
                        }

                Nothing ->
                    Notification.Error
                        { message = UnknownError
                        , detail = CheckError
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
