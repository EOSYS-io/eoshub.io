module Route exposing (Route(..), parseLocation, route)

import Navigation exposing (Location)
import UrlParser exposing (Parser, map, oneOf, parsePath, s, top)


type Route
    = IndexRoute
    | AccountCreateRoute
    | SearchRoute
    | VotingRoute
    | TransferRoute
    | NotFoundRoute


route : Parser (Route -> a) a
route =
    oneOf
        [ map IndexRoute top
        , map AccountCreateRoute (s "account_create")
        , map SearchRoute (s "search")
        , map VotingRoute (s "voting")
        , map TransferRoute (s "transfer")
        ]


parseLocation : Location -> Route
parseLocation location =
    case parsePath route location of
        Just route ->
            route

        Nothing ->
            NotFoundRoute
