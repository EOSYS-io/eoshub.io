module Response
    exposing
        ( ScatterResponse
        , Wallet
        , WalletStatus(..)
        , WalletResponse
        , decodeScatterResponse
        , decodeWalletResponse
        )

import View.Notification


-- This type should be expanded as Wallet Response.


type alias ScatterResponse =
    { code : Int
    , type_ : String
    , message : String
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


decodeScatterResponse : ScatterResponse -> View.Notification.Message
decodeScatterResponse { code, type_, message } =
    if code == 200 then
        View.Notification.Ok
    else
        View.Notification.Error { code = code, message = type_ ++ "\n" ++ message }


decodeWalletResponse : WalletResponse -> Wallet
decodeWalletResponse { status, account, authority } =
    if status == "WALLET_STATUS_AUTHENTICATED" then
        { status = Authenticated, account = account, authority = authority }
    else if status == "WALLET_STATUS_LOADED" then
        { status = Loaded, account = "", authority = "" }
    else
        { status = NotFound, account = "", authority = "" }
