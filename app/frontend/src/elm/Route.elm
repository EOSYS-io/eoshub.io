module Route exposing (..)

import Navigation exposing (Location)
import UrlParser exposing ((</>), (<?>), Parser, map, oneOf, parsePath, s, string, top, stringParam)


type Route
    = IndexRoute
    | ConfirmEmailRoute (Maybe String)
    | EmailConfirmedRoute String (Maybe String) (Maybe String)
    | EmailConfirmFailureRoute
    | CreateKeysRoute
    | CreatedRoute
    | CreateRoute String
    | SearchRoute (Maybe String)
    | SearchKeyRoute (Maybe String)
    | VotingRoute
    | TransferRoute
    | ResourceRoute
    | NotFoundRoute


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
        , map SearchRoute (s "search" <?> stringParam "query")
        , map SearchKeyRoute (s "searchkey" <?> stringParam "query")
        , map VotingRoute (s "voting")
        , map TransferRoute (s "transfer")
        , map ResourceRoute (s "resource")
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
