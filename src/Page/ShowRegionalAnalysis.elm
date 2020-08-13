module Page.ShowRegionalAnalysis exposing (Model, Msg(..), decode, default, renderField, update, view)

import Data.Party as Party
import Data.Region as Region
import Data.RegionalAnalysis as RegionalAnalysis
import Html exposing (button, div, form, input, label, option, select, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class, classList, placeholder, readonly, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Events.Extra exposing (onChange)
import Json.Decode as Decode
import Ports


type Msg
    = FetchRegionalAnalysis String
    | AddRegionalAnalysis
    | ShowDetail RegionalAnalysis.Model
    | RegionalAnalysisReceived RegionalAnalysisData
    | AddOne RegionalAnalysis.Model
    | Form Field
    | Save
    | DetailMode ShowDetailMode
    | OnEdit
    | SearchList String


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
    , searchWord : String
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
                [ if String.length model.searchWord > 0 then
                    renderRegionalList (RegionalAnalysis.filter model.searchWord model.regionalAnalysis)

                  else
                    renderRegionalList model.regionalAnalysis
                ]
            , div [ class "col-md-4" ]
                [ case model.showDetailMode of
                    View ->
                        renderDetails model.selectedRegionalAnalysis

                    Edit ->
                        renderEditableDetails model.selectedRegionalAnalysis

                    New ->
                        renderNewDetails model model.selectedRegionalAnalysis
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

        AddOne regionalAnalysis ->
            ( { model | regionalAnalysis = addToRegionalAnalysis regionalAnalysis model.regionalAnalysis }, Cmd.none )

        Form field ->
            case field of
                Region regionId ->
                    ( { model | selectedRegionalAnalysis = RegionalAnalysis.setRegion regionId model.selectedRegionalAnalysis }, Cmd.none )

                Votes votes ->
                    ( { model | selectedRegionalAnalysis = RegionalAnalysis.setVotes votes model.selectedRegionalAnalysis }, Cmd.none )

                CandidateType candidateType ->
                    ( { model | selectedRegionalAnalysis = RegionalAnalysis.setCandidateType candidateType model.selectedRegionalAnalysis }, Cmd.none )

                Percentage percentage ->
                    ( { model | selectedRegionalAnalysis = RegionalAnalysis.setPercentage percentage model.selectedRegionalAnalysis }, Cmd.none )

                Angle angle ->
                    ( { model | selectedRegionalAnalysis = RegionalAnalysis.setAngle angle model.selectedRegionalAnalysis }, Cmd.none )

                Bar bar ->
                    ( { model | selectedRegionalAnalysis = RegionalAnalysis.setBar bar model.selectedRegionalAnalysis }, Cmd.none )

                Party partyId ->
                    ( { model | selectedRegionalAnalysis = RegionalAnalysis.setParty partyId model.selectedRegionalAnalysis }, Cmd.none )

                Status status ->
                    ( { model | selectedRegionalAnalysis = RegionalAnalysis.setStatus status model.selectedRegionalAnalysis }, Cmd.none )

        Save ->
            ( model, Cmd.batch [ Ports.sendToJs (Ports.SaveRegionSummary model.selectedRegionalAnalysis) ] )

        DetailMode mode ->
            ( showDetailState mode model, Cmd.none )

        OnEdit ->
            ( { model | showDetailMode = Edit }, Cmd.none )

        SearchList val ->
            ( { model | searchWord = val }, Cmd.none )


renderHeader : Html.Html Msg
renderHeader =
    div [ class "row spacing" ]
        [ div [ class "col-md-9" ]
            [ input [ class "search-input", placeholder "Type to search", onInput SearchList ] []
            ]
        , div [ class "col-md-3" ]
            [ button [ class "btn btn-primary new-button", onClick AddRegionalAnalysis ] [ Html.text "New" ]
            ]
        ]


renderRegions : String -> (String -> Field) -> List Region.Model -> Html.Html Msg
renderRegions fieldLabel field regionList =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , select
            [ class "form-control"
            , onChange (Form << field)
            ]
            (List.map regionItem regionList)
        ]


regionItem : Region.Model -> Html.Html msg
regionItem item =
    option [ value item.id ] [ Html.text item.name ]


renderParties : String -> (String -> Field) -> List Party.Model -> Html.Html Msg
renderParties fieldLabel field partyList =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , select
            [ class "form-control"
            , onChange (Form << field)
            ]
            (List.map partyItem partyList)
        ]


