module Wallet exposing (..)


type Status
    = Authenticated
    | Loaded
    | NotFound


type alias WalletStatus =
    { status : Status, account : String, authority : String }


decodeWalletStatus : { status : String, account : String, authority : String } -> WalletStatus
decodeWalletStatus { status, account, authority } =
    if (status == "WALLET_STATUS_AUTHENTICATED") then
        { status = Authenticated, account = account, authority = authority }
    else if (status == "WALLET_STATUS_LOADED") then
        { status = Loaded, account = "", authority = "" }
    else
        { status = NotFound, account = "", authority = "" }
