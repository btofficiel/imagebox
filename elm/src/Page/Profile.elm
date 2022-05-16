port module Page.Profile exposing (Model, Msg, init, update, view)

import Api
import Browser.Navigation as Nav
import File exposing (File)
import File.Select as Select
import Html exposing (Attribute, Html, a, button, div, img, input, li, section, span, text, textarea, ul)
import Html.Attributes exposing (class, href, id, placeholder, rows, src, style, type_, value)
import Html.Events exposing (on, onClick, onInput)
import Http
import Json.Decode as D
import MessageBanner as Message exposing (MessageBanner)
import Post exposing (Post, postsDecoder)
import RemoteData exposing (WebData)
import Request
import Route exposing (Token)
import Task


type alias Model =
    { caption : String
    , previewedImage : String
    , uploadedImage : Maybe File
    , view : View
    , message : MessageBanner
    , posts : WebData (List Post)
    }


type View
    = Profile
    | ViewImage
    | UploadImage


type Msg
    = EnterCaption String
    | ImageRequested
    | ImageLoaded File
    | ImageURLLoaded String
    | GotResponse (Result Http.Error ())
    | GotPosts (WebData (List Post))
    | FetchPosts
    | Upload
    | PreviewImage String String
    | SignOut
    | FadeMessage


init : Token -> ( Model, Cmd Msg )
init token =
    ( { caption = ""
      , previewedImage = ""
      , uploadedImage = Nothing
      , view = Profile
      , message = Nothing
      , posts = RemoteData.Loading
      }
    , fetchPosts token
    )


fetchPosts : Token -> Cmd Msg
fetchPosts token =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Authorization" token ]
        , url = "/api/profile"
        , body = Http.emptyBody
        , expect = Request.expectJson (RemoteData.fromResult >> GotPosts) postsDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


upload : Token -> { caption : String, image : File } -> Cmd Msg
upload token payload =
    let
        decoder =
            D.succeed ()
    in
    Http.request
        { method = "POST"
        , url = "/api/upload"
        , headers = [ Http.header "Authorization" token ]
        , body =
            Http.multipartBody
                [ Http.stringPart "caption" payload.caption
                , Http.filePart "image" payload.image
                ]
        , expect = Request.expectJson GotResponse decoder
        , timeout = Nothing
        , tracker = Nothing
        }


viewUploader : Model -> Html Msg
viewUploader model =
    div [ class "upload" ]
        [ img [ src model.previewedImage, class "photo" ] []
        , div [ class "caption" ]
            [ textarea
                [ id "caption"
                , class "caption"
                , placeholder "Write a caption for this..."
                , rows 5
                , value model.caption
                , onInput EnterCaption
                ]
                []
            , button [ class "form", onClick Upload ] [ text "Upload" ]
            ]
        ]


viewPreview : Model -> Html Msg
viewPreview model =
    div [ class "upload" ]
        [ img [ src model.previewedImage, class "photo" ] []
        , div [ class "caption" ] [ div [ class "empty-state" ] [ text model.caption ] ]
        ]


viewProfile : Model -> Html Msg
viewProfile model =
    case model.posts of
        RemoteData.NotAsked ->
            div [ class "feed" ]
                [ div [ class "progress-bar" ]
                    [ div [ class "progress-bar-value" ] []
                    ]
                ]

        RemoteData.Loading ->
            div [ class "feed" ]
                [ div [ class "progress-bar" ]
                    [ div [ class "progress-bar-value" ] []
                    ]
                ]

        RemoteData.Success posts ->
            let
                path =
                    "/static/media/processed/"
            in
            case List.length posts > 0 of
                True ->
                    div [ class "photos" ]
                        (List.map (\t -> div [ class "photo" ] [ img [ class "photo", src (String.concat [ path, t.filename ]), onClick (PreviewImage t.caption t.filename) ] [] ]) posts)

                False ->
                    div [ class "feed" ]
                        [ img [ class "empty-icon", src "/static/images/camera.png" ] []
                        , div [ class "empty-state" ] [ text "Looks like you haven't uploaded any photos yet." ]
                        ]

        RemoteData.Failure (Http.BadBody err) ->
            div [ class "feed" ]
                [ img [ class "empty-icon", src "/static/images/camera.png" ] []
                , div [ class "empty-state" ] [ text err ]
                ]

        RemoteData.Failure Http.NetworkError ->
            div [ class "feed" ]
                [ img [ class "empty-icon", src "/static/images/camera.png" ] []
                , div [ class "empty-state" ] [ text "Oops! Looks like there is some problem with your network." ]
                ]

        _ ->
            div [] []


