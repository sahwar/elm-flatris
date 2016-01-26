module View (view) where
import Html exposing (div, Html, text, button, fromElement)
import Graphics.Collage as Collage
import Color exposing (Color)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick, onMouseDown, onMouseUp, on)
import Markdown
import Model exposing (Model)
import Actions exposing (Action)
import Grid exposing (Grid)
import Json.Decode as Decode


(=>) : a -> b -> (a, b)
(=>) = (,)


onTouchStart : Signal.Address a -> a -> Html.Attribute
onTouchStart address action =
  on "touchstart" Decode.value (\_ -> Signal.message address action)


onTouchEnd : Signal.Address a -> a -> Html.Attribute
onTouchEnd address action =
  on "touchend" Decode.value (\_ -> Signal.message address action)


renderBox : (Float, Float) -> (Color -> Color) -> Color -> (Int, Int) -> Collage.Form
renderBox (xOff, yOff) fun c (x, y) =
  Collage.rect 30 30
  |> Collage.filled (fun c)
  |> Collage.move ((toFloat x + xOff) * 30, (toFloat y + yOff) * -30)


renderNext : Grid Color -> Html
renderNext grid =
  let
    (width, height) = Grid.size grid
  in
    grid
    |> Grid.mapToList (renderBox ((1 - toFloat width) / 2, (1 - toFloat height) / 2) (always (Color.rgb 236 240 241)))
    |> Collage.collage (width * 30) (height * 30)
    |> fromElement


renderWell : Model -> Html
renderWell {width, height, active, grid, position} =
  ( Collage.filled (Color.rgb 236 240 241) (Collage.rect (toFloat (width * 30)) (toFloat (height * 30))) ::
    ( grid
      |> Grid.stamp (fst position) (floor (snd position)) active
      |> Grid.mapToList (renderBox ((1 - toFloat width) / 2, (1 - toFloat height) / 2) identity)
    )
  )
  |> Collage.collage (width * 30) (height * 30)
  |> fromElement


renderTitle : String -> Html
renderTitle txt =
  div
  [ style
    [ "color" => "#34495f"
    , "font-size" => "40px"
    , "line-height" => "60px"
    , "margin" => "30px 0 0"
    ]
  ]
  [ text txt ]


renderLabel : String -> Html
renderLabel txt =
  div
  [ style
    [ "color" => "#bdc3c7"
    , "font-weight" => "300"
    , "line-height" => "1"
    , "margin" => "30px 0 0"
    ]
  ]
  [ text txt ]


renderCount : Int -> Html
renderCount n =
  div
  [ style
    [ "color" => "#3993d0"
    , "font-size" => "30px"
    , "line-height" => "1"
    , "margin" => "5px 0 0"
    ]
  ]
  [ text (toString n) ]


renderGameButton : Signal.Address Action -> Model.State -> Html
renderGameButton address state =
  let
    (txt, action) = case state of
      Model.Stopped -> ("New game", Actions.Start)
      Model.Playing -> ("Pause", Actions.Pause)
      Model.Paused -> ("Resume", Actions.Resume)
  in
    button
    [ style
      [ "background" => "#34495f"
      , "border" => "0"
      , "bottom" => "30px"
      , "color" => "#fff"
      , "cursor" => "pointer"
      , "display" => "block"
      , "font-family" => "Helvetica, Arial, sans-serif"
      , "font-size" => "18px"
      , "font-weight" => "300"
      , "height" => "60px"
      , "left" => "30px"
      , "line-height" => "60px"
      , "outline" => "none"
      , "padding" => "0"
      , "position" => "absolute"
      , "width" => "120px"
      ]
    , onClick address action
    ]
    [ text txt ]


