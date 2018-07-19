module Page.Account.Create exposing (Message(..), Model, createEosAccountBodyParams, initModel, update, view)

import Html exposing (Html, button, div, input, li, p, text, ul)
import Html.Attributes exposing (placeholder)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Util.Flags exposing (Flags)
import Util.Urls as Urls


-- MODEL


type alias Model =
    { accountName : String, requestStatus : Response, pubkey : String }


initModel : String -> Model
initModel pubkey =
    { accountName = "", requestStatus = { msg = "" }, pubkey = pubkey }



-- UPDATES


type Message
    = AccountName String
    | CreateEosAccount
    | NewUser (Result Http.Error Response)


update : Message -> Model -> Flags -> String -> ( Model, Cmd Message )
update msg model flags confirmToken =
    case msg of
        AccountName accountName ->
            ( { model | accountName = accountName }, Cmd.none )

        CreateEosAccount ->
            ( model, createEosAccountRequest model flags confirmToken )

        NewUser (Ok res) ->
            ( { model | requestStatus = res }, Cmd.none )

        NewUser (Err error) ->
            ( { model | requestStatus = { msg = toString error } }, Cmd.none )



-- VIEW


view : Model -> Html Message
view model =
    div []
        [ input [ placeholder "abcdefghijkl(12자)", onInput AccountName ] []
        , button [ onClick CreateEosAccount ] [ text "다음" ]
        , p [] [ text model.requestStatus.msg ]
        ]



-- HTTP


type alias Response =
    { msg : String }


responseDecoder : Decoder Response
responseDecoder =
    decode Response
        |> required "msg" string


createEosAccountBodyParams : Model -> Http.Body
createEosAccountBodyParams model =
    Encode.object
        [ ( "account_name", Encode.string model.accountName )
        , ( "pubkey", Encode.string model.pubkey )
        ]
        |> Http.jsonBody


postCreateEosAccount : Model -> Flags -> String -> Http.Request Response
postCreateEosAccount model flags confirmToken =
    let
        url =
            Urls.createEosAccountUrl ( flags, confirmToken )

        params =
            createEosAccountBodyParams model
    in
        Http.post url params responseDecoder


createEosAccountRequest : Model -> Flags -> String -> Cmd Message
createEosAccountRequest model flags confirmToken =
    Http.send NewUser <| postCreateEosAccount model flags confirmToken
