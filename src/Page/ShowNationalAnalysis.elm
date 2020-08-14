module Page.ShowNationalAnalysis exposing (Model, Msg(..), decode, default, update, view)

import Data.NationalAnalysis as NationalAnalysis
import Data.Party as Party
import Html exposing (button, div, form, input, label, option, select, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class, classList, disabled, placeholder, readonly, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Events.Extra exposing (onChange)
import Json.Decode as Decode
import Ports


type Msg
    = FetchNationalAnalysis String
    | AddNationalAnalysis
    | ShowDetail NationalAnalysis.Model
    | NationalAnalysisReceived NationalAnalysisData
    | AddOne NationalAnalysis.Model
    | Form Field
    | Save
    | DetailMode ShowDetailMode
    | OnEdit
    | SearchList String


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


type alias NationalAnalysisData =
    { nationalAnalysis : List NationalAnalysis.Model
    , parties : List Party.Model
    }


type alias Model =
    { nationalAnalysis : List NationalAnalysis.Model
    , parties : List Party.Model
    , searchWord : String
    , year : String
    , selectedNationalAnalysis : NationalAnalysis.Model
    , showDetailMode : ShowDetailMode
    , isLoading : Bool
    }


view : Model -> Html.Html Msg
view model =
    div
        []
        [ renderHeader
        , div [ class "row" ]
            [ div [ class "col-md-8" ]
                [ if String.length model.searchWord > 0 then
                    renderNationalList (NationalAnalysis.filter model.searchWord model.nationalAnalysis)

                  else
                    renderNationalList model.nationalAnalysis
                ]
            , div [ class "col-md-4" ]
                [ case model.showDetailMode of
                    View ->
                        renderDetails model.selectedNationalAnalysis

                    Edit ->
                        renderEditableDetails model.selectedNationalAnalysis

                    New ->
                        renderNewDetails model model.selectedNationalAnalysis
                ]
            ]
        ]


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchNationalAnalysis year ->
            ( model, Cmd.none )

        AddNationalAnalysis ->
            ( { model | showDetailMode = New }, Cmd.none )

        ShowDetail nationalAnalysis ->
            ( { model | showDetailMode = View, selectedNationalAnalysis = nationalAnalysis }, Cmd.none )

        NationalAnalysisReceived nationalAnalysisData ->
            ( { model
                | nationalAnalysis = nationalAnalysisData.nationalAnalysis
                , parties = nationalAnalysisData.parties
              }
            , Cmd.none
            )

        AddOne nationalAnalysis ->
            ( { model
                | nationalAnalysis = addToNationalAnalysis nationalAnalysis model.nationalAnalysis
                , isLoading = False
                , showDetailMode = View
              }
            , Cmd.none
            )

        Form field ->
            case field of
                Party partyId ->
                    ( { model | selectedNationalAnalysis = NationalAnalysis.setPartyId partyId model.selectedNationalAnalysis }, Cmd.none )

                Votes votes ->
                    ( { model | selectedNationalAnalysis = NationalAnalysis.setVotes votes model.selectedNationalAnalysis }, Cmd.none )

                CandidateType candidateType ->
                    ( { model | selectedNationalAnalysis = NationalAnalysis.setCandidateType candidateType model.selectedNationalAnalysis }, Cmd.none )

                Percentage percentage ->
                    ( { model | selectedNationalAnalysis = NationalAnalysis.setPercentage percentage model.selectedNationalAnalysis }, Cmd.none )

                Angle angle ->
                    ( { model | selectedNationalAnalysis = NationalAnalysis.setAngle angle model.selectedNationalAnalysis }, Cmd.none )

                Bar bar ->
                    ( { model | selectedNationalAnalysis = NationalAnalysis.setBar bar model.selectedNationalAnalysis }, Cmd.none )

        Save ->
            ( { model | isLoading = True }, Cmd.batch [ Ports.sendToJs (Ports.SaveNationalSummary model.selectedNationalAnalysis) ] )

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
            [ button [ class "btn btn-primary new-button", onClick AddNationalAnalysis ] [ Html.text "New" ]
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
        , td [] [ Html.text national.votes ]
        ]


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


renderField : String -> String -> String -> Bool -> (String -> Field) -> Html.Html Msg
renderField fieldLabel fieldValue fieldPlaceholder isEditable field =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , if isEditable then
            input [ class "form-control", type_ "text", value fieldValue, placeholder fieldPlaceholder, onInput (Form << field) ] []

          else
            input [ class "form-control", type_ "text", value fieldValue, placeholder fieldPlaceholder, readonly True ] []
        ]


