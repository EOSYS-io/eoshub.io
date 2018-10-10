module Component.Main.Page.SearchKey exposing
    ( Message(..)
    , Model
    , initCmd
    , initModel
    , update
    , view
    , viewAccountCard
    , viewAccountCardList
    )

import Data.Account exposing (keyAccountsDecoder)
import Html exposing (Html, button, dd, div, dt, h2, main_, p, span, strong, text)
import Html.Attributes exposing (class, title, type_)
import Html.Events exposing (onClick)
import Http
import Json.Encode as JE
import Navigation
import Translation exposing (I18n(..), Language, translate)
import Util.HttpRequest exposing (getFullPath, post)



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
                |> Http.send OnFetchKeyAccounts
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

        OnFetchKeyAccounts (Err _) ->
            ( model, Cmd.none )

        ChangeUrl url ->
            ( model, Navigation.newUrl url )



-- VIEW


view : Language -> Model -> Html Message
view language { accounts, publickey } =
    main_ [ class "search public_key" ]
        [ h2 []
            [ text (translate language SearchPublicKey) ]
        , p []
            [ text (translate language SearchResultPublicKey) ]
        , div [ class "container" ]
            [ div [ class "summary" ]
                [ dt []
                    [ text (translate language SearchPublicKey) ]
                , dd []
                    [ text publickey ]
                ]
            , div [ class "keybox" ]
                (viewAccountCardList language accounts)
            ]
        ]


viewAccountCardList : Language -> List String -> List (Html Message)
viewAccountCardList language accounts =
    List.indexedMap (viewAccountCard language) accounts


viewAccountCard : Language -> Int -> String -> Html Message
viewAccountCard language index account =
    div []
        [ span [] [ text <| translate language Translation.Account ++ " " ++ toString (index + 1) ]
        , strong
            [ title account ]
            [ text account ]
        , button [ type_ "button", onClick (ChangeUrl ("/search?query=" ++ account)) ]
            [ text "자세한 검색 보기" ]
        ]
