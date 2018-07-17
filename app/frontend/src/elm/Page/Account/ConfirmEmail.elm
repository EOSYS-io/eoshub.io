module Page.Account.ConfirmEmail exposing (Message(..), Model, createUserBodyParams, initModel, update, view)

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
    { email : String, requestStatus : Response, flags : Flags }


initModel : Flags -> Model
initModel flags =
    { email = "", requestStatus = { msg = "" }, flags = flags }



-- UPDATES


type Message
    = Email String
    | CreateUser
    | NewUser (Result Http.Error Response)


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case msg of
        Email email ->
            ( { model | email = email }, Cmd.none )

        CreateUser ->
            ( model, createUserRequest model )

        NewUser (Ok res) ->
            ( { model | requestStatus = res }, Cmd.none )

        NewUser (Err error) ->
            ( { model | requestStatus = { msg = toString error } }, Cmd.none )



-- VIEW


view : Model -> Html Message
view model =
    div []
        [ input [ placeholder "email@example.com", onInput Email ] []
        , button [ onClick CreateUser ] [ text "인증 메일 전송" ]
        , p [] [ text model.requestStatus.msg ]
        ]



-- HTTP


type alias Response =
    { msg : String }


responseDecoder : Decoder Response
responseDecoder =
    decode Response
        |> required "msg" string


createUserBodyParams : Model -> Http.Body
createUserBodyParams model =
    Encode.object [ ( "email", Encode.string model.email ) ]
        |> Http.jsonBody


postUsers : Model -> Http.Request Response
postUsers model =
    Http.post (Urls.usersApiUrl model.flags) (createUserBodyParams model) responseDecoder


createUserRequest : Model -> Cmd Message
createUserRequest model =
    Http.send NewUser <| postUsers model
