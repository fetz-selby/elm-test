module Page.ShowRegionalAnalysis exposing (Model, Msg(..), decode, default, renderField, update, view)

import Data.Party as Party
import Data.Region as Region
import Data.RegionalAnalysis as RegionalAnalysis
import Html exposing (button, div, form, input, label, option, select, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class, placeholder, readonly, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Events.Extra exposing (onChange)
import Json.Decode as Decode
import Page.ShowConstituencies exposing (Msg(..))


type Msg
    = FetchRegionalAnalysis String
    | AddRegionalAnalysis
    | ShowDetail RegionalAnalysis.Model
    | RegionalAnalysisReceived RegionalAnalysisData
    | Form Field
    | Save
    | DetailMode ShowDetailMode
    | OnPartyChange String
    | OnRegionChange String
    | OnEdit


type Field
    = Region String
    | Votes String
    | CandidateType String
    | Percentage String
    | Angle String
    | Bar String
    | Party String
    | Status String


type ShowDetailMode
    = View
    | Edit
    | New


type alias RegionalAnalysisData =
    { regionalAnalysis : List RegionalAnalysis.Model
    , regions : List Region.Model
    , parties : List Party.Model
    }


type alias Model =
    { regionalAnalysis : List RegionalAnalysis.Model
    , regions : List Region.Model
    , parties : List Party.Model
    , year : String
    , selectedRegionalAnalysis : RegionalAnalysis.Model
    , showDetailMode : ShowDetailMode
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
                [ case model.showDetailMode of
                    View ->
                        renderDetails model.selectedRegionalAnalysis

                    Edit ->
                        renderEditableDetails model.selectedRegionalAnalysis

                    New ->
                        renderNewDetails model
                ]
            ]
        ]


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchRegionalAnalysis year ->
            ( model, Cmd.none )

        AddRegionalAnalysis ->
            ( { model | showDetailMode = New }, Cmd.none )

        ShowDetail regionalAnalysis ->
            ( { model | showDetailMode = View, selectedRegionalAnalysis = regionalAnalysis }, Cmd.none )

        RegionalAnalysisReceived regionalAnalysisData ->
            ( { model
                | regionalAnalysis = regionalAnalysisData.regionalAnalysis
                , regions = regionalAnalysisData.regions
                , parties = regionalAnalysisData.parties
              }
            , Cmd.none
            )

        Form field ->
            ( model, Cmd.none )

        Save ->
            ( model, Cmd.none )

        DetailMode mode ->
            ( showDetailState mode model, Cmd.none )

        OnRegionChange val ->
            ( model, Cmd.none )

        OnPartyChange val ->
            ( model, Cmd.none )

        OnEdit ->
            ( { model | showDetailMode = Edit }, Cmd.none )


renderHeader : Html.Html Msg
renderHeader =
    div [ class "row spacing" ]
        [ div [ class "col-md-9" ]
            [ input [ class "search-input" ] []
            ]
        , div [ class "col-md-3" ]
            [ button [ class "btn btn-primary new-button", onClick AddRegionalAnalysis ] [ Html.text "New" ]
            ]
        ]


renderRegions : String -> List Region.Model -> Html.Html Msg
renderRegions fieldLabel regionList =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , select
            [ class "form-control"
            , onChange OnRegionChange
            ]
            (List.map regionItem regionList)
        ]


regionItem : Region.Model -> Html.Html msg
regionItem item =
    option [ value item.id ] [ Html.text item.name ]


renderParties : String -> List Party.Model -> Html.Html Msg
renderParties fieldLabel partyList =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , select
            [ class "form-control"
            , onChange OnPartyChange
            ]
            (List.map partyItem partyList)
        ]


partyItem : Party.Model -> Html.Html msg
partyItem item =
    option [ value item.id ] [ Html.text item.name ]


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
    div []
        [ div [ class "col-md-12 spacing-bottom" ]
            [ div [ class "pull-right edit-style", onClick OnEdit ] [ Html.text "edit" ]
            ]
        , form [ onSubmit Save ]
            [ renderField "region" model.region.name "eg.Ashanti" False Region
            , renderField "type" model.candidateType "e.g P" False CandidateType
            , renderField "votes" (String.fromInt model.votes) "e.g 1002" False Votes
            , renderField "party" model.party.name "e.g XXX" False Party
            , renderField "percentage" (String.fromFloat model.percentage) "e.g 45.4" False Percentage
            , renderField "angle" (String.fromFloat model.angle) "e.g 180" False Angle
            , renderField "bar" (String.fromFloat model.bar) "e.g 234" False Bar
            , renderField "status" model.status "e.g A/D" False Status
            ]
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


renderNewDetails : Model -> Html.Html Msg
renderNewDetails model =
    form [ onSubmit Save ]
        [ renderRegions "region" model.regions
        , renderParties "party" model.parties
        , renderField "type" "" "e.g P" True CandidateType
        , renderField "votes" "" "e.g 1002" True Votes
        , renderField "percentage" "" "e.g 45.4" True Percentage
        , renderField "angle" "" "e.g 180" True Angle
        , renderField "bar" "" "e.g 234" True Bar
        , renderField "status" "" "e.g A/D" True Status
        ]


showDetailState : ShowDetailMode -> Model -> Model
showDetailState mode model =
    case mode of
        View ->
            { model | showDetailMode = View }

        Edit ->
            { model | showDetailMode = Edit }

        New ->
            { model | showDetailMode = New, selectedRegionalAnalysis = RegionalAnalysis.initRegionalAnalysis }


decode : Decode.Decoder RegionalAnalysisData
decode =
    Decode.field "regionalAnalysisData" (Decode.map3 RegionalAnalysisData RegionalAnalysis.decodeList Region.decodeList Party.decodeList)


default : Model
default =
    { regionalAnalysis = []
    , regions = []
    , parties = []
    , year = ""
    , selectedRegionalAnalysis = RegionalAnalysis.initRegionalAnalysis
    , showDetailMode = View
    }