renderSubmitBtn : Bool -> String -> String -> Bool -> Html.Html Msg
renderSubmitBtn isLoading label className isCustom =
    div [ class "form-group" ]
        [ if isLoading then
            button
                [ type_ "submit"
                , disabled True
                , classList [ ( className, True ), ( "btn-extra", isCustom ) ]
                ]
                [ Html.text "Please wait ..." ]

          else
            button
                [ type_ "submit"
                , classList [ ( className, True ), ( "btn-extra", isCustom ) ]
                ]
                [ Html.text label ]
        ]


renderDetails : NationalAnalysis.Model -> Html.Html Msg
renderDetails model =
    div []
        [ div [ class "col-md-12 spacing-bottom" ]
            [ div [ class "pull-right edit-style", onClick OnEdit ] [ Html.text "edit" ]
            ]
        , form [ onSubmit Save ]
            [ renderField "party" model.party.name "eg.XXX" False Party
            , renderField "votes" model.votes "e.g 23009" False Votes
            , renderField "type" model.candidateType "e.g M/P" False CandidateType
            , renderField "percentage" model.percentage "e.g 45.4" False Percentage
            , renderField "angle" model.angle "e.g 180" False Angle
            , renderField "bar" model.bar "e.g 234" False Bar
            ]
        ]


renderEditableDetails : NationalAnalysis.Model -> Html.Html Msg
renderEditableDetails model =
    form [ onSubmit Save ]
        [ renderField "party" model.party.name "eg.XXX" True Party
        , renderField "votes" model.votes "e.g 23009" True Votes
        , renderField "type" model.candidateType "e.g M/P" True CandidateType
        , renderField "percentage" model.percentage "e.g 45.4" True Percentage
        , renderField "angle" model.angle "e.g 180" True Angle
        , renderField "bar" model.bar "e.g 234" True Bar
        ]


renderNewDetails : Model -> NationalAnalysis.Model -> Html.Html Msg
renderNewDetails model nationalAnalysis =
    form [ onSubmit Save ]
        [ renderParties "party" Party model.parties
        , renderField "votes" nationalAnalysis.votes "e.g 23009" True Votes
        , renderGenericList "type" CandidateType getTypeList
        , renderField "percentage" nationalAnalysis.percentage "e.g 45.4" True Percentage
        , renderField "angle" nationalAnalysis.angle "e.g 180" True Angle
        , renderField "bar" nationalAnalysis.bar "e.g 234" True Bar
        , renderSubmitBtn model.isLoading "Save" "btn btn-danger" True
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


addToNationalAnalysis : NationalAnalysis.Model -> List NationalAnalysis.Model -> List NationalAnalysis.Model
addToNationalAnalysis nationalAnalysis list =
    if NationalAnalysis.isIdExist nationalAnalysis list then
        list

    else
        nationalAnalysis :: list


decode : Decode.Decoder NationalAnalysisData
decode =
    Decode.field "nationalAnalysisData" (Decode.map2 NationalAnalysisData NationalAnalysis.decodeList Party.decodeList)


default : Model
default =
    { nationalAnalysis = []
    , parties = []
    , searchWord = ""
    , year = ""
    , selectedNationalAnalysis = NationalAnalysis.initNationalAnalysis
    , showDetailMode = View
    , isLoading = False
    }
