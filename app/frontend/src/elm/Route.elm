module Route exposing (ComponentRoute(..), Route(..), getComponentRoute, matchRoute, parseLocation)

import Navigation exposing (Location)
import UrlParser exposing ((</>), (<?>), Parser, map, oneOf, parsePath, s, string, stringParam, top)


type Route
    = IndexRoute
    | ConfirmEmailRoute (Maybe String)
    | EmailConfirmedRoute String (Maybe String) (Maybe String)
    | EmailConfirmFailureRoute
    | CreateKeysRoute
    | CreatedRoute
    | CreateRoute String
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
        , map ConfirmEmailRoute (s "account" </> s "confirm_email" <?> stringParam "locale")
        , map EmailConfirmedRoute (s "account" </> s "email_confirmed" </> string <?> stringParam "email" <?> stringParam "locale")
        , map EmailConfirmFailureRoute (s "account" </> s "email_confirm_failure")
        , map CreateKeysRoute (s "account" </> s "create_keys")
        , map CreatedRoute (s "account" </> s "created")
        , map CreateRoute (s "account" </> s "create" </> string)
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
