port module Port exposing (..)

import Json.Encode as JE


-- A port for asking status of Wallet in JS.


port checkWalletStatus : () -> Cmd msg



-- A port for receiving status of Wallet in Js.
-- Currently, status of Wallet is defined in three categories 'authenticated', 'loaded', 'notFound'


port receiveWalletStatus : ({ status : String, account : String, authority : String } -> msg) -> Sub msg


port authenticateAccount : () -> Cmd msg


port invalidateAccount : () -> Cmd msg


port pushAction : JE.Value -> Cmd msg
