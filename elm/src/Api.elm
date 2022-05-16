port module Api exposing (deleteToken, storeToken)


port storeToken : String -> Cmd msg


port deleteToken : () -> Cmd msg
