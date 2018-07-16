module Header exposing (..)

import Html exposing (Html, Attribute, div, input, button, text)
import Html.Attributes exposing (placeholder)
import Html.Events exposing (on, onInput, onClick, keyCode)
import Http
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE


-- MODEL


type alias Model =
    { searchInput : String
    , eosPrice : Int
    , ramPrice : Int
    , keyAccounts : List String
    , account : Account
    , errMessage : String
    }



-- TODO(boseok): add required fields


type alias Account =
    { account_name : String
    , core_liquid_balance : Maybe String
    , total_resources : Resource
    }


type alias Resource =
    { net_weight : String
    , cpu_weight : String
    , ram_bytes : Int
    }


initModel : Model
initModel =
    { searchInput = ""
    , eosPrice = 0
    , ramPrice = 0
    , keyAccounts = []
    , account =
        { account_name = ""
        , core_liquid_balance = Just "0 EOS"
        , total_resources =
            { net_weight = "0 EOS"
            , cpu_weight = "0 EOS"
            , ram_bytes = 0
            }
        }
    , errMessage = ""
    }



-- TODO(boseok): Should be changed to config valiable


apiUrl : String
apiUrl =
    "https://rpc.eosys.io"



-- UPDATE


type Message
    = InputSearch String
    | GetSearchResult String
    | OnFetchAccount (Result Http.Error Account)
    | OnFetchKeyAccounts (Result Http.Error (List String))


type Query
    = AccountQuery
    | PublicKeyQuery


type alias AccountQuery =
    String


type alias PublicKeyQuery =
    String


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        InputSearch value ->
            ( { model | searchInput = value }, Cmd.none )

        GetSearchResult query ->
            let
                parsedQuery =
                    (parseQuery query)

                newCmd =
                    case parsedQuery of
                        Ok AccountQuery ->
                            let
                                body =
                                    JE.object
                                        [ ( "account_name", JE.string query ) ]
                                        |> Http.jsonBody
                            in
                                post (apiUrl ++ "/v1/chain/get_account") body accountDecoder |> (Http.send OnFetchAccount)

                        Ok PublicKeyQuery ->
                            let
                                body =
                                    JE.object
                                        [ ( "public_key", JE.string query ) ]
                                        |> Http.jsonBody
                            in
                                post (apiUrl ++ "/v1/history/get_key_accounts") body keyAccountsDecoder |> (Http.send OnFetchKeyAccounts)

                        Err _ ->
                            Cmd.none
            in
                ( model, newCmd )

        OnFetchAccount (Ok data) ->
            ( { model | account = data, errMessage = "success" }, Cmd.none )

        OnFetchAccount (Err error) ->
            ( { model | errMessage = "invalid length" }, Cmd.none )

        OnFetchKeyAccounts (Ok data) ->
            ( { model | keyAccounts = data, errMessage = "success" }, Cmd.none )

        OnFetchKeyAccounts (Err error) ->
            ( { model | errMessage = "invalid length" }, Cmd.none )


parseQuery : String -> Result String Query
parseQuery query =
    let
        -- EOS account's length is less than 12 letters
        -- EOS public key's length is 53 letters
        queryLength =
            String.length query
    in
        if queryLength <= 12 then
            Ok AccountQuery
        else if queryLength == 53 then
            Ok PublicKeyQuery
        else
            Err "invalid input"


accountDecoder : JD.Decoder Account
accountDecoder =
    JD.map3 Account
        (JD.field "account_name" JD.string)
        (JD.maybe <| JD.field "core_liquid_balance" JD.string)
        (JD.field "total_resources"
            (JD.map3 Resource
                (JD.field "net_weight" JD.string)
                (JD.field "cpu_weight" JD.string)
                (JD.field "ram_bytes" JD.int)
            )
        )


keyAccountsDecoder : JD.Decoder (List String)
keyAccountsDecoder =
    (JD.field "account_names" (JD.list JD.string))


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



-- VIEW


view : Model -> Html Message
view model =
    div []
        [ input [ placeholder "계정명, 퍼블릭키 검색하기", onInput InputSearch ] []
        , button [ onClick (GetSearchResult (model.searchInput)) ] [ text "검색하기" ]
        ]
