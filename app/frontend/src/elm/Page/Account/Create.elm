module Page.Account.Create exposing (Message(..), Model, createEosAccountBodyParams, initModel, update, view)

import Html exposing (Html, button, div, input, li, p, text, ul, ol, h1, img, text, br, form, article, span)
import Html.Attributes exposing (placeholder, class, attribute, alt, src, type_)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Util.Flags exposing (Flags)
import Util.Urls as Urls
import Validate exposing (Validator, validate, fromErrors)
import Array.Hamt as Array exposing (Array)
import Navigation


-- MODEL


type alias Model =
    { accountName : String
    , requestStatus : Response
    , pubkey : String
    , validation : Bool
    , validationMsg : String
    , requestSuccess : Bool
    , confirmToken : String }


initModel : String -> String -> Model
initModel confirmToken pubkey =
    { accountName = ""
    , requestStatus = { msg = "" }
    , pubkey = pubkey
    , validation = False
    , validationMsg = ""
    , requestSuccess = False
    , confirmToken = confirmToken }



-- UPDATES


type Message
    = ValidateAccountName String
    | CreateEosAccount
    | NewUser (Result Http.Error Response)


update : Message -> Model -> Flags -> ( Model, Cmd Message )
update msg model flags =
    case msg of
        ValidateAccountName accountName ->
            let
                newModel =
                    { model | accountName = accountName }

                accountNameLength =
                    String.length newModel.accountName

                ( validateMsg, validate ) =
                    if accountNameLength == 12 then
                        ( "가능한 ID에요", True )
                    else
                        ( "불가능한 ID에요", False )
            in
                ( { newModel | validation = validate, validationMsg = validateMsg }, Cmd.none )

        CreateEosAccount ->
            ( model, createEosAccountRequest model flags model.confirmToken )

        NewUser (Ok res) ->
            ( { model | requestStatus = res, requestSuccess = True }, Navigation.newUrl ("/account/created") )

        NewUser (Err error) ->
            ( { model | requestStatus = { msg = toString error }, requestSuccess = False }, Cmd.none )



-- VIEW


view : Model -> Html Message
view model =
    div [ class "container join" ]
        [ ol [ class "progress bar" ]
            [ li [ class "done" ]
                [ text "인증하기" ]
            , li [ class "done" ]
                [ text "키 생성" ]
            , li [ class "ing" ]
                [ text "계정생성" ]
            ]
        , article [ attribute "data-step" "4" ]
            [ h1 []
                [ img [ alt "", src "./image/symbol-smile.svg" ]
                    []
                , text "원하는 계정의 이름을 입력해주세요!    "
                ]
            , p []
                [ text "계정명은 1~5 사이의 숫자와 영어 소문자의 조합으로 12글자만 가능합니다!"
                , br []
                    []
                , text "ex) eoshuby12345"
                ]
            , form []
                [ input [ class "account_name", placeholder "계정이름은 반드시 12글자로 입력해주세요", attribute "required" "", attribute (if model.validation then
                            "valid"
                        else
                            "invalid"
                        ) "", type_ "text", onInput ValidateAccountName ]
                    []
                , span []
                    [ text model.requestStatus.msg ]
                ]
            ]
        , div [ class "btn_area" ]
            [ button [ class "middle blue_white button", attribute (if model.validation && not model.requestSuccess then
                            "enabled"
                        else
                            "disabled"
                        ) "", type_ "button", onClick CreateEosAccount ]
                [ text "다음" ]
            ]
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