body : Model -> Html Msg
body model =
    div [ class "main" ]
        [ div [ class "profile" ]
            [ div [ class "nav" ]
                [ img [ src "/static/images/logo.png", class "logo-header", onClick FetchPosts ] []
                , ul []
                    [ li [ onClick ImageRequested ]
                        [ img [ class "button", src "/static/images/upload.png" ] []
                        ]
                    , li [ onClick SignOut ]
                        [ img [ class "button", src "/static/images/logout.png" ] []
                        ]
                    ]
                ]
            , case model.view of
                Profile ->
                    viewProfile model

                ViewImage ->
                    viewPreview model

                UploadImage ->
                    viewUploader model
            ]
        ]


view : Model -> Html Msg
view model =
    div []
        [ Message.viewMessage model.message
        , body model
        ]


port resizeTextArea : String -> Cmd msg


update : Msg -> Model -> Token -> ( Model, Cmd Msg )
update msg model token =
    case msg of
        EnterCaption caption ->
            ( { model
                | caption = String.slice 0 250 caption
              }
            , resizeTextArea "caption"
            )

        ImageRequested ->
            ( model
            , Select.file [ "image/png", "image/jpg", "image/jpeg" ] ImageLoaded
            )

        ImageLoaded image ->
            let
                isFileTypeAlllowed =
                    [ "image/jpeg", "image/png", "image/jpg" ]
                        |> List.member (File.mime image)
            in
            case isFileTypeAlllowed of
                True ->
                    ( { model
                        | uploadedImage = Just image
                      }
                    , Task.perform ImageURLLoaded (File.toUrl image)
                    )

                False ->
                    ( { model
                        | message = Just (Message.Failure "Please upload a JPG or PNG image")
                      }
                    , Cmd.none
                    )

        ImageURLLoaded imageUrl ->
            ( { model
                | previewedImage = imageUrl
                , view = UploadImage
              }
            , Cmd.none
            )

        GotResponse (Ok _) ->
            ( { model
                | message = Just (Message.Success "Your photo has been uploaded")
              }
            , Message.fadeMessage FadeMessage
            )

        GotResponse (Err error) ->
            case error of
                Http.BadBody err ->
                    ( { model | message = Just (Message.Failure err) }, Message.fadeMessage FadeMessage )

                Http.NetworkError ->
                    let
                        err =
                            "Oops! Looks like there is some problem with your network."
                    in
                    ( { model | message = Just (Message.Failure err) }, Message.fadeMessage FadeMessage )

                Http.BadStatus 401 ->
                    ( model
                    , Cmd.batch
                        [ Api.deleteToken ()
                        ]
                    )

                _ ->
                    let
                        err =
                            "Oops! Something bad happened, please try reloading the app"
                    in
                    ( { model | message = Just (Message.Failure err) }, Message.fadeMessage FadeMessage )

        Upload ->
            case model.uploadedImage of
                Just image ->
                    let
                        payload =
                            { caption = model.caption
                            , image = image
                            }
                    in
                    ( { model
                        | message = Just Message.Loading
                      }
                    , upload token payload
                    )

                Nothing ->
                    ( { model
                        | message = Just (Message.Failure "Try reloading the app")
                      }
                    , Message.fadeMessage FadeMessage
                    )

        GotPosts response ->
            ( { model
                | posts = response
              }
            , Cmd.none
            )

        SignOut ->
            ( model, Api.deleteToken () )

        FetchPosts ->
            ( { model | view = Profile }, fetchPosts token )

        PreviewImage caption filename ->
            let
                path =
                    String.concat [ "/static/media/processed/", filename ]
            in
            ( { model
                | caption = caption
                , previewedImage = path
                , view = ViewImage
              }
            , Cmd.none
            )

        FadeMessage ->
            ( { model | message = Nothing }, Cmd.none )
