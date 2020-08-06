module Page.ShowParties exposing (Model, Msg(..), decode, default, update, view)

import Data.Party as Party
import Html exposing (button, div, form, input, label, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class, placeholder, readonly, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Json.Decode as Decode


type Msg
    = FetchParties String
    | AddParty
    | ShowDetail Party.Model
    | PartiesReceived PartyData
    | AddOne Party.Model
    | Form Field
    | Save
    | DetailMode ShowDetailMode
    | OnEdit
    | SearchList String


type Field
    = Party String
    | Color String
    | LogoPath String
    | OrderQueue String


type ShowDetailMode
    = View
    | Edit
    | New


type alias PartyData =
    { parties : List Party.Model
    }


type alias Model =
    { parties : List Party.Model
    , searchWord : String
    , year : String
    , selectedParty : Party.Model
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
                    renderPartyList (Party.filter model.searchWord model.parties)

                  else
                    renderPartyList model.parties
                ]
            , div [ class "col-md-4" ]
                [ case model.showDetailMode of
                    View ->
                        renderDetails model.selectedParty

                    Edit ->
                        renderEditableDetails model.selectedParty

                    New ->
                        renderNewDetails
                ]
            ]
        ]


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchParties year ->
            ( model, Cmd.none )

        AddParty ->
            ( { model | showDetailMode = New }, Cmd.none )

        ShowDetail party ->
            ( { model | showDetailMode = View, selectedParty = party }, Cmd.none )

        PartiesReceived partyData ->
            ( { model | parties = partyData.parties }, Cmd.none )

        AddOne party ->
            ( { model | parties = addToParties party model.parties }, Cmd.none )

        Form field ->
            ( model, Cmd.none )

        Save ->
            ( model, Cmd.none )

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
            [ button [ class "btn btn-primary new-button", onClick AddParty ] [ Html.text "New" ]
            ]
        ]


renderPartyList : List Party.Model -> Html.Html Msg
renderPartyList parties =
    table [ class "table table-striped table table-hover" ]
        [ thead []
            [ renderPartyHeader ]
        , tbody [] (List.map renderPartyItem parties)
        ]


renderPartyHeader : Html.Html Msg
renderPartyHeader =
    tr []
        [ th [] [ Html.text "Party" ]
        , th [] [ Html.text "Type" ]
        , th [] [ Html.text "Votes" ]
        ]


renderPartyItem : Party.Model -> Html.Html Msg
renderPartyItem party =
    tr [ onClick (ShowDetail party) ]
        [ td [] [ Html.text party.name ]
        , td [] [ Html.text party.color ]
        , td [] [ Html.text party.logoPath ]
        , td [] [ Html.text party.orderQueue ]
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


renderDetails : Party.Model -> Html.Html Msg
renderDetails model =
    div []
        [ div [ class "col-md-12 spacing-bottom" ]
            [ div [ class "pull-right edit-style", onClick OnEdit ] [ Html.text "edit" ]
            ]
        , form [ onSubmit Save ]
            [ renderField "party" model.name "eg.XXX" False Party
            , renderField "color" model.color "e.g P" False Color
            , renderField "logo path" model.logoPath "e.g #F33e345" False LogoPath
            , renderField "order queue" model.orderQueue "e.g 12" False OrderQueue
            ]
        ]


renderEditableDetails : Party.Model -> Html.Html Msg
renderEditableDetails model =
    form [ onSubmit Save ]
        [ renderField "party" model.name "eg.XXX" True Party
        , renderField "color" model.color "e.g P" True Color
        , renderField "logo path" model.logoPath "e.g #F33e345" True LogoPath
        , renderField "order queue" model.orderQueue "e.g 12" True OrderQueue
        ]


renderNewDetails : Html.Html Msg
renderNewDetails =
    form [ onSubmit Save ]
        [ renderField "party" "" "eg.XXX" True Party
        , renderField "color" "" "e.g P" True Color
        , renderField "logo path" "" "e.g #F33e345" True LogoPath
        , renderField "order queue" "" "e.g 12" True OrderQueue
        ]


showDetailState : ShowDetailMode -> Model -> Model
showDetailState mode model =
    case mode of
        View ->
            { model | showDetailMode = View }

        Edit ->
            { model | showDetailMode = Edit }

        New ->
            { model | showDetailMode = New, selectedParty = Party.initParty }


addToParties : Party.Model -> List Party.Model -> List Party.Model
addToParties party list =
    party :: list


decode : Decode.Decoder PartyData
decode =
    Decode.field "partyData" (Decode.map PartyData Party.decodeList)


default : Model
default =
    { parties = []
    , searchWord = ""
    , year = ""
    , selectedParty = Party.initParty
    , showDetailMode = View
    }
