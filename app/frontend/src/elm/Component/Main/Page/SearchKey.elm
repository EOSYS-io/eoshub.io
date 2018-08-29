module Component.Main.Page.SearchKey exposing (..)

import Translation exposing (I18n(..), Language, translate)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Util.HttpRequest exposing (..)
import Json.Encode as JE
import Data.Account exposing (..)
import Navigation exposing (..)


-- MODEL


type alias Model =
    { accounts : List String
    , publickey : String
    }


initModel : String -> Model
initModel query =
    { accounts = []
    , publickey = query
    }


initCmd : String -> Cmd Message
initCmd query =
    let
        newCmd =
            let
                body =
                    JE.object
                        [ ( "public_key", JE.string query ) ]
                        |> Http.jsonBody
            in
                post (getFullPath "/v1/history/get_key_accounts") body keyAccountsDecoder
                    |> (Http.send OnFetchKeyAccounts)
    in
        newCmd



-- UPDATE


type Message
    = OnFetchKeyAccounts (Result Http.Error (List String))
    | ChangeUrl String


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        OnFetchKeyAccounts (Ok data) ->
            ( { model | accounts = data }, Cmd.none )

        OnFetchKeyAccounts (Err error) ->
            ( model, Cmd.none )

        ChangeUrl url ->
            ( model, Navigation.newUrl url )



-- VIEW


view : Language -> Model -> Html Message
view language { accounts, publickey } =
    main_ [ class "search public_key" ]
        [ h2 []
            [ text "공개 키 검색" ]
        , p []
            [ text "검색하신 계정에 대한 정보입니다." ]
        , div [ class "container" ]
            [ div [ class "summary" ]
                [ dt []
                    [ text "공개 키 이름" ]
                , dd []
                    [ text publickey ]
                ]
            , div [ class "keybox" ]
                (viewAccountCardList accounts)
            ]
        ]


viewAccountCardList : List String -> List (Html Message)
viewAccountCardList accounts =
    List.indexedMap viewAccountCard accounts


viewAccountCard : Int -> String -> Html Message
viewAccountCard index account =
    div []
        [ span [] [ text <| "계정 " ++ (toString (index + 1)) ]
        , strong
            [ title account ]
            [ text account ]
        , button [ type_ "button", onClick (ChangeUrl ("/search?query=" ++ account)) ]
            [ text "자세한 검색 보기" ]
        ]
