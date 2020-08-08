module Page.ShowNationalAnalysis exposing (Model, Msg(..), decode, default, update, view)

import Data.NationalAnalysis as NationalAnalysis
import Data.Party as Party
import Html exposing (button, div, form, input, label, option, select, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class, placeholder, readonly, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Events.Extra exposing (onChange)
import Json.Decode as Decode
import Page.ShowConstituencies exposing (Msg(..))


type Msg
    = FetchNationalAnalysis String
    | AddNationalAnalysis
    | ShowDetail NationalAnalysis.Model
    | NationalAnalysisReceived NationalAnalysisData
    | AddOne NationalAnalysis.Model
    | Form Field
    | Save
    | DetailMode ShowDetailMode
    | OnPartyChange String
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
                        renderNewDetails model
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
            ( { model | nationalAnalysis = addToNationalAnalysis nationalAnalysis model.nationalAnalysis }, Cmd.none )

        Form field ->
            ( model, Cmd.none )

        Save ->
            ( model, Cmd.none )

        DetailMode mode ->
            ( showDetailState mode model, Cmd.none )

        OnPartyChange val ->
            ( model, Cmd.none )

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
    div []
        [ div [ class "col-md-12 spacing-bottom" ]
            [ div [ class "pull-right edit-style", onClick OnEdit ] [ Html.text "edit" ]
            ]
        , form [ onSubmit Save ]
            [ renderField "party" model.party.name "eg.XXX" False Party
            , renderField "votes" model.votes "e.g 23009" False Votes
            , renderField "type" model.candidateType "e.g X" False CandidateType
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
        , renderField "type" model.candidateType "e.g X" True CandidateType
        , renderField "percentage" model.percentage "e.g 45.4" True Percentage
        , renderField "angle" model.angle "e.g 180" True Angle
        , renderField "bar" model.bar "e.g 234" True Bar
        ]


renderNewDetails : Model -> Html.Html Msg
renderNewDetails model =
    form [ onSubmit Save ]
        [ renderParties "party" model.parties
        , renderField "votes" "" "e.g 23009" True Votes
        , renderField "type" "" "e.g X" True CandidateType
        , renderField "percentage" "" "e.g 45.4" True Percentage
        , renderField "angle" "" "e.g 180" True Angle
        , renderField "bar" "" "e.g 234" True Bar
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
    }
