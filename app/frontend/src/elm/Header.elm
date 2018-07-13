module Header exposing (..)

import Html exposing (Html, div, input, button, text)
import Html.Attributes exposing (placeholder)
import Html.Events exposing (onInput, onClick)
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
    , core_liquid_balance : String
    }


initModel : Model
initModel =
    { searchInput = ""
    , eosPrice = 0
    , ramPrice = 0
    , keyAccounts = []
    , account =
        { account_name = ""
        , core_liquid_balance = ""
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
    | OnFecthKeyAccounts (Result Http.Error (List String))


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
                                post (apiUrl ++ "/v1/history/get_key_accounts") body keyAccountsDecoder |> (Http.send OnFecthKeyAccounts)

                        Err _ ->
                            Cmd.none
            in
                ( model, newCmd )

        OnFetchAccount (Ok data) ->
            ( { model | account = data }, Cmd.none )

        OnFetchAccount (Err error) ->
            ( { model | errMessage = "invalid length" }, Cmd.none )

        OnFecthKeyAccounts (Ok data) ->
            ( { model | keyAccounts = data }, Cmd.none )

        OnFecthKeyAccounts (Err error) ->
            ( { model | errMessage = "invalid length" }, Cmd.none )


parseQuery : String -> Result String Query
parseQuery query =
    case String.length query of
        12 ->
            Ok AccountQuery

        53 ->
            Ok PublicKeyQuery

        _ ->
            Err "invalid input"


accountDecoder : JD.Decoder Account
accountDecoder =
    JD.map2 Account
        (JD.field "account_name" JD.string)
        (JD.field "core_liquid_balance" JD.string)


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
