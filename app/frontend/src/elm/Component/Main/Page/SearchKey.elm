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
import Html exposing (Html, dd, div, dt, h2, main_, p, span, strong, text)
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
            ( model, Navigation.newUrl "/notfound" )

        ChangeUrl url ->
            ( model, Navigation.newUrl url )



-- VIEW


view : Language -> Model -> Html Message
view language { accounts, publickey } =
    let
        count =
            List.length accounts
                |> toString
    in
    main_ [ class "search public_key" ]
        [ h2 []
            [ text (translate language SearchPublicKey) ]
        , p []
            [ text (translate language SearchResultPublicKey) ]
        , div [ class "container" ]
            [ div [ class "summary" ]
                [ dt []
                    [ text (translate language PublicKey) ]
                , dd []
                    [ text publickey ]
                ]
            , p [ class "description" ] [ text (translate language (LinkedCount count)) ]
            , div [ class "keybox" ]
                (viewAccountCardList language accounts)
            ]
        ]


viewAccountCardList : Language -> List String -> List (Html Message)
viewAccountCardList language accounts =
    List.map (viewAccountCard language) accounts


viewAccountCard : Language -> String -> Html Message
viewAccountCard language account =
    div [ type_ "button", onClick (ChangeUrl ("/search?query=" ++ account)) ]
        [ span [] [ text <| translate language Translation.Account ]
        , strong
            [ title account ]
            [ text account ]
        ]