renderPanel : Signal.Address Action -> Model -> Html
renderPanel address {score, lines, next, state} =
  div
  [ style
    [ "bottom" => "80px"
    , "color" => "#34495f"
    , "font-family" => "Helvetica, Arial, sans-serif"
    , "font-size" => "14px"
    , "left" => "300px"
    , "padding" => "0 30px"
    , "position" => "absolute"
    , "right" => "0"
    , "top" => "0"
    ]
  ]
  [ renderTitle "Flatris"
  , renderLabel "Score"
  , renderCount score
  , renderLabel "Lines Cleared"
  , renderCount lines
  , renderLabel "Next Shape"
  , div
    [ style
      [ "margin-top" => "10px"
      , "position" => "relative"
      ]
    ]
    [ renderNext next ]
  , renderGameButton address state
  ]


renderControlButton : String -> List Html.Attribute -> Html
renderControlButton txt attrs =
  div
  ( style
    [ "background" => "#ecf0f1"
    , "border" => "0"
    , "color" => "#34495f"
    , "cursor" => "pointer"
    , "text-align" => "center"
    , "-webkit-user-select" => "none"
    , "display" => "block"
    , "float" => "left"
    , "font-family" => "Helvetica, Arial, sans-serif"
    , "font-size" => "24px"
    , "font-weight" => "300"
    , "height" => "60px"
    , "line-height" => "60px"
    , "margin" => "20px 20px 0 0"
    , "outline" => "none"
    , "padding" => "0"
    , "width" => "60px"
    ] :: attrs
  )
  [ text txt ]


renderControls : Signal.Address Action -> Html
renderControls address =
  div
  [ style
    [ "height" => "80px"
    , "left" => "0"
    , "position" => "absolute"
    , "top" => "600px"
    ]
  ]
  [ renderControlButton "↻"
    [ onMouseDown address (Actions.Rotate True)
    , onMouseUp address (Actions.Rotate False)
    , onTouchStart address (Actions.Rotate True)
    , onTouchEnd address (Actions.Rotate False)
    ]
  , renderControlButton "←"
    [ onMouseDown address (Actions.Move -1)
    , onMouseUp address (Actions.Move 0)
    , onTouchStart address (Actions.Move -1)
    , onTouchEnd address (Actions.Move 0)
    ]
  , renderControlButton "→"
    [ onMouseDown address (Actions.Move 1)
    , onMouseUp address (Actions.Move 0)
    , onTouchStart address (Actions.Move 1)
    , onTouchEnd address (Actions.Move 0)
    ]
  , renderControlButton "↓"
    [ onMouseDown address (Actions.Accelerate True)
    , onMouseUp address (Actions.Accelerate False)
    , onTouchStart address (Actions.Accelerate True)
    , onTouchEnd address (Actions.Accelerate False)
    ]
  ]


renderInfo : Model.State -> Html
renderInfo state =
  div
  [ style
    [ "background" => "rgba(236, 240, 241, 0.85)"
    , "color" => "#34495f"
    , "font-family" => "Helvetica, Arial, sans-serif"
    , "font-size" => "18px"
    , "height" => "600px"
    , "left" => "0"
    , "line-height" => "1.5"
    , "padding" => "0 15px"
    , "position" => "absolute"
    , "top" => "0"
    , "width" => "270px"
    , "display" => if state == Model.Playing then "none" else "block"
    ]
  ] [
    Markdown.toHtml """
elm-flatris is a [**Flatris**](https://github.com/skidding/flatris)
clone coded in [**Elm**](http://elm-lang.org/) language.

Inspired by the classic [**Tetris**](http://en.wikipedia.org/wiki/Tetris)
game, the game can be played with a keyboard using the arrow keys,
and on mobile devices using the buttons below.

elm-flatris is open source on
[**GitHub**](https://github.com/w0rm/elm-flatris).
"""
  ]


view : Signal.Address Action -> Model -> Html
view address model =
  div
  [ style ["padding" => "30px 0"]
  , onTouchEnd address Actions.UnlockButtons
  , onMouseUp address Actions.UnlockButtons
  ]
  [ div
    [ style
      [ "height" => "680px"
      , "margin" => "auto"
      , "position" => "relative"
      , "width" => "480px"
      ]
    ]
    [ renderWell model
    , renderControls address
    , renderPanel address model
    , renderInfo model.state
    ]
  ]
