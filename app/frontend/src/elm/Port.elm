port module Port exposing (..)

import Json.Encode as JE


-- A port for asking status of Wallet in JS.


port checkWalletStatus : () -> Cmd message



-- A port for receiving status of Wallet in Js.
-- Currently, status of Wallet is defined in three categories 'authenticated', 'loaded', 'notFound'


port receiveWalletStatus : ({ status : String, account : String, authority : String } -> message) -> Sub message


port authenticateAccount : () -> Cmd message


port invalidateAccount : () -> Cmd message


port pushAction : JE.Value -> Cmd message


port receiveScatterResponse : ({ code : Int, type_ : String, message : String } -> message) -> Sub message
