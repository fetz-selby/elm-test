module Page.ShowNationalAnalysis exposing (Model, Msg(..), decode, default, update, view)

import Data.NationalAnalysis as NationalAnalysis
import Html exposing (button, div, form, input, label, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Json.Decode as Decode


type Msg
    = FetchNationalAnalysis String
    | AddNationalAnalysis
    | ShowDetail NationalAnalysis.Model
    | NationalAnalysisReceived (List NationalAnalysis.Model)
    | Form Field
    | Save


type Field
    = Party String
    | Votes String
    | CandidateType String
    | Percentage String
    | Angle String
    | Bar String


type alias Model =
    { nationalAnalysis : List NationalAnalysis.Model
    , year : String
    , selectedNationalAnalysis : NationalAnalysis.Model
    }


view : Model -> Html.Html Msg
view model =
    div
        []
        [ renderHeader
        , div [ class "row" ]
            [ div [ class "col-md-8" ]
                [ renderNationalList model.nationalAnalysis ]
            , div [ class "col-md-4" ] [ renderDetails model.selectedNationalAnalysis ]
            ]
        ]


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchNationalAnalysis year ->
            ( model, Cmd.none )

        AddNationalAnalysis ->
            ( model, Cmd.none )

        ShowDetail nationalAnalysis ->
            ( { model | selectedNationalAnalysis = nationalAnalysis }, Cmd.none )

        NationalAnalysisReceived nationalAnalysis ->
            ( { model | nationalAnalysis = nationalAnalysis }, Cmd.none )

        Form field ->
            ( model, Cmd.none )

        Save ->
            ( model, Cmd.none )


renderHeader : Html.Html Msg
renderHeader =
    div [ class "row" ]
        [ div [ class "col-md-9" ]
            [ input [] []
            ]
        , div [ class "col-md-offset-3" ]
            [ button [ onClick AddNationalAnalysis ] [ Html.text "Add" ]
            ]
        ]


renderNationalList : List NationalAnalysis.Model -> Html.Html Msg
renderNationalList nationalAnalysis =
    table [ class "table table-striped table table-hover" ]
        [ thead []
            [ renderNationalAnalysisHeader ]
        , tbody [] (List.map renderNationalItem nationalAnalysis)
        ]


renderNationalAnalysisHeader : Html.Html Msg
renderNationalAnalysisHeader =
    tr []
        [ th [] [ Html.text "Party" ]
        , th [] [ Html.text "Type" ]
        , th [] [ Html.text "Votes" ]
        ]


renderNationalItem : NationalAnalysis.Model -> Html.Html Msg
renderNationalItem national =
    tr [ onClick (ShowDetail national) ]
        [ td [] [ Html.text national.party.name ]
        , td [] [ Html.text national.candidateType ]
        , td [] [ Html.text (String.fromInt national.votes) ]
        ]


renderField : String -> String -> String -> (String -> Field) -> Html.Html Msg
renderField fieldLabel fieldValue fieldPlaceholder field =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , input [ class "form-control", type_ "text", value fieldValue, placeholder fieldPlaceholder, onInput (Form << field) ] []
        ]


renderDetails : NationalAnalysis.Model -> Html.Html Msg
renderDetails model =
    form [ onSubmit Save ]
        [ renderField "party" model.party.name "eg.XXX" Party
        , renderField "votes" (String.fromInt model.votes) "e.g 23009" Votes
        , renderField "type" model.candidateType "e.g X" CandidateType
        , renderField "percentage" (String.fromFloat model.percentage) "e.g 45.4" Percentage
        , renderField "angle" (String.fromFloat model.angle) "e.g 180" Angle
        , renderField "bar" (String.fromFloat model.bar) "e.g 234" Bar
        ]


decode : Decode.Decoder (List NationalAnalysis.Model)
decode =
    Decode.field "nationalAnalysis" (Decode.list NationalAnalysis.decode)


default : Model
default =
    { nationalAnalysis = [], year = "", selectedNationalAnalysis = NationalAnalysis.initNationalAnalysis }
