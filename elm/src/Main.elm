module Main exposing (main)

import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (class)
import MessageBanner as Message exposing (MessageBanner)
import Page.Login as Login
import Page.Profile as Profile
import Page.Signup as Signup
import Route exposing (Route, Token, parseUrl)
import Url exposing (Url)


type alias Model =
    { route : Route
    , page : Page
    , auth : AuthenticationStatus
    , navKey : Nav.Key
    }


type Page
    = NotFoundPage
    | LoginPage Login.Model
    | SignupPage Signup.Model
    | ProfilePage Profile.Model


type AuthenticationStatus
    = LoggedIn Token
    | LoggedOut


type Msg
    = LinkClicked UrlRequest
    | UrlChanged Url
    | LoginMsg Login.Msg
    | SignupMsg Signup.Msg
    | ProfileMsg Profile.Msg


getToken : AuthenticationStatus -> Token
getToken auth =
    case auth of
        LoggedIn token ->
            token

        _ ->
            "invalid_token"


parseRoute : AuthenticationStatus -> Route
parseRoute auth =
    case auth of
        LoggedIn _ ->
            Route.Index

        LoggedOut ->
            Route.Index


init : Maybe Token -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init token url navKey =
    let
        model =
            case token of
                Just token_ ->
                    let
                        ( pageModel, pageCmds ) =
                            Profile.init token_
                    in
                    { route = parseUrl url
                    , page = ProfilePage pageModel
                    , auth = LoggedIn token_
                    , navKey = navKey
                    }

                Nothing ->
                    let
                        ( pageModel, pageCmds ) =
                            Login.init
                    in
                    { route = Route.Login
                    , page = LoginPage pageModel
                    , auth = LoggedOut
                    , navKey = navKey
                    }
    in
    initCurrentPage
        ( model
        , Cmd.none
        )


initCurrentPage : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
initCurrentPage ( model, existingCmds ) =
    let
        ( currentPage, mappedPageCmds ) =
            case model.route of
                Route.NotFound ->
                    ( NotFoundPage, Cmd.none )

                Route.Login ->
                    let
                        ( pageModel, pageCmds ) =
                            Login.init
                    in
                    ( LoginPage pageModel, Cmd.map LoginMsg pageCmds )

                Route.Signup ->
                    let
                        ( pageModel, pageCmds ) =
                            Signup.init
                    in
                    ( SignupPage pageModel, Cmd.map SignupMsg pageCmds )

                Route.Index ->
                    let
                        ( pageModel, pageCmds ) =
                            Profile.init (getToken model.auth)
                    in
                    ( ProfilePage pageModel, Cmd.map ProfileMsg pageCmds )
    in
    ( { model | page = currentPage }
    , Cmd.batch [ existingCmds, mappedPageCmds ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.navKey (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , Nav.load url
                    )

        ( UrlChanged url, _ ) ->
            let
                newRoute =
                    Route.parseUrl url
            in
            ( { model | route = newRoute }, Cmd.none )
                |> initCurrentPage

        ( LoginMsg subMsg, LoginPage pageModel ) ->
            let
                ( updatedModel, updatedCmds ) =
                    Login.update subMsg pageModel
            in
            ( { model | page = LoginPage updatedModel }, Cmd.map LoginMsg updatedCmds )

        ( SignupMsg subMsg, SignupPage pageModel ) ->
            let
                ( updatedModel, updatedCmds ) =
                    Signup.update subMsg pageModel
            in
            ( { model | page = SignupPage updatedModel }, Cmd.map SignupMsg updatedCmds )

        ( ProfileMsg subMsg, ProfilePage pageModel ) ->
            let
                ( updatedModel, updatedCmds ) =
                    Profile.update subMsg pageModel (getToken model.auth)
            in
            ( { model | page = ProfilePage updatedModel }, Cmd.map ProfileMsg updatedCmds )

        ( _, _ ) ->
            ( model, Cmd.none )


currentTitle : Route -> String
currentTitle route =
    case route of
        Route.Index ->
            "Imagebox - The photo sharing website"

        Route.Login ->
            "Login to Imagebox"

        Route.Signup ->
            "Join Imagebox"

        Route.NotFound ->
            "Oops, looks like you're lost"


currentView : Model -> Html Msg
currentView model =
    case model.page of
        LoginPage pageModel ->
            Login.view pageModel
                |> Html.map LoginMsg

        SignupPage pageModel ->
            Signup.view pageModel
                |> Html.map SignupMsg

        ProfilePage pageModel ->
            Profile.view pageModel
                |> Html.map ProfileMsg

        NotFoundPage ->
            h1 [] [ text "NotFound" ]


view : Model -> Document Msg
view model =
    { title = currentTitle model.route
    , body = [ currentView model ]
    }


main : Program (Maybe Token) Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }
