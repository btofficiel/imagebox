module Auth exposing (Auth, authDecoder, authEncoder)

import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode


type alias Auth =
    { token : String
    }


authDecoder : Decoder Auth
authDecoder =
    Decode.at [ "data" ] <|
        (Decode.succeed Auth
            |> required "token" string
        )


authEncoder : { email : String, password : String } -> Encode.Value
authEncoder payload =
    Encode.object
        [ ( "email", Encode.string payload.email )
        , ( "password", Encode.string payload.password )
        ]
