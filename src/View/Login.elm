module View.Login exposing (Model, Msg(..), update, view)

import Data.Login as LoginData
import Email
import Html exposing (button, div, form, input, label)
import Html.Attributes exposing (class, classList, disabled, placeholder, readonly, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Json.Decode as Decode
import Ports


type Msg
    = FetchCred
    | LoginReady LoginData.Model
    | Form Field


type Field
    = Email String
    | Password String


type Model
    = Loading
    | Loaded LoginData.Model
    | Error


view : Model -> Html.Html Msg
view model =
    case model of
        Loading ->
            div [] [ Html.text "Loading ....." ]

        Loaded data ->
            renderWhenLoaded data

        Error ->
            div [] []


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchCred ->
            ( model, fetch model )

        Form field ->
            case field of
                Email email ->
                    ( emailChange email model, Cmd.none )

                Password password ->
                    ( passwordChange password model, Cmd.none )

        LoginReady data ->
            ( Loaded data, Cmd.none )


renderWhenLoaded : LoginData.Model -> Html.Html Msg
renderWhenLoaded data =
    renderView data


renderView : Data -> Html.Html Msg
renderView data =
    form [ onSubmit FetchCred ]
        [ renderField "text" "email" data.email "alpha@code-arbeitet.com" False Email
        , renderField "password" "password" data.password "alpha@code-arbeitet.com" False Password
        , renderSubmitBtn False (isValidData data) "Login" "btn btn-danger" True
        ]


renderHeader : Html.Html Msg
renderHeader =
    div [ class "row spacing" ]
        []


renderField : String -> String -> String -> String -> Bool -> (String -> Field) -> Html.Html Msg
renderField inputType fieldLabel fieldValue fieldPlaceholder isEditable field =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , if isEditable then
            input [ class "form-control", type_ inputType, value fieldValue, placeholder fieldPlaceholder, onInput (Form << field) ] []

          else
            input [ class "form-control", type_ inputType, value fieldValue, placeholder fieldPlaceholder, readonly True ] []
        ]


renderSubmitBtn : Bool -> Bool -> String -> String -> Bool -> Html.Html Msg
renderSubmitBtn isLoading isValid label className isCustom =
    div [ class "form-group" ]
        [ if isLoading && isValid then
            button
                [ type_ "submit"
                , disabled True
                , classList [ ( className, True ), ( "btn-extra", isCustom ) ]
                ]
                [ Html.text "Please wait ..." ]

          else if not isLoading && isValid then
            button
                [ type_ "submit"
                , classList [ ( className, True ), ( "btn-extra", isCustom ) ]
                ]
                [ Html.text label ]

          else
            button
                [ type_ "submit"
                , disabled True
                , classList [ ( "btn btn-extra", isCustom ), ( "btn-invalid", True ) ]
                ]
                [ Html.text label ]
        ]


emailChange : String -> Model -> Model
emailChange email model =
    case model of
        Loading ->
            Loading

        Loaded data ->
            Loaded <| LoignData.modifyEmail email data

        Error ->
            Error


passwordChange : String -> Model -> Model
passwordChange password model =
    case model of
        Loading ->
            Loading

        Loaded data ->
            Loaded <| LoginData.modifyPassword password data

        Error ->
            Error


isValidData : LoginData.Model -> Bool
isValidData data =
    hasValidEmail data.email
        && hasValidPassword data.password


fetch : Model -> Cmd Msg
fetch model =
    case model of
        Loading ->
            Cmd.none

        Loaded data ->
            Cmd.batch [ Ports.sendToJs (Ports.FetchUser data) ]

        Error ->
            Cmd.none
