module Page.ShowRegionalAnalysis exposing (Model, Msg(..), decode, default, renderField, update, view)

import Data.RegionalAnalysis as RegionalAnalysis
import Html exposing (button, div, form, input, label, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class, placeholder, readonly, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Json.Decode as Decode


type Msg
    = FetchRegionalAnalysis String
    | AddRegionalAnalysis
    | ShowDetail RegionalAnalysis.Model
    | RegionalAnalysisReceived (List RegionalAnalysis.Model)
    | Form Field
    | Save


type Field
    = Region String
    | Votes String
    | CandidateType String
    | Percentage String
    | Angle String
    | Bar String
    | Party String
    | Status String


type alias Model =
    { regionalAnalysis : List RegionalAnalysis.Model
    , year : String
    , selectedRegionalAnalysis : RegionalAnalysis.Model
    , isEditableMode : Bool
    }


view : Model -> Html.Html Msg
view model =
    div
        []
        [ renderHeader
        , div [ class "row" ]
            [ div [ class "col-md-8" ]
                [ renderRegionalList model.regionalAnalysis
                ]
            , div [ class "col-md-4" ]
                [ if model.isEditableMode then
                    renderEditableDetails model.selectedRegionalAnalysis

                  else
                    renderDetails model.selectedRegionalAnalysis
                ]
            ]
        ]


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchRegionalAnalysis year ->
            ( model, Cmd.none )

        AddRegionalAnalysis ->
            ( model, Cmd.none )

        ShowDetail regionalAnalysis ->
            ( { model | selectedRegionalAnalysis = regionalAnalysis }, Cmd.none )

        RegionalAnalysisReceived regionalAnalysis ->
            ( { model | regionalAnalysis = regionalAnalysis }, Cmd.none )

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
            [ button [ onClick AddRegionalAnalysis ] [ Html.text "Add" ]
            ]
        ]


renderRegionalList : List RegionalAnalysis.Model -> Html.Html Msg
renderRegionalList regionalAnalysis =
    table [ class "table table-striped table table-hover" ]
        [ thead [] [ renderRegionAnalysisHeader ]
        , tbody [] (List.map renderRegionalItem regionalAnalysis)
        ]


renderRegionAnalysisHeader : Html.Html Msg
renderRegionAnalysisHeader =
    tr []
        [ th [] [ Html.text "Region" ]
        , th [] [ Html.text "Party" ]
        , th [] [ Html.text "Type" ]
        , th [] [ Html.text "Total Votes" ]
        ]


renderRegionalItem : RegionalAnalysis.Model -> Html.Html Msg
renderRegionalItem regional =
    tr [ onClick (ShowDetail regional) ]
        [ td [] [ Html.text regional.region.name ]
        , td [] [ Html.text regional.party.name ]
        , td [] [ Html.text regional.candidateType ]
        , td [] [ Html.text (String.fromInt regional.votes) ]
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


renderDetails : RegionalAnalysis.Model -> Html.Html Msg
renderDetails model =
    form [ onSubmit Save ]
        [ renderField "region" model.region.name "eg.Ashanti" False Region
        , renderField "type" model.candidateType "e.g P" False CandidateType
        , renderField "votes" (String.fromInt model.votes) "e.g 1002" False Votes
        , renderField "party" model.party.name "e.g XXX" False Party
        , renderField "percentage" (String.fromFloat model.percentage) "e.g 45.4" False Percentage
        , renderField "angle" (String.fromFloat model.angle) "e.g 180" False Angle
        , renderField "bar" (String.fromFloat model.bar) "e.g 234" False Bar
        , renderField "status" model.status "e.g A/D" False Status
        ]


renderEditableDetails : RegionalAnalysis.Model -> Html.Html Msg
renderEditableDetails model =
    form [ onSubmit Save ]
        [ renderField "region" model.region.name "eg.Ashanti" True Region
        , renderField "type" model.candidateType "e.g P" True CandidateType
        , renderField "votes" (String.fromInt model.votes) "e.g 1002" True Votes
        , renderField "party" model.party.name "e.g XXX" True Party
        , renderField "percentage" (String.fromFloat model.percentage) "e.g 45.4" True Percentage
        , renderField "angle" (String.fromFloat model.angle) "e.g 180" True Angle
        , renderField "bar" (String.fromFloat model.bar) "e.g 234" True Bar
        , renderField "status" model.status "e.g A/D" True Status
        ]


decode : Decode.Decoder (List RegionalAnalysis.Model)
decode =
    Decode.field "regionalAnalysis" (Decode.list RegionalAnalysis.decode)


default : Model
default =
    { regionalAnalysis = [], year = "", selectedRegionalAnalysis = RegionalAnalysis.initRegionalAnalysis, isEditableMode = False }
