module Page.ShowConstituencies exposing (Model, Msg(..), decode, default, update, view)

import Data.Constituency as Constituency
import Data.ParentConstituency as ParentConstituency
import Data.Party as Party
import Html exposing (button, div, form, input, label, option, select, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (checked, class, classList, disabled, placeholder, readonly, type_, value)
import Html.Events exposing (onCheck, onClick, onInput, onSubmit)
import Html.Events.Extra exposing (onChange)
import Json.Decode as Decode
import Ports


type Msg
    = FetchConstituencies String
    | AddConstituency
    | ShowDetail Constituency.Model
    | ConstituenciesReceived ConstituencyData
    | AddOne Constituency.Model
    | UpdateOne Constituency.Model
    | Form Field
    | Save
    | Update
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
    | AllSelected Bool
    | IsDeclaredSelected Bool
    | IsNotDeclaredSelected Bool


type ShowDetailMode
    = View
    | Edit
    | New


type alias ConstituencyData =
    { constituencies : List Constituency.Model
    , parentConstituencies : List ParentConstituency.Model
    , parties : List Party.Model
    }


type ViewFilter
    = AllView
    | DeclaredView
    | NotDeclaredView


type alias Model =
    { constituencies : List Constituency.Model
    , parentConstituencies : List ParentConstituency.Model
    , parties : List Party.Model
    , region : String
    , searchWord : String
    , year : String
    , selectedConstituency : Constituency.Model
    , showDetailMode : ShowDetailMode
    , isLoading : Bool
    , filter : ViewFilter
    }


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchConstituencies constituencyId ->
            ( model, Cmd.none )

        AddConstituency ->
            ( { model | showDetailMode = New, selectedConstituency = Constituency.initConstituency }, Cmd.none )

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
            ( { model
                | constituencies = addToConstituencies constituency model.constituencies
                , isLoading = False
                , showDetailMode = View
              }
            , Cmd.none
            )

        Form field ->
            case field of
                Constituency constituencyName ->
                    ( { model | selectedConstituency = Constituency.setName constituencyName model.selectedConstituency }, Cmd.none )

                CastedVotes castedVotes ->
                    ( { model | selectedConstituency = Constituency.setCastedVotes castedVotes model.selectedConstituency }, Cmd.none )

                IsDeclared isDeclared ->
                    ( { model | selectedConstituency = Constituency.setIsDeclared isDeclared model.selectedConstituency }, Cmd.none )

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
                    ( { model | selectedConstituency = Constituency.setAutoCompute autoCompute model.selectedConstituency }, Cmd.none )

                AllSelected isAllSelected ->
                    ( { model | filter = AllView }, Cmd.none )

                IsDeclaredSelected isDeclaredSelected ->
                    ( { model | filter = DeclaredView }, Cmd.none )

                IsNotDeclaredSelected isNotDeclaredSelected ->
                    ( { model | filter = NotDeclaredView }, Cmd.none )

        Save ->
            ( { model | isLoading = True }, Cmd.batch [ Ports.sendToJs (Ports.SaveConstituency model.selectedConstituency) ] )

        DetailMode mode ->
            ( showDetailState mode model, Cmd.none )

        OnEdit ->
            ( { model | showDetailMode = Edit }, Cmd.none )

        SearchList val ->
            ( { model | searchWord = val }, Cmd.none )

        Update ->
            ( { model | isLoading = True }, Ports.sendToJs (Ports.UpdateConstituency model.selectedConstituency) )

        UpdateOne constituency ->
            ( { model
                | isLoading = False
                , constituencies = Constituency.replace constituency model.constituencies
                , showDetailMode = View
              }
            , Cmd.none
            )


view : Model -> Html.Html Msg
view model =
    div
        []
        [ renderHeader
        , case model.filter of
            AllView ->
                div [ class "row" ]
                    [ renderFilter "All" AllSelected True
                    , renderFilter "Declared" IsDeclaredSelected False
                    , renderFilter "Not Declared" IsNotDeclaredSelected False
                    ]

            DeclaredView ->
                div [ class "row" ]
                    [ renderFilter "All" AllSelected False
                    , renderFilter "Declared" IsDeclaredSelected True
                    , renderFilter "Not Declared" IsNotDeclaredSelected False
                    ]

            NotDeclaredView ->
                div [ class "row" ]
                    [ renderFilter "All" AllSelected False
                    , renderFilter "Declared" IsDeclaredSelected False
                    , renderFilter "Not Declared" IsNotDeclaredSelected True
                    ]
        , div [ class "row" ]
            [ div [ class "col-md-8" ]
                [ case model.filter of
                    AllView ->
                        if String.length model.searchWord > 0 then
                            renderConstituencyList (Constituency.filter model.searchWord model.constituencies)

                        else
                            renderConstituencyList model.constituencies

                    DeclaredView ->
                        let
                            filteredConstituencies =
                                Constituency.getDeclared model.constituencies
                        in
                        if String.length model.searchWord > 0 then
                            renderConstituencyList (Constituency.filter model.searchWord filteredConstituencies)

                        else
                            renderConstituencyList filteredConstituencies

                    NotDeclaredView ->
                        let
                            filteredConstituencies =
                                Constituency.getNotDeclared model.constituencies
                        in
                        if String.length model.searchWord > 0 then
                            renderConstituencyList (Constituency.filter model.searchWord filteredConstituencies)

                        else
                            renderConstituencyList filteredConstituencies
                ]
            , div [ class "col-md-4" ]
                [ case model.showDetailMode of
                    View ->
                        renderDetails model.selectedConstituency

                    Edit ->
                        renderEditableDetails model

                    New ->
                        renderNewDetails model
                ]
            ]
        ]



-- if String.length model.searchWord > 0 then
--             renderConstituencyList (Constituency.filter model.searchWord model.constituencies)
--           else
--             renderConstituencyList model.constituencies


renderFilter : String -> (Bool -> Field) -> Bool -> Html.Html Msg
renderFilter checkLabel isChecked checkedValue =
    div [ class "form-group" ]
        [ div [ class "col-md-12" ]
            [ div [ class "checkbox" ]
                [ label []
                    [ input
                        [ type_ "checkbox"
                        , onCheck (Form << isChecked)
                        , checked checkedValue
                        ]
                        []
                    , label [ class "small-lnr-pad" ] [ Html.text checkLabel ]
                    ]
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


getIsDeclaredList : List { id : String, name : String }
getIsDeclaredList =
    [ { id = "0", name = "Select" }, { id = "N", name = "No" }, { id = "Y", name = "Yes" } ]


getAutoComputeList : List { id : String, name : String }
getAutoComputeList =
    [ { id = "0", name = "Select" }, { id = "N", name = "No" }, { id = "Y", name = "Yes" } ]


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


renderDetails : Constituency.Model -> Html.Html Msg
renderDetails model =
    div []
        [ div [ class "col-md-12 spacing-bottom" ]
            [ div [ class "pull-right edit-style", onClick OnEdit ] [ Html.text "edit" ]
            ]
        , form [ onSubmit Save ]
            [ renderField "text" "constituency" model.name "eg.Bekwai" False Constituency
            , renderField "text" "seat won by" model.seatWonId.name "eg.XXX" False SeatWonId
            , renderField "number" "casted votes" model.castedVotes "e.g 3423" False CastedVotes
            , renderField "number" "reg votes" model.regVotes "e.g 432" False RegVotes
            , renderField "number" "rejected votes" model.rejectVotes "e.g 180" False RejectVotes
            , renderField "number" "total votes" model.totalVotes "e.g 234" False TotalVotes
            , renderField "text"
                "is declared"
                (if model.isDeclared then
                    "Yes"

                 else
                    "No"
                )
                "e.g Yes"
                False
                IsDeclared
            , renderField "text"
                "is auto-compute"
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


renderEditableDetails : Model -> Html.Html Msg
renderEditableDetails model =
    form [ onSubmit Update ]
        [ renderField "text" "constituency" model.selectedConstituency.name "eg.Bekwai" True Constituency
        , renderParties "seat won by" SeatWonId (Party.addIfNotExist Party.getFirstSelect model.parties)
        , renderField "number" "casted votes" model.selectedConstituency.castedVotes "e.g 2342" True CastedVotes
        , renderField "number" "reg votes" model.selectedConstituency.regVotes "e.g 432" True RegVotes
        , renderField "number" "rejected votes" model.selectedConstituency.rejectVotes "e.g 180" True RejectVotes
        , renderField "number" "total votes" model.selectedConstituency.totalVotes "e.g 234" True TotalVotes
        , renderGenericList "is declared" IsDeclared getIsDeclaredList
        , renderGenericList "is auto compute" AutoCompute getAutoComputeList
        , renderSubmitBtn model.isLoading (Constituency.isValid model.selectedConstituency) "Update" "btn btn-danger" True
        ]


renderNewDetails : Model -> Html.Html Msg
renderNewDetails model =
    form [ onSubmit Save ]
        [ renderParentConstituencies "parent constituency" ParentId (ParentConstituency.addIfNotExist ParentConstituency.getFirstSelect model.parentConstituencies)
        , renderField "text" "constituency" model.selectedConstituency.name "eg.Bekwai" True Constituency
        , renderField "number" "casted votes" model.selectedConstituency.castedVotes "e.g 2343" True CastedVotes
        , renderField "number" "reg votes" model.selectedConstituency.regVotes "e.g 432" True RegVotes
        , renderField "number" "rejected votes" model.selectedConstituency.rejectVotes "e.g 180" True RejectVotes
        , renderField "number" "total votes" model.selectedConstituency.totalVotes "e.g 234" True TotalVotes
        , renderGenericList "is auto compute" AutoCompute getAutoComputeList
        , renderSubmitBtn model.isLoading (Constituency.isValid model.selectedConstituency) "Save" "btn btn-danger" True
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
    if Constituency.isIdExist constituency list then
        list

    else
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
    , isLoading = False
    , filter = AllView
    }
