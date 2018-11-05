port module Port exposing
    ( KeyPair
    , authenticateAccount
    , checkLocale
    , checkWalletStatus
    , copy
    , generateKeys
    , invalidateAccount
    , loadChart
    , openWindow
    , pushAction
    , receiveKeys
    , receiveLocale
    , receivePushActionResponse
    , receiveWalletStatus
    )

import Json.Encode as JE
import Util.WalletDecoder exposing (PushActionResponse, WalletResponse)



-- A port for asking status of Wallet in JS.


port checkWalletStatus : () -> Cmd message



-- A port for receiving status of Wallet in Js.
-- Currently, status of Wallet is defined in three categories 'authenticated', 'loaded', 'notFound'


port receiveWalletStatus : (WalletResponse -> message) -> Sub message


port authenticateAccount : () -> Cmd message


port invalidateAccount : () -> Cmd message


port pushAction : JE.Value -> Cmd message


port receivePushActionResponse : (PushActionResponse -> message) -> Sub message



-- EOS Key pair


type alias KeyPair =
    { privateKey : String
    , publicKey : String
    }


port generateKeys : () -> Cmd message


port receiveKeys : (KeyPair -> message) -> Sub message



-- Clipboard


port copy : () -> Cmd message



-- Dynamic chart loading.


port loadChart : () -> Cmd message



-- Open window


port openWindow : JE.Value -> Cmd message


port checkLocale : () -> Cmd message


port receiveLocale : (String -> message) -> Sub message
