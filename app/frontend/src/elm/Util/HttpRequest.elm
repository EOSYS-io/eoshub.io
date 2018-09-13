module Util.HttpRequest exposing (getFullPath, getTableRows, post)

import Data.Table exposing (Row, rowsDecoder)
import Http
import Json.Decode exposing (Decoder)
import Json.Encode as Encode
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


getTableRows : String -> String -> String -> Http.Request (List Row)
getTableRows scope code table =
    let
        requestBody =
            [ ( "scope", scope |> Encode.string )
            , ( "code", code |> Encode.string )
            , ( "table", table |> Encode.string )
            , ( "json", True |> Encode.bool )
            ]
                |> Encode.object
                |> Http.jsonBody
    in
    post ("/v1/chain/get_table_rows" |> getFullPath) requestBody rowsDecoder
