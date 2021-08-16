module Main exposing (main)

import Browser
import Css exposing (..)
import Data as Data
import Html.Attributes as Attr
import Html.Styled as Html exposing (Html, a, button, div, header, img, text, toUnstyled)
import Html.Styled.Attributes exposing (class, css, src, value)
import Html.Styled.Events as Events exposing (onClick)
import Ports exposing (listenToJs)


type alias Model =
    { data : List Data.Car, waitingToBeDeleted : Maybe Data.Car }


initCars : Model
initCars =
    { data = [], waitingToBeDeleted = Nothing }


main : Program String Model Data.Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view >> toUnstyled
        , subscriptions = subscriptions
        }


subscriptions : a -> Sub Data.Msg
subscriptions =
    \_ -> listenToJs Data.PortMsgReceived


init : String -> ( Model, Cmd Data.Msg )
init _ =
    ( initCars, Ports.sendToJs Ports.FetchCars )


update : Data.Msg -> Model -> ( Model, Cmd Data.Msg )
update msg model =
    case msg of
        Data.OnModalClose ->
            ( closePopUp False model, Cmd.none )

        Data.OnModalSubmit ->
            ( closePopUp True model, Cmd.none )

        Data.OnRemove car ->
            ( showPopUp car model, Cmd.none )

        Data.PortMsgReceived portMsg ->
            handlePortMsg portMsg model

        Data.IncomingDecoderError _ ->
            -- Throw some error
            ( model, Cmd.none )


removeIdFromCarList : Data.Car -> List Data.Car -> List Data.Car
removeIdFromCarList car list =
    list |> List.filter (\itm -> car.id /= itm.id)


showPopUp : Data.Car -> Model -> Model
showPopUp car model =
    { model | waitingToBeDeleted = Just car }


closePopUp : Bool -> Model -> Model
closePopUp isRemove model =
    let
        car =
            Maybe.withDefault Data.emptyCar model.waitingToBeDeleted
    in
    if isRemove then
        { model | data = removeIdFromCarList car model.data, waitingToBeDeleted = Nothing }

    else
        { model | waitingToBeDeleted = Nothing }


view : Model -> Html Data.Msg
view { data, waitingToBeDeleted } =
    let
        appContainer =
            Css.batch
                [ backgroundColor (hex "#ffffff")
                ]
    in
    div [ css [ appContainer ] ]
        [ renderCars data
        , case waitingToBeDeleted of
            Just car ->
                renderPopUp car

            Nothing ->
                text ""
        ]


renderPopUp : Data.Car -> Html Data.Msg
renderPopUp carToBeRemoved =
    -- Popup design goes here (copied the styles from w3c)
    let
        modal =
            Css.batch
                [ position fixed
                , zIndex (int 10)
                , left zero
                , top zero
                , width (pct 100)
                , height (pct 100)
                , overflow auto
                , opacity (num 0.7)
                , backgroundColor (hex "#000000")
                ]

        modalContents =
            Css.batch
                [ displayFlex
                , flexDirection column
                , justifyContent spaceBetween
                , backgroundColor (hex "#fefefe")
                , margin2 (pct 15) auto
                , padding2 (rem 0.5) (rem 1)
                , border3 (rem 0.1) solid (hex "#888")
                , width (pct 20)
                , height (pct 30)
                ]

        xBtnContainer =
            Css.batch
                [ displayFlex
                , justifyContent spaceBetween
                ]

        xBtn =
            Css.batch
                [ color (hex "#000000")
                , fontSize (rem 0.8)
                , fontSize (px 15)
                , cursor pointer
                ]

        actionBtnContainer =
            Css.batch
                [ displayFlex
                , flexDirection row
                , justifyContent spaceBetween
                ]

        cancelBtn =
            Css.batch
                [ backgroundColor (hex "#ffffff")
                , color (hex "#000000")
                , fontSize (px 13)
                , padding2 (px 5) (px 15)
                , border3 (rem 0.1) solid (hex "#888")
                , cursor pointer
                ]

        submitBtn =
            Css.batch
                [ backgroundColor (hex "#000000")
                , color (hex "#eaeaea")
                , fontSize (px 13)
                , padding2 (px 5) (px 15)
                , cursor pointer
                ]
    in
    div [ css [ modal ] ]
        [ div [ css [ modalContents ] ]
            [ div [ css [ xBtnContainer ] ]
                [ div []
                    [ text ("Confirm deletion of " ++ carToBeRemoved.name ++ " ? ")
                    ]
                , div [ css [ xBtn ], onClick Data.OnModalClose ]
                    [ text "x"
                    ]
                ]
            , div [ css [ actionBtnContainer ] ]
                [ div [ css [ cancelBtn ], onClick Data.OnModalClose ]
                    [ text "Cancel"
                    ]
                , div [ css [ submitBtn ], onClick Data.OnModalSubmit ]
                    [ text "Submit"
                    ]
                ]
            ]
        ]


renderCars : List Data.Car -> Html Data.Msg
renderCars cars =
    let
        container =
            Css.batch
                [ displayFlex
                , flexDirection row
                ]
    in
    div [ css [ container ] ]
        (List.map renderCar cars)


renderCar : Data.Car -> Html Data.Msg
renderCar car =
    let
        container =
            Css.batch
                [ displayFlex
                , flexDirection column
                , width (rem 10)
                , height (rem 12)
                , margin (rem 1)
                , padding (rem 0.5)
                , border3 (rem 0.1) solid (hex "#888")
                ]

        closeStyle =
            Css.batch
                [ textAlign right
                , cursor pointer
                ]
    in
    div [ css [ container ] ]
        [ div [ css [ closeStyle ] ]
            [ div [ onClick (Data.OnRemove car) ] [ text "x" ]
            ]
        , img [ src car.imgUrl ] []
        , div [] [ text car.name ]
        , div [] [ text (String.fromFloat car.price) ]
        ]


handlePortMsg : Data.IncomingMsg -> Model -> ( Model, Cmd Data.Msg )
handlePortMsg incomingMsg model =
    case incomingMsg of
        Data.InitLoad result ->
            case result of
                Ok cars ->
                    let
                        updatedModel =
                            { model | data = cars.cars }
                    in
                    ( updatedModel, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        Data.UnknownIncomingMessage v ->
            ( model, Cmd.none )
