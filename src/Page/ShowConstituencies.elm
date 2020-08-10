module Page.ShowConstituencies exposing (Model, Msg(..), decode, default, update, view)

import Data.Constituency as Constituency
import Data.ParentConstituency as ParentConstituency
import Data.Party as Party
import Html exposing (button, div, form, input, label, option, select, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class, classList, placeholder, readonly, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Events.Extra exposing (onChange)
import Json.Decode as Decode
import Ports


type Msg
    = FetchConstituencies String
    | AddConstituency
    | ShowDetail Constituency.Model
    | ConstituenciesReceived ConstituencyData
    | AddOne Constituency.Model
    | Form Field
    | Save
    | DetailMode ShowDetailMode
    | OnEdit
    | SearchList String


type Field
    = Constituency String
    | CastedVotes String
    | IsDeclared String
    | ParentId String
    | RegVotes String
    | RejectVotes String
    | SeatWonId String
    | TotalVotes String
    | AutoCompute String


type ShowDetailMode
    = View
    | Edit
    | New


type alias ConstituencyData =
    { constituencies : List Constituency.Model
    , parentConstituencies : List ParentConstituency.Model
    , parties : List Party.Model
    }


type alias Model =
    { constituencies : List Constituency.Model
    , parentConstituencies : List ParentConstituency.Model
    , parties : List Party.Model
    , region : String
    , searchWord : String
    , year : String
    , selectedConstituency : Constituency.Model
    , showDetailMode : ShowDetailMode
    }


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchConstituencies constituencyId ->
            ( model, Cmd.none )

        AddConstituency ->
            ( { model | showDetailMode = New }, Cmd.none )

        ShowDetail constituency ->
            ( { model | showDetailMode = View, selectedConstituency = constituency }, Cmd.none )

        ConstituenciesReceived constituencyData ->
            ( { model
                | constituencies = constituencyData.constituencies
                , parentConstituencies = constituencyData.parentConstituencies
                , parties = constituencyData.parties
              }
            , Cmd.none
            )

        AddOne constituency ->
            ( { model | constituencies = addToConstituencies constituency model.constituencies }, Cmd.none )

        Form field ->
            case field of
                Constituency constituencyName ->
                    ( { model | selectedConstituency = Constituency.setName constituencyName model.selectedConstituency }, Cmd.none )

                CastedVotes castedVotes ->
                    ( { model | selectedConstituency = Constituency.setCastedVotes castedVotes model.selectedConstituency }, Cmd.none )

                IsDeclared isDeclared ->
                    ( { model | selectedConstituency = Constituency.setIsDeclared False model.selectedConstituency }, Cmd.none )

                ParentId parentId ->
                    ( { model | selectedConstituency = Constituency.setParentId parentId model.selectedConstituency }, Cmd.none )

                RegVotes regVotes ->
                    ( { model | selectedConstituency = Constituency.setRegVotes regVotes model.selectedConstituency }, Cmd.none )

                RejectVotes rejectVotes ->
                    ( { model | selectedConstituency = Constituency.setRejectVotes rejectVotes model.selectedConstituency }, Cmd.none )

                SeatWonId seatWonId ->
                    ( { model | selectedConstituency = Constituency.setSeatWonId seatWonId model.selectedConstituency }, Cmd.none )

                TotalVotes totalVotes ->
                    ( { model | selectedConstituency = Constituency.setTotalVotes totalVotes model.selectedConstituency }, Cmd.none )

                AutoCompute autoCompute ->
                    ( { model | selectedConstituency = Constituency.setAutoCompute False model.selectedConstituency }, Cmd.none )

        Save ->
            ( model, Cmd.batch [ Ports.sendToJs (Ports.SaveConstituency model.selectedConstituency) ] )

        DetailMode mode ->
            ( showDetailState mode model, Cmd.none )

        OnEdit ->
            ( { model | showDetailMode = Edit }, Cmd.none )

        SearchList val ->
            ( { model | searchWord = val }, Cmd.none )


view : Model -> Html.Html Msg
view model =
    div
        []
        [ renderHeader
        , div [ class "row" ]
            [ div [ class "col-md-8" ]
                [ if String.length model.searchWord > 0 then
                    renderConstituencyList (Constituency.filter model.searchWord model.constituencies)

                  else
                    renderConstituencyList model.constituencies
                ]
            , div [ class "col-md-4" ]
                [ case model.showDetailMode of
                    View ->
                        renderDetails model.selectedConstituency

                    Edit ->
                        renderEditableDetails model.selectedConstituency

                    New ->
                        renderNewDetails model model.selectedConstituency
                ]
            ]
        ]


renderParentConstituencies : String -> (String -> Field) -> List ParentConstituency.Model -> Html.Html Msg
renderParentConstituencies fieldLabel field parentConstituencyList =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , select
            [ class "form-control"
            , onChange (Form << field)
            ]
            (List.map parentConstituencyItem parentConstituencyList)
        ]


parentConstituencyItem : ParentConstituency.Model -> Html.Html msg
parentConstituencyItem item =
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


