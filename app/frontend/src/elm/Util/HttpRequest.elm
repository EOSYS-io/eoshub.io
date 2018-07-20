module Util.HttpRequest exposing (..)

import Http
import Json.Decode as JD exposing (Decoder)


apiUrl : String
apiUrl =
    "https://rpc.eosys.io"


getFullPath : String -> String
getFullPath path =
    apiUrl ++ path


post : String -> Http.Body -> Decoder a -> Http.Request a
post url body decoder =
    Http.request
        { method = "POST"
        , headers = []
        , url = url
        , body = body
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }
