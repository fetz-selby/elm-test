module Page.ShowRegionalAnalysis exposing (Model, Msg(..), decode, default, renderField, update, view)

import Data.Party as Party
import Data.Region as Region
import Data.RegionalAnalysis as RegionalAnalysis
import Html exposing (button, div, form, input, label, option, select, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class, classList, disabled, placeholder, readonly, type_, value)
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
    | UpdateOne RegionalAnalysis.Model
    | Form Field
    | Save
    | Update
    | DetailMode ShowDetailMode
    | OnEdit
    | SearchList String


type Field
    = Region String
    | Id String
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
    , isLoading : Bool
    }


view : Model -> Html.Html Msg
view model =
    div
        []
        [ if String.length model.searchWord > 0 then
            renderHeader <| String.fromInt <| List.length <| RegionalAnalysis.filter model.searchWord model.regionalAnalysis

          else
            renderHeader <| String.fromInt <| List.length <| model.regionalAnalysis
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
                        renderEditableDetails model

                    New ->
                        renderNewDetails model
                ]
            ]
        ]


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchRegionalAnalysis _ ->
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
            ( { model
                | regionalAnalysis = addToRegionalAnalysis regionalAnalysis model.regionalAnalysis
                , isLoading = False
                , showDetailMode = View
              }
            , Cmd.none
            )

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

                Id _ ->
                    ( model, Cmd.none )

        Save ->
            ( { model | isLoading = True }, Cmd.batch [ Ports.sendToJs (Ports.SaveRegionSummary model.selectedRegionalAnalysis) ] )

        DetailMode mode ->
            ( showDetailState mode model, Cmd.none )

        OnEdit ->
            ( { model | showDetailMode = Edit }, Cmd.none )

        SearchList val ->
            ( { model | searchWord = val }, Cmd.none )

        Update ->
            ( { model | isLoading = True }, Ports.sendToJs (Ports.UpdateRegionalSummary model.selectedRegionalAnalysis) )

        UpdateOne regionalAnalysis ->
            ( { model
                | isLoading = False
                , regionalAnalysis = RegionalAnalysis.replace regionalAnalysis model.regionalAnalysis
                , showDetailMode = View
              }
            , Cmd.none
            )


renderHeader : String -> Html.Html Msg
renderHeader result =
    div [ class "row spacing" ]
        [ div [ class "col-md-7" ]
            [ input [ class "search-input", placeholder "Type to search", onInput SearchList ] []
            ]
        , div [ class "col-md-2 result" ]
            [ div [ class "row" ] [ Html.text result ]
            , div [ class "row label" ] [ Html.text "counts" ]
            ]
        , div [ class "col-md-3" ]
            [ button [ class "btn btn-primary new-button", onClick AddRegionalAnalysis ] [ Html.text "New" ]
            ]
        ]


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
        [ th [] [ Html.text "Party" ]
        , th [] [ Html.text "Type" ]
        , th [] [ Html.text "Total Votes" ]
        ]


renderRegionalItem : RegionalAnalysis.Model -> Html.Html Msg
renderRegionalItem regional =
    tr [ onClick (ShowDetail regional) ]
        [ td [] [ Html.text regional.party.name ]
        , td [] [ Html.text regional.candidateType ]
        , td [] [ Html.text regional.votes ]
        ]


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


renderDetails : RegionalAnalysis.Model -> Html.Html Msg
renderDetails model =
    div []
        [ div [ class "col-md-12 spacing-bottom" ]
            [ div [ class "pull-right edit-style", onClick OnEdit ] [ Html.text "edit" ]
            ]
        , form [ onSubmit Save ]
            [ renderField "text" "id" model.id "eg. 123" False Id
            , renderField "text" "region" model.region.name "eg.Ashanti" False Region
            , renderField "text" "type" model.candidateType "e.g M/P" False CandidateType
            , renderField "number" "votes" model.votes "e.g 1002" False Votes
            , renderField "text" "party" model.party.name "e.g XXX" False Party
            , renderField "number" "percentage" model.percentage "e.g 45.4" False Percentage
            , renderField "number" "angle" model.angle "e.g 180" False Angle
            , renderField "number" "bar" model.bar "e.g 234" False Bar
            , renderField "text" "status" model.status "e.g A/D" False Status
            ]
        ]


renderEditableDetails : Model -> Html.Html Msg
renderEditableDetails model =
    form [ onSubmit Update ]
        [ renderField "text" "id" model.selectedRegionalAnalysis.id "eg. 123" False Id
        , renderParties "party" Party (Party.addIfNotExist Party.getFirstSelect model.parties)
        , renderGenericList "type" CandidateType getTypeList
        , renderField "text" "votes" model.selectedRegionalAnalysis.votes "e.g 1002" True Votes
        , renderField "text" "percentage" model.selectedRegionalAnalysis.percentage "e.g 45.4" True Percentage
        , renderField "text" "angle" model.selectedRegionalAnalysis.angle "e.g 180" True Angle
        , renderField "text" "bar" model.selectedRegionalAnalysis.bar "e.g 234" True Bar
        , renderSubmitBtn model.isLoading (RegionalAnalysis.isValid model.selectedRegionalAnalysis) "Update" "btn btn-danger" True
        ]


renderNewDetails : Model -> Html.Html Msg
renderNewDetails model =
    form [ onSubmit Save ]
        [ renderParties "party" Party (Party.addIfNotExist Party.getFirstSelect model.parties)
        , renderGenericList "type" CandidateType getTypeList
        , renderField "text" "votes" model.selectedRegionalAnalysis.votes "e.g 1002" True Votes
        , renderField "text" "percentage" model.selectedRegionalAnalysis.percentage "e.g 45.4" True Percentage
        , renderField "text" "angle" model.selectedRegionalAnalysis.angle "e.g 180" True Angle
        , renderField "text" "bar" model.selectedRegionalAnalysis.bar "e.g 234" True Bar
        , renderSubmitBtn model.isLoading (RegionalAnalysis.isValid model.selectedRegionalAnalysis) "Save" "btn btn-danger" True
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
    if RegionalAnalysis.isIdExist regionalAnalysis list then
        list

    else
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
    , isLoading = False
    }
