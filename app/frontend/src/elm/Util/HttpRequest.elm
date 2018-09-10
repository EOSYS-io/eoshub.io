module Util.HttpRequest exposing (getFullPath, post)

import Http
import Json.Decode as JD exposing (Decoder)
import Util.Urls exposing (mainnetRpcUrl)


getFullPath : String -> String
getFullPath path =
    mainnetRpcUrl ++ path


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
