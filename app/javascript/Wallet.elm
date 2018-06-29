module Wallet exposing (..)


type WalletStatus
    = UNAUTHENTICATED
    | LOADED
    | NOTFOUND


decodeWalletStatus : String -> WalletStatus
decodeWalletStatus string =
    if (string == "WALLET_STATUS_UNAUTHENTICATED") then
        UNAUTHENTICATED
    else if (string == "WALLET_STATUS_LOADED") then
        LOADED
    else
        NOTFOUND
