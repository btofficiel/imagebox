module MessageBanner exposing (Message(..), MessageBanner, fadeMessage, viewMessage)

import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class)
import Process
import Task


type Message
    = Loading
    | Success String
    | Failure String


type alias MessageBanner =
    Maybe Message


fadeMessage : msg -> Cmd msg
fadeMessage message =
    Process.sleep 3000
        |> Task.perform (\_ -> message)


generateMessageClass : MessageBanner -> String
generateMessageClass message =
    case message of
        Just Loading ->
            "progress-header"

        _ ->
            ""


viewMessage : MessageBanner -> Html msg
viewMessage message =
    div
        [ class
            (String.concat
                [ "message"
                , " "
                , case message of
                    Just Loading ->
                        "loading"

                    Just (Success _) ->
                        "success"

                    Just (Failure _) ->
                        "error"

                    Nothing ->
                        "nothing"
                ]
            )
        ]
        [ span [ class (generateMessageClass message) ]
            (case message of
                Just Loading ->
                    []

                Just (Failure msg) ->
                    [ text msg ]

                Just (Success msg) ->
                    [ text msg ]

                Nothing ->
                    [ text "" ]
            )
        ]
