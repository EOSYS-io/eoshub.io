module Data.RailsResponse exposing (RailsResponse, handleRailsErrorResponse, railsResponseDecoder)

import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required)
import Translation exposing (I18n(DebugMessage, EmptyMessage))


type alias RailsResponse =
    { message : String }


railsResponseDecoder : Decoder RailsResponse
railsResponseDecoder =
    decode RailsResponse
        |> required "message" Decode.string


decodeBodyMessage : Http.Response String -> String
decodeBodyMessage response =
    case Decode.decodeString railsResponseDecoder response.body of
        Ok body ->
            body.message

        Err body ->
            body


handleRailsErrorResponse : Http.Error -> I18n -> ( I18n, I18n )
handleRailsErrorResponse error badPayloadMsg =
    case error of
        Http.BadStatus response ->
            ( DebugMessage (decodeBodyMessage response), EmptyMessage )

        Http.BadPayload debugMsg response ->
            ( badPayloadMsg, DebugMessage ("debugMsg: " ++ debugMsg ++ ", body: " ++ response.body) )

        _ ->
            ( badPayloadMsg, DebugMessage (toString error) )
