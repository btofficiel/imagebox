module Post exposing (Post, postsDecoder)

import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (optional, required)


type alias Post =
    { id : Int
    , caption : String
    , filename : String
    }


postDecoder : Decoder Post
postDecoder =
    Decode.succeed Post
        |> required "id" int
        |> required "caption" string
        |> required "image_url" string


postsDecoder : Decoder (List Post)
postsDecoder =
    Decode.at [ "data", "posts" ] (list postDecoder)
