module Page.Account.CreateKeys exposing (Message(..), Model, initModel, subscriptions, update, view)

import Html exposing (Html, button, div, h1, p, text)
import Html.Events exposing (onClick)
import Navigation
import Port exposing (KeyPair)


-- MODEL


type alias Model =
    { confirmToken : String
    , keys : KeyPair
    }


initModel : String -> Model
initModel confirmToken =
    { confirmToken = confirmToken
    , keys = { privateKey = "", publicKey = "" }
    }



-- UPDATES


type Message
    = Next
    | GenerateKeys
    | UpdateKeys KeyPair


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case msg of
        Next ->
            ( model, Navigation.newUrl ("/account/create/" ++ model.confirmToken ++ "/" ++ model.keys.publicKey) )

        GenerateKeys ->
            ( model, Port.generateKeys () )

        UpdateKeys keyPair ->
            ( { model | keys = keyPair }, Cmd.none )



-- VIEW


view : Model -> Html Message
view model =
    div []
        [ p [] [ text model.keys.publicKey ]
        , p [] [ text model.keys.privateKey ]
        , p [] [ text "키 쌍을 만들었어요." ]
        , button [ onClick Next ] [ text "다음" ]
        ]



-- SUBSCRIPTIONS


subscriptions : Sub Message
subscriptions =
    Port.receiveKeys UpdateKeys
