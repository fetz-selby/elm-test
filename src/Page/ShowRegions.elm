module Page.ShowRegions exposing (Model, Msg(..), decode, default, update, view)

import Data.Region as Region exposing (isValid)
import Html exposing (button, div, form, input, label, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class, classList, disabled, placeholder, readonly, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Json.Decode as Decode
import Ports


type Msg
    = FetchRegions
    | AddRegion
    | ShowDetail Region.Model
    | RegionsReceived RegionData
    | AddOne Region.Model
    | UpdateOne Region.Model
    | Form Field
    | Save
    | Update
    | DetailMode ShowDetailMode
    | OnEdit
    | SearchList String
    | OnDelete String
    | OnAdd


type Field
    = Name String
    | Seats String


type ShowDetailMode
    = View
    | Edit
    | New


type alias RegionData =
    { regions : List Region.Model }


type alias Model =
    { regions : List Region.Model
    , searchWord : String
    , year : String
    , selectedRegion : Region.Model
    , showDetailMode : ShowDetailMode
    , isLoading : Bool
    }


view : Model -> Html.Html Msg
view model =
    div
        []
        [ if String.length model.searchWord > 0 then
            renderHeader <| String.fromInt <| List.length <| Region.filter model.searchWord model.regions

          else
            renderHeader <| String.fromInt <| List.length <| model.regions
        , div [ class "row" ]
            [ div [ class "col-md-8" ]
                [ if String.length model.searchWord > 0 then
                    renderRegionList (Region.filter model.searchWord model.regions)

                  else
                    renderRegionList model.regions
                ]
            , div [ class "col-md-4" ]
                [ case model.showDetailMode of
                    View ->
                        renderDetails model.selectedRegion

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
        FetchRegions ->
            ( model, Cmd.none )

        AddRegion ->
            ( { model | showDetailMode = New, selectedRegion = Region.initRegion, isLoading = False }, Cmd.none )

        ShowDetail region ->
            ( { model | showDetailMode = View, selectedRegion = region }, Cmd.none )

        RegionsReceived regionData ->
            ( { model | regions = regionData.regions, isLoading = False }, Cmd.none )

        AddOne region ->
            ( { model
                | regions = addToRegions region model.regions
                , isLoading = False
                , showDetailMode = View
              }
            , Cmd.none
            )

        Form field ->
            case field of
                Name name ->
                    ( { model | selectedRegion = Region.modifyName name model.selectedRegion }, Cmd.none )

                Seats seat ->
                    ( { model | selectedRegion = Region.modifySeat seat model.selectedRegion }, Cmd.none )

        Save ->
            ( { model | isLoading = True }, Cmd.batch [ Ports.sendToJs (Ports.SaveRegion model.selectedRegion) ] )

        DetailMode mode ->
            ( showDetailState mode model, Cmd.none )

        OnEdit ->
            ( { model | showDetailMode = Edit }, Cmd.none )

        SearchList val ->
            ( { model | searchWord = val }, Cmd.none )

        OnDelete id ->
            ( { model | isLoading = True }, Ports.sendToJs (Ports.DeleteRegion id) )

        OnAdd ->
            ( model, Cmd.none )

        Update ->
            ( { model | isLoading = True }, Ports.sendToJs (Ports.UpdateRegion model.selectedRegion) )

        UpdateOne region ->
            ( { model
                | isLoading = False
                , regions = Region.replace region model.regions
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
            [ Html.text result ]
        , div [ class "col-md-3" ]
            [ button [ class "btn btn-primary new-button", onClick AddRegion ] [ Html.text "New" ]
            ]
        ]


renderRegionList : List Region.Model -> Html.Html Msg
renderRegionList regions =
    table [ class "table table-striped table table-hover" ]
        [ thead []
            [ renderRegionHeader ]
        , tbody
            []
            (List.map renderRegionItem regions)
        ]


renderRegionHeader : Html.Html Msg
renderRegionHeader =
    tr []
        [ th [] [ Html.text "Region" ]
        , th [] [ Html.text "Seats" ]
        ]


renderRegionItem : Region.Model -> Html.Html Msg
renderRegionItem region =
    tr [ onClick (ShowDetail region) ]
        [ td [] [ Html.text region.name ]
        , td [] [ Html.text region.seats ]
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


renderDetails : Region.Model -> Html.Html Msg
renderDetails model =
    div []
        [ div [ class "col-md-12 spacing-bottom" ]
            [ div [ class "pull-right edit-style", onClick OnEdit ] [ Html.text "edit" ]
            ]
        , form []
            [ renderField "text" "region" model.name "eg.Ashanti" False Name
            , renderField "number" "seat" model.seats "e.g 30" False Seats
            ]
        ]


renderEditableDetails : Model -> Html.Html Msg
renderEditableDetails model =
    form [ onSubmit Update ]
        [ renderField "text" "region" model.selectedRegion.name "eg.Ashanti" True Name
        , renderField "number" "seat" model.selectedRegion.seats "e.g 30" True Seats
        , renderSubmitBtn model.isLoading (Region.isValid model.selectedRegion) "Update" "btn btn-danger" True
        ]


renderNewDetails : Model -> Html.Html Msg
renderNewDetails model =
    form [ onSubmit Save ]
        [ renderField "text" "region" model.selectedRegion.name "eg.Ashanti" True Name
        , renderField "number" "seat" model.selectedRegion.seats "e.g 30" True Seats
        , renderSubmitBtn model.isLoading (Region.isValid model.selectedRegion) "Save" "btn btn-danger" True
        ]


showDetailState : ShowDetailMode -> Model -> Model
showDetailState mode model =
    case mode of
        View ->
            { model | showDetailMode = View }

        Edit ->
            { model | showDetailMode = Edit }

        New ->
            { model | showDetailMode = New, selectedRegion = Region.initRegion }


addToRegions : Region.Model -> List Region.Model -> List Region.Model
addToRegions region list =
    if Region.isIdExist region list then
        list

    else
        region :: list


decode : Decode.Decoder RegionData
decode =
    Decode.field "regionData" (Decode.map RegionData Region.decodeList)


default : Model
default =
    { regions = []
    , searchWord = ""
    , year = ""
    , selectedRegion = Region.initRegion
    , showDetailMode = View
    , isLoading = False
    }
