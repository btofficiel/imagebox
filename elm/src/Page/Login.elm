module Page.Login exposing (Model, Msg, init, update, view)

import Api
import Auth exposing (Auth, authDecoder, authEncoder)
import Browser.Navigation as Nav
import Html exposing (Attribute, Html, a, button, div, img, input, li, section, span, text, textarea, ul)
import Html.Attributes exposing (class, href, id, placeholder, src, style, type_, value)
import Html.Events exposing (on, onClick, onInput)
import Http
import MessageBanner as Message exposing (MessageBanner)
import RemoteData exposing (WebData)
import Request


type alias Model =
    { email : String
    , password : String
    , message : MessageBanner
    , auth : WebData Auth
    }


type Msg
    = EnterEmail String
    | EnterPassword String
    | Login
    | GotAuth (WebData Auth)
    | FadeMessage


init : ( Model, Cmd Msg )
init =
    ( { email = ""
      , password = ""
      , message = Nothing
      , auth = RemoteData.NotAsked
      }
    , Cmd.none
    )


login : { email : String, password : String } -> Cmd Msg
login payload =
    Http.request
        { method = "POST"
        , url = "/api/login"
        , headers = []
        , body = Http.jsonBody (authEncoder payload)
        , expect = Request.expectJson (RemoteData.fromResult >> GotAuth) authDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


body : Model -> Html Msg
body model =
    div [ class "main" ]
        [ div [ class "form" ]
            [ img [ src "/static/images/logo.png", class "logo" ] []
            , input [ class "form", type_ "email", placeholder "Enter your email", value model.email, onInput EnterEmail ] []
            , input [ class "form", type_ "password", placeholder "Enter your password", value model.password, onInput EnterPassword ] []
            , button [ class "form", onClick Login ] [ text "Login" ]
            , a [ href "/app/signup" ] [ text "Don't have an account? Join now." ]
            ]
        ]


view : Model -> Html Msg
view model =
    div []
        [ Message.viewMessage model.message
        , body model
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EnterEmail email ->
            ( { model
                | email = email
              }
            , Cmd.none
            )

        EnterPassword password ->
            ( { model
                | password = password
              }
            , Cmd.none
            )

        Login ->
            let
                payload =
                    { email = model.email
                    , password = model.password
                    }
            in
            ( { model
                | message = Just Message.Loading
              }
            , login payload
            )

        GotAuth response ->
            case response of
                RemoteData.Success auth ->
                    ( { model
                        | message = Just (Message.Success "Let's go!")
                      }
                    , Api.storeToken auth.token
                    )

                RemoteData.Failure (Http.BadBody err) ->
                    ( { model
                        | message = Just (Message.Failure err)
                      }
                    , Cmd.none
                    )

                RemoteData.Failure Http.NetworkError ->
                    let
                        err =
                            "Oops! Looks like there is some problem with your network."
                    in
                    ( { model
                        | message = Just (Message.Failure err)
                      }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        FadeMessage ->
            ( { model | message = Nothing }, Cmd.none )
