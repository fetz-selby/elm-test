module Page.ShowNationalAnalysis exposing (Model, Msg(..), decode, default, update, view)

import Data.NationalAnalysis as NationalAnalysis
import Html exposing (button, div, form, input, label, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class, placeholder, readonly, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Json.Decode as Decode


type Msg
    = FetchNationalAnalysis String
    | AddNationalAnalysis
    | ShowDetail NationalAnalysis.Model
    | NationalAnalysisReceived (List NationalAnalysis.Model)
    | Form Field
    | Save
    | DetailMode ShowDetailMode


type Field
    = Party String
    | Votes String
    | CandidateType String
    | Percentage String
    | Angle String
    | Bar String


type ShowDetailMode
    = View
    | Edit
    | New


type alias Model =
    { nationalAnalysis : List NationalAnalysis.Model
    , year : String
    , selectedNationalAnalysis : NationalAnalysis.Model
    , showDetailMode : ShowDetailMode
    }


view : Model -> Html.Html Msg
view model =
    div
        []
        [ renderHeader
        , div [ class "row" ]
            [ div [ class "col-md-8" ]
                [ renderNationalList model.nationalAnalysis ]
            , div [ class "col-md-4" ]
                [ case model.showDetailMode of
                    View ->
                        renderDetails model.selectedNationalAnalysis

                    Edit ->
                        renderEditableDetails model.selectedNationalAnalysis

                    New ->
                        div [] []
                ]
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
            ( { model | showDetailMode = View, selectedNationalAnalysis = nationalAnalysis }, Cmd.none )

        NationalAnalysisReceived nationalAnalysis ->
            ( { model | nationalAnalysis = nationalAnalysis }, Cmd.none )

        Form field ->
            ( model, Cmd.none )

        Save ->
            ( model, Cmd.none )

        DetailMode mode ->
            ( showDetailState mode model, Cmd.none )


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


renderField : String -> String -> String -> Bool -> (String -> Field) -> Html.Html Msg
renderField fieldLabel fieldValue fieldPlaceholder isEditable field =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , if isEditable then
            input [ class "form-control", type_ "text", value fieldValue, placeholder fieldPlaceholder, onInput (Form << field) ] []

          else
            input [ class "form-control", type_ "text", value fieldValue, placeholder fieldPlaceholder, readonly True ] []
        ]


renderDetails : NationalAnalysis.Model -> Html.Html Msg
renderDetails model =
    form [ onSubmit Save ]
        [ renderField "party" model.party.name "eg.XXX" False Party
        , renderField "votes" (String.fromInt model.votes) "e.g 23009" False Votes
        , renderField "type" model.candidateType "e.g X" False CandidateType
        , renderField "percentage" (String.fromFloat model.percentage) "e.g 45.4" False Percentage
        , renderField "angle" (String.fromFloat model.angle) "e.g 180" False Angle
        , renderField "bar" (String.fromFloat model.bar) "e.g 234" False Bar
        ]


renderEditableDetails : NationalAnalysis.Model -> Html.Html Msg
renderEditableDetails model =
    form [ onSubmit Save ]
        [ renderField "party" model.party.name "eg.XXX" True Party
        , renderField "votes" (String.fromInt model.votes) "e.g 23009" True Votes
        , renderField "type" model.candidateType "e.g X" True CandidateType
        , renderField "percentage" (String.fromFloat model.percentage) "e.g 45.4" True Percentage
        , renderField "angle" (String.fromFloat model.angle) "e.g 180" True Angle
        , renderField "bar" (String.fromFloat model.bar) "e.g 234" True Bar
        ]


showDetailState : ShowDetailMode -> Model -> Model
showDetailState mode model =
    case mode of
        View ->
            { model | showDetailMode = View }

        Edit ->
            { model | showDetailMode = Edit }

        New ->
            { model | showDetailMode = New, selectedNationalAnalysis = NationalAnalysis.initNationalAnalysis }


decode : Decode.Decoder (List NationalAnalysis.Model)
decode =
    Decode.field "nationalAnalysis" (Decode.list NationalAnalysis.decode)


default : Model
default =
    { nationalAnalysis = [], year = "", selectedNationalAnalysis = NationalAnalysis.initNationalAnalysis, showDetailMode = View }