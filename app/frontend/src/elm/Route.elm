module Route exposing (Route(..), matchRoute, parseLocation)

import Navigation exposing (Location)
import UrlParser exposing ((</>), (<?>), Parser, map, oneOf, parsePath, s, string, top, stringParam)


type Route
    = IndexRoute
    | ConfirmEmailRoute
    | EmailConfirmedRoute String (Maybe String)
    | EmailConfirmFailureRoute
    | CreateKeysRoute String
    | CreatedRoute
    | CreateRoute String String
    | SearchRoute
    | VotingRoute
    | TransferRoute
    | NotFoundRoute


matchRoute : Parser (Route -> a) a
matchRoute =
    oneOf
        [ map IndexRoute top
        , map ConfirmEmailRoute (s "account" </> s "confirm_email")
        , map EmailConfirmedRoute (s "account" </> s "email_confirmed" </> string <?> stringParam "email")
        , map EmailConfirmFailureRoute (s "account" </> s "email_confirm_failure")
        , map CreateKeysRoute (s "account" </> s "create_keys" </> string)
        , map CreatedRoute (s "account" </> s "created")
        , map CreateRoute (s "account" </> s "create" </> string </> string)
        , map SearchRoute (s "search")
        , map VotingRoute (s "voting")
        , map TransferRoute (s "transfer")
        ]


parseLocation : Location -> Route
parseLocation location =
    case parsePath matchRoute location of
        Just route ->
            route

        Nothing ->
            NotFoundRoute
