module View.LoginView exposing (Model, Msg(..), default, update, view)

import Data.Login as Login
import Html exposing (button, div, form, input, label)
import Html.Attributes exposing (class, classList, disabled, placeholder, readonly, type_, value)
import Html.Events exposing (onInput, onSubmit)
import Ports


type Msg
    = FetchCred
    | LoginReady Login.Model
    | Form Field


type Field
    = Email String
    | Password String


type Model
    = Loading
    | Loaded Login.Model
    | Error


default : Model
default =
    Loaded Login.initLogin


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


renderWhenLoaded : Login.Model -> Html.Html Msg
renderWhenLoaded data =
    div [ class "row login-container" ]
        [ div [ class "col-md-12" ]
            [ brandView ]
        , div [ class "col-md-12" ]
            [ renderView data
            ]
        ]


renderView : Login.Model -> Html.Html Msg
renderView model =
    div [ class "row" ]
        [ div [ class "col-md-4" ] []
        , div [ class "col-md-4" ]
            [ form [ onSubmit FetchCred ]
                [ renderField "text" "email" model.email "alpha@code-arbeitet.com" True Email
                , renderField "password" "password" model.password "" True Password
                , renderSubmitBtn False (Login.isValid model) "Login" "btn btn-danger" True
                ]
            ]
        , div [ class "col-md-4" ] []
        ]


brandView : Html.Html msg
brandView =
    div [ class "row" ]
        [ div [ class "col-md-4" ] []
        , div [ class "col-md-4" ]
            [ div [ class "brand" ]
                [ Html.text "Apollo"
                ]
            ]
        , div [ class "col-md-4" ] []
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
            Loaded <| Login.modifyEmail email data

        Error ->
            Error


passwordChange : String -> Model -> Model
passwordChange password model =
    case model of
        Loading ->
            Loading

        Loaded data ->
            Loaded <| Login.modifyPassword password data

        Error ->
            Error


fetch : Model -> Cmd Msg
fetch model =
    case model of
        Loading ->
            Cmd.none

        Loaded data ->
            Cmd.batch [ Ports.sendToJs (Ports.FetchUser data) ]

        Error ->
            Cmd.none
