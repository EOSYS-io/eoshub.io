module Util.RailsErrorResponse exposing (decodeRailsErrorResponse)

import Data.Json exposing (railsResponseDecoder)
import Http
import Json.Decode as Decode
import Translation exposing (I18n(DebugMessage, EmptyMessage))


decodeBodyMessage : Http.Response String -> String
decodeBodyMessage response =
    case Decode.decodeString railsResponseDecoder response.body of
        Ok body ->
            body.message

        Err body ->
            body


decodeRailsErrorResponse : Http.Error -> I18n -> ( I18n, I18n )
decodeRailsErrorResponse error badPayloadMsg =
    case error of
        Http.BadStatus response ->
            ( DebugMessage (decodeBodyMessage response), EmptyMessage )

        Http.BadPayload debugMsg response ->
            ( badPayloadMsg, DebugMessage ("debugMsg: " ++ debugMsg ++ ", body: " ++ response.body) )

        _ ->
            ( badPayloadMsg, DebugMessage (toString error) )
