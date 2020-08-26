module Page.ShowSeats exposing (Model, Msg(..), decode, default, initShowSeatModel, update, view)

import Data.Seat as Seat
import Html exposing (div, form, input, label, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class, placeholder, readonly, type_, value)
import Html.Events exposing (onClick, onInput)
import Json.Decode as Decode


type Msg
    = ShowDetail Seat.Model
    | SeatsReceived SeatsData
    | Form Field
    | DetailMode ShowDetailMode
    | SearchList String


type Field
    = Name String
    | Id String
    | Constituency String
    | Party String
    | Votes String
    | Percentage String


type ShowDetailMode
    = View
    | Edit
    | New


type alias SeatsData =
    { seats : List Seat.Model }


type alias Model =
    { seats : List Seat.Model
    , searchWord : String
    , year : String
    , selectedSeat : Seat.Model
    , showDetailMode : ShowDetailMode
    , isLoading : Bool
    }


initShowSeatModel : Model
initShowSeatModel =
    default


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        ShowDetail seat ->
            ( { model | showDetailMode = View, selectedSeat = seat }, Cmd.none )

        SeatsReceived seatData ->
            ( { model
                | seats = seatData.seats
              }
            , Cmd.none
            )

        Form _ ->
            ( model, Cmd.none )

        DetailMode mode ->
            ( showDetailState mode model, Cmd.none )

        SearchList val ->
            ( { model | searchWord = val }, Cmd.none )


view : Model -> Html.Html Msg
view model =
    div
        []
        [ if String.length model.searchWord > 0 then
            renderHeader <| String.fromInt <| List.length <| Seat.filter model.searchWord model.seats

          else
            renderHeader <| String.fromInt <| List.length <| model.seats
        , div [ class "row" ]
            [ div [ class "col-md-8" ]
                [ if String.length model.searchWord > 0 then
                    renderSeatList (Seat.filter model.searchWord model.seats)

                  else
                    renderSeatList model.seats
                ]
            , div [ class "col-md-4" ]
                [ case model.showDetailMode of
                    View ->
                        renderDetails model.selectedSeat

                    Edit ->
                        div [] []

                    New ->
                        div [] []
                ]
            ]
        ]


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
            []
        ]


renderSeatList : List Seat.Model -> Html.Html Msg
renderSeatList seats =
    table [ class "table table-striped table table-hover" ]
        [ thead [] [ renderSeatsHeader ]
        , tbody []
            (List.map renderSeatItem seats)
        ]


renderSeatsHeader : Html.Html Msg
renderSeatsHeader =
    tr []
        [ th [] [ Html.text "Name" ]
        , th [] [ Html.text "Votes" ]
        , th [] [ Html.text "Party" ]
        , th [] [ Html.text "Constituency" ]
        ]


renderSeatItem : Seat.Model -> Html.Html Msg
renderSeatItem seat =
    tr [ onClick (ShowDetail seat) ]
        [ td [] [ Html.text seat.candidate.name ]
        , td [] [ Html.text seat.votes ]
        , td [] [ Html.text seat.party.name ]
        , td [] [ Html.text seat.constituency.name ]
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


renderDetails : Seat.Model -> Html.Html Msg
renderDetails model =
    form []
        [ renderField "text" "id" model.id "eg. 123" False Id
        , renderField "text" "name" model.candidate.name "Smith" False Name
        , renderField "text" "constituency" model.constituency.name "e.g Bantama" False Constituency
        , renderField "text" "party" model.party.name "XXX" False Party
        , renderField "text" "votes" model.votes "e.g 1002" False Votes
        , renderField "text" "percentage" model.percentage "e.g XXX" False Percentage
        ]


showDetailState : ShowDetailMode -> Model -> Model
showDetailState mode model =
    case mode of
        View ->
            { model | showDetailMode = View }

        Edit ->
            { model | showDetailMode = Edit }

        New ->
            { model | showDetailMode = New, selectedSeat = Seat.initSeat }


decode : Decode.Decoder SeatsData
decode =
    Decode.field "seatData" (Decode.map SeatsData Seat.decodeList)


default : Model
default =
    { seats = []
    , searchWord = ""
    , year = ""
    , selectedSeat = Seat.initSeat
    , showDetailMode = View
    , isLoading = False
    }