renderHeader : Html.Html Msg
renderHeader =
    div [ class "row spacing" ]
        [ div [ class "col-md-9" ]
            [ input [ class "search-input", placeholder "Type to search", onInput SearchList ] []
            ]
        , div [ class "col-md-3" ]
            [ button [ class "btn btn-primary new-button", onClick AddConstituency ] [ Html.text "New" ]
            ]
        ]


renderConstituencyList : List Constituency.Model -> Html.Html Msg
renderConstituencyList constituencies =
    table [ class "table table-striped table table-hover" ]
        [ thead []
            [ renderConstituencyHeader ]
        , tbody [] (List.map renderConstituencyItem constituencies)
        ]


renderConstituencyHeader : Html.Html Msg
renderConstituencyHeader =
    tr []
        [ th [] [ Html.text "Constituency" ]
        , th [] [ Html.text "Seat Won" ]
        , th [] [ Html.text "Total Votes" ]
        ]


renderConstituencyItem : Constituency.Model -> Html.Html Msg
renderConstituencyItem constituency =
    tr [ onClick (ShowDetail constituency) ]
        [ td [] [ Html.text constituency.name ]
        , td [] [ Html.text constituency.seatWonId.name ]
        , td [] [ Html.text constituency.totalVotes ]
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


renderDetails : Constituency.Model -> Html.Html Msg
renderDetails model =
    div []
        [ div [ class "col-md-12 spacing-bottom" ]
            [ div [ class "pull-right edit-style", onClick OnEdit ] [ Html.text "edit" ]
            ]
        , form [ onSubmit Save ]
            [ renderField "constituency" model.name "eg.Bekwai" False Constituency
            , renderField "seat won by" model.seatWonId.name "eg.XXX" False SeatWonId
            , renderField "casted votes" model.castedVotes "e.g P" False CastedVotes
            , renderField "reg votes" model.regVotes "e.g 432" False RegVotes
            , renderField "rejected votes" model.rejectVotes "e.g 180" False RejectVotes
            , renderField "total votes" model.totalVotes "e.g 234" False TotalVotes
            , renderField "is declared"
                (if model.isDeclared then
                    "Yes"

                 else
                    "No"
                )
                "e.g Yes"
                False
                IsDeclared
            , renderField "is declared"
                (if model.autoCompute then
                    "Yes"

                 else
                    "No"
                )
                "e.g No"
                False
                AutoCompute
            ]
        ]


renderEditableDetails : Constituency.Model -> Html.Html Msg
renderEditableDetails model =
    form [ onSubmit Save ]
        [ renderField "constituency" model.name "eg.Bekwai" True Constituency
        , renderField "seat won by" model.seatWonId.name "eg.XXX" True SeatWonId
        , renderField "casted votes" model.castedVotes "e.g P" True CastedVotes
        , renderField "reg votes" model.regVotes "e.g 432" True RegVotes
        , renderField "rejected votes" model.rejectVotes "e.g 180" True RejectVotes
        , renderField "total votes" model.totalVotes "e.g 234" True TotalVotes
        , renderField "is declared"
            (if model.isDeclared then
                "Yes"

             else
                "No"
            )
            "e.g Yes"
            True
            IsDeclared
        , renderField "is declared"
            (if model.autoCompute then
                "Yes"

             else
                "No"
            )
            "e.g No"
            True
            AutoCompute
        , renderField "parent id" model.parent.name "e.g Bantama" True ParentId
        ]


renderNewDetails : Model -> Constituency.Model -> Html.Html Msg
renderNewDetails model constituencyModel =
    form [ onSubmit Save ]
        [ renderParentConstituencies "parent constituency" ParentId model.parentConstituencies
        , renderParties "seat won by" SeatWonId model.parties
        , renderField "constituency" constituencyModel.name "eg.Bekwai" True Constituency
        , renderField "casted votes" constituencyModel.castedVotes "e.g P" True CastedVotes
        , renderField "reg votes" constituencyModel.regVotes "e.g 432" True RegVotes
        , renderField "rejected votes" constituencyModel.rejectVotes "e.g 180" True RejectVotes
        , renderField "total votes" constituencyModel.totalVotes "e.g 234" True TotalVotes
        , renderField "is declared"
            "No"
            "e.g Yes"
            True
            IsDeclared
        , renderField "is autoCompute"
            "No"
            "e.g No"
            True
            AutoCompute
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
            { model | showDetailMode = New, selectedConstituency = Constituency.initConstituency }


addToConstituencies : Constituency.Model -> List Constituency.Model -> List Constituency.Model
addToConstituencies constituency list =
    constituency :: list


decode : Decode.Decoder ConstituencyData
decode =
    Decode.field "constituencyData" (Decode.map3 ConstituencyData Constituency.decodeList ParentConstituency.decodeList Party.decodeList)


default : Model
default =
    { constituencies = []
    , parentConstituencies = []
    , parties = []
    , region = ""
    , searchWord = ""
    , year = ""
    , selectedConstituency = Constituency.initConstituency
    , showDetailMode = View
    }
