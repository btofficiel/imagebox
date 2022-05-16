module Route exposing (Route(..), Token, matchRoute, parseUrl)

import Url exposing (Url)
import Url.Parser exposing (..)


type alias Token =
    String


type Route
    = Index
    | Login
    | Signup
    | NotFound


parseUrl : Url -> Route
parseUrl url =
    case parse matchRoute url of
        Just route ->
            route

        Nothing ->
            NotFound


matchRoute : Parser (Route -> a) a
matchRoute =
    oneOf
        [ map Index (s "app")
        , map Login (s "app" </> s "login")
        , map Signup (s "app" </> s "signup")
        , map NotFound (s "app" </> s "not-found")
        ]
