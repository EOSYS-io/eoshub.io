module Wallet exposing (..)


type WalletStatus
    = AUTHENTICATED
    | LOADED
    | NOTFOUND


decodeWalletStatus : String -> WalletStatus
decodeWalletStatus string =
    if (string == "WALLET_STATUS_AUTHENTICATED") then
        AUTHENTICATED
    else if (string == "WALLET_STATUS_LOADED") then
        LOADED
    else
        NOTFOUND
