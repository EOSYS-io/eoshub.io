module Wallet exposing (..)


type Status
    = AUTHENTICATED
    | LOADED
    | NOTFOUND


type alias WalletStatus =
    { status : Status, account : String, authority : String }


decodeWalletStatus : { status : String, account : String, authority : String } -> WalletStatus
decodeWalletStatus { status, account, authority } =
    if (status == "WALLET_STATUS_AUTHENTICATED") then
        { status = AUTHENTICATED, account = account, authority = authority }
    else if (status == "WALLET_STATUS_LOADED") then
        { status = LOADED, account = "", authority = "" }
    else
        { status = NOTFOUND, account = "", authority = "" }
