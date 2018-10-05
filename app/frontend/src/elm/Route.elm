module Route exposing (ComponentRoute(..), Route(..), getComponentRoute, matchRoute, parseLocation)

import Navigation exposing (Location)
import UrlParser exposing ((</>), (<?>), Parser, map, oneOf, parsePath, s, string, stringParam, top)


type Route
    = IndexRoute
    | CreatedRoute (Maybe String) (Maybe String)
    | EventCreationRoute (Maybe String)
    | SearchRoute (Maybe String)
    | SearchKeyRoute (Maybe String)
    | VoteRoute
    | TransferRoute
    | ResourceRoute
    | NotFoundRoute
    | RammarketRoute


matchRoute : Parser (Route -> a) a
matchRoute =
    oneOf
        [ map IndexRoute top
        , map CreatedRoute (s "account" </> s "created" <?> stringParam "eos_account" <?> stringParam "public_key")
        , map EventCreationRoute (s "account" </> s "event_creation" <?> stringParam "locale")
        , map SearchRoute (s "search" <?> stringParam "query")
        , map SearchKeyRoute (s "searchkey" <?> stringParam "query")
        , map VoteRoute (s "vote")
        , map TransferRoute (s "transfer")
        , map ResourceRoute (s "resource")
        , map RammarketRoute (s "rammarket")
        ]


parseLocation : Location -> Route
parseLocation location =
    case parsePath matchRoute location of
        Just route ->
            route

        Nothing ->
            NotFoundRoute


type ComponentRoute
    = MainComponentRoute
    | AccountComponentRoute


getComponentRoute : Location -> ComponentRoute
getComponentRoute location =
    if String.startsWith "/account/" location.pathname then
        AccountComponentRoute

    else
        MainComponentRoute
