module Data.Login exposing
    ( Model
    , convertModelToLower
    , encode
    , initLogin
    , isValid
    , modifyEmail
    , modifyPassword
    )

import Email
import Json.Encode as Encode


type alias Model =
    { email : String
    , password : String
    }


initLogin : Model
initLogin =
    { email = "", password = "" }


convertModelToLower : Model -> Model
convertModelToLower model =
    { model | email = String.toLower model.email }


modifyEmail : String -> Model -> Model
modifyEmail email model =
    { model | email = email }


modifyPassword : String -> Model -> Model
modifyPassword password model =
    { model | password = password }


isValid : Model -> Bool
isValid model =
    hasValidEmail model.email && hasValidPassword model.password


hasValidEmail : String -> Bool
hasValidEmail email =
    case email |> Email.fromString of
        Just _ ->
            True

        Nothing ->
            False


hasValidPassword : String -> Bool
hasValidPassword password =
    password |> String.length |> (<) 0


encode : Model -> Encode.Value
encode login =
    Encode.object
        [ ( "email", Encode.string login.email )
        , ( "password", Encode.string login.password )
        ]
