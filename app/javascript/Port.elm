port module Port exposing (..)

-- A port for asking status of Wallet in JS.


port checkWalletStatus : () -> Cmd msg



-- A port for receiving status of Wallet in Js.
-- Currently, status of Wallet is defined in three categories 'authenticated', 'loaded', 'notFound'


port receiveWalletStatus : (String -> msg) -> Sub msg
