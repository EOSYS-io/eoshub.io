module Header exposing (..)

import Html exposing (Html, Attribute, div, input, button, text)
import Html.Attributes exposing (placeholder)
import Html.Events exposing (on, onInput, onClick, keyCode)
import Http
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Json.Encode as JE
import Regex exposing (regex, contains)


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
    , ram_quota : Int
    , ram_usage : Int
    , net_limit : Resource
    , cpu_limit : Resource
    , total_resources : ResourceInEos
    , self_delegated_bandwidth : Maybe ResourceInEos
    , refund_request : Maybe Refund
    }


type alias ResourceInEos =
    { net_weight : String
    , cpu_weight : String
    , ram_bytes : Maybe Int
    }


type alias Resource =
    { used : Int
    , available : Int
    , max : Int
    }


type alias Refund =
    { owner : String
    , request_time : String
    , net_amount : String
    , cpu_amount : String
    }


initModel : Model
initModel =
    { searchInput = ""
    , eosPrice = 0
    , ramPrice = 0
    , keyAccounts = []
    , account =
        { account_name = ""
        , core_liquid_balance = "0 EOS"
        , ram_quota = 0
        , ram_usage = 0
        , net_limit =
            { used = 0, available = 0, max = 0 }
        , cpu_limit =
            { used = 0, available = 0, max = 0 }
        , total_resources =
            { net_weight = "0 EOS"
            , cpu_weight = "0 EOS"
            , ram_bytes = Just 0
            }
        , self_delegated_bandwidth =
            Just
                { net_weight = "0 EOS"
                , cpu_weight = "0 EOS"
                , ram_bytes = Nothing
                }
        , refund_request =
            Just
                { owner = ""
                , request_time = ""
                , net_amount = ""
                , cpu_amount = ""
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
                                post (getFullPath "/v1/chain/get_account") body accountDecoder |> (Http.send OnFetchAccount)

                        Ok PublicKeyQuery ->
                            let
                                body =
                                    JE.object
                                        [ ( "public_key", JE.string query ) ]
                                        |> Http.jsonBody
                            in
                                post (getFullPath "/v1/history/get_key_accounts") body keyAccountsDecoder |> (Http.send OnFetchKeyAccounts)

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


getFullPath : String -> String
getFullPath path =
    apiUrl ++ path


parseQuery : String -> Result String Query
parseQuery query =
    -- EOS account's length is less than 12 letters
    -- EOS public key's length is 53 letters
    if isAccount query then
        Ok AccountQuery
    else if isPublicKey query then
        Ok PublicKeyQuery
    else
        Err "invalid input"


isAccount : String -> Bool
isAccount query =
    contains (regex "^[a-z.1-5]{1,12}$") query


isPublicKey : String -> Bool
isPublicKey query =
    contains (regex "^EOS[\\w]{50}$") query


accountDecoder : JD.Decoder Account
accountDecoder =
    decode Account
        |> required "account_name" JD.string
        |> optional "core_liquid_balance" JD.string "0 EOS"
        |> required "ram_quota" JD.int
        |> required "ram_usage" JD.int
        |> required "net_limit"
            (decode Resource
                |> required "used" JD.int
                |> required "available" JD.int
                |> required "max" JD.int
            )
        |> required "cpu_limit"
            (decode Resource
                |> required "used" JD.int
                |> required "available" JD.int
                |> required "max" JD.int
            )
        |> required "total_resources"
            (decode ResourceInEos
                |> required "net_weight" JD.string
                |> required "cpu_weight" JD.string
                |> required "ram_bytes" (JD.nullable JD.int)
            )
        |> required "self_delegated_bandwidth"
            (JD.nullable
                (decode ResourceInEos
                    |> required "net_weight" JD.string
                    |> required "cpu_weight" JD.string
                    |> optional "ram_bytes" (JD.nullable JD.int) Nothing
                )
            )
        |> required "refund_request"
            (JD.nullable
                (decode Refund
                    |> required "owner" JD.string
                    |> required "request_time" JD.string
                    |> required "net_amount" JD.string
                    |> required "cpu_amount" JD.string
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
        [ input [ placeholder "계정명, 퍼블릭키 검색하기", onInput InputSearch, onEnter (GetSearchResult (model.searchInput)) ] []
        , button [ onClick (GetSearchResult (model.searchInput)) ] [ text "검색하기" ]
        ]


onEnter : Message -> Attribute Message
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                JD.succeed msg
            else
                JD.fail "not ENTER"
    in
        on "keydown" (JD.andThen isEnter keyCode)