partyItem : Party.Model -> Html.Html msg
partyItem item =
    option [ value item.id ] [ Html.text item.name ]


renderGenericList : String -> (String -> Field) -> List { id : String, name : String } -> Html.Html Msg
renderGenericList fieldLabel field itemsList =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , select
            [ class "form-control"
            , onChange (Form << field)
            ]
            (List.map genericItem itemsList)
        ]


genericItem : { id : String, name : String } -> Html.Html msg
genericItem item =
    option [ value item.id ] [ Html.text item.name ]


getTypeList : List { id : String, name : String }
getTypeList =
    [ { id = "0", name = "Select" }, { id = "M", name = "Parliamentary" }, { id = "P", name = "Presidential" } ]


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
        , td [] [ Html.text regional.votes ]
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


renderSubmitBtn : String -> String -> Bool -> Html.Html Msg
renderSubmitBtn label className isCustom =
    div [ class "form-group" ]
        [ button [ type_ "submit", classList [ ( className, True ), ( "btn-extra", isCustom ) ] ] [ Html.text label ]
        ]


renderDetails : RegionalAnalysis.Model -> Html.Html Msg
renderDetails model =
    div []
        [ div [ class "col-md-12 spacing-bottom" ]
            [ div [ class "pull-right edit-style", onClick OnEdit ] [ Html.text "edit" ]
            ]
        , form [ onSubmit Save ]
            [ renderField "region" model.region.name "eg.Ashanti" False Region
            , renderField "type" model.candidateType "e.g M/P" False CandidateType
            , renderField "votes" model.votes "e.g 1002" False Votes
            , renderField "party" model.party.name "e.g XXX" False Party
            , renderField "percentage" model.percentage "e.g 45.4" False Percentage
            , renderField "angle" model.angle "e.g 180" False Angle
            , renderField "bar" model.bar "e.g 234" False Bar
            , renderField "status" model.status "e.g A/D" False Status
            ]
        ]


renderEditableDetails : RegionalAnalysis.Model -> Html.Html Msg
renderEditableDetails model =
    form [ onSubmit Save ]
        [ renderField "region" model.region.name "eg.Ashanti" True Region
        , renderField "type" model.candidateType "e.g M/P" True CandidateType
        , renderField "votes" model.votes "e.g 1002" True Votes
        , renderField "party" model.party.name "e.g XXX" True Party
        , renderField "percentage" model.percentage "e.g 45.4" True Percentage
        , renderField "angle" model.angle "e.g 180" True Angle
        , renderField "bar" model.bar "e.g 234" True Bar
        ]


renderNewDetails : Model -> RegionalAnalysis.Model -> Html.Html Msg
renderNewDetails model selectedRegionalAnalysis =
    form [ onSubmit Save ]
        [ renderRegions "region" Region model.regions
        , renderParties "party" Party model.parties
        , renderGenericList "type" CandidateType getTypeList
        , renderField "votes" selectedRegionalAnalysis.votes "e.g 1002" True Votes
        , renderField "percentage" selectedRegionalAnalysis.percentage "e.g 45.4" True Percentage
        , renderField "angle" selectedRegionalAnalysis.angle "e.g 180" True Angle
        , renderField "bar" selectedRegionalAnalysis.bar "e.g 234" True Bar
        , renderSubmitBtn "Save" "btn btn-danger" True
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


addToRegionalAnalysis : RegionalAnalysis.Model -> List RegionalAnalysis.Model -> List RegionalAnalysis.Model
addToRegionalAnalysis regionalAnalysis list =
    regionalAnalysis :: list


decode : Decode.Decoder RegionalAnalysisData
decode =
    Decode.field "regionalAnalysisData" (Decode.map3 RegionalAnalysisData RegionalAnalysis.decodeList Region.decodeList Party.decodeList)


default : Model
default =
    { regionalAnalysis = []
    , regions = []
    , parties = []
    , searchWord = ""
    , year = ""
    , selectedRegionalAnalysis = RegionalAnalysis.initRegionalAnalysis
    , showDetailMode = View
    }
