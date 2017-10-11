import Html exposing (Html, Attribute, button, div, h1, text)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Maybe exposing (withDefault)
import Array exposing (Array)
import Debug exposing (..)

main =
  Html.beginnerProgram { model = model, view = view, update = update }

-- MODEL

type Action 
    = Add 
    | Move
    | NoOp

type PieceType 
    = Road 
    | Wall 
    | CapStone

type alias TileId =
    Int

type alias Tile  = 
    (TileId, Pieces)

type alias Tiles = 
    Array Pieces

type alias ChosenTile = 
    TileId

type alias Pieces =
    Array Piece

type alias Piece = 
    { color : String 
    , kind : PieceType
    }

type alias PieceId =
    Int

type alias ChosenPiece =
    (TileId, PieceId)

type alias Model = 
    { action : Action
    , chosenTile : ChosenTile
    , chosenPiece : ChosenPiece
    , tilesWithPieces : Tiles
    }


defaultPiece : Piece
defaultPiece = Piece "black" Road


model : Model
model = 
    { action = NoOp
    , chosenTile = -1 
    , chosenPiece = (-1, -1)
    , tilesWithPieces = Array.initialize 25 (always Array.empty)
    }

-- UPDATE

addPiece : Pieces -> Pieces
addPiece pieces =
  Array.append (Array.fromList [defaultPiece]) pieces


movePieces : TileId -> ChosenPiece -> Tiles -> Tiles
movePieces toTile (fromTile, withPieces) tiles = 
  let 
    toTilesPieces = 
      tiles
        |> Array.get toTile
        |> Maybe.withDefault Array.empty

    fromPieces = 
      tiles
        |> Array.get fromTile
        |> Maybe.withDefault Array.empty
        |> Array.slice 0 (withPieces + 1)

    updatedToTile = 
      Array.append toTilesPieces fromPieces

    piecesLength = 
      tiles 
        |> Array.get fromTile
        |> Maybe.withDefault Array.empty
        |> Array.length 

    toPieces = 
      tiles
        |> Array.get fromTile
        |> Maybe.withDefault Array.empty
        |> Array.slice (withPieces + 1) piecesLength

  in
    tiles
      |> Array.set toTile updatedToTile
      |> Array.set fromTile toPieces


type Msg 
      = StackPiece 
      | HideTileInfo
      | ShowTileInfo Int
      | UpdateCount Int
      | SelectPiece (Int, Int)
      | MovePieces

update : Msg -> Model -> Model
update msg model =
  case msg of
    StackPiece-> 
      { model | action = Add }
    MovePieces -> 
      { model | action = Move }
    ShowTileInfo id -> 
      { model | chosenTile = id }
    SelectPiece (tId, pId) ->
      { model | chosenPiece = (tId, pId)}
    HideTileInfo -> 
      { model | chosenTile = -1 }
    UpdateCount id -> 
      case model.action of
        Add -> 
          { model | 
            action = NoOp
          , chosenTile = id
          , tilesWithPieces = 
              let 
                p = model.tilesWithPieces 
                  |> Array.get id
                  |> Maybe.withDefault Array.empty
                  |> addPiece 
              in
                Array.set id p model.tilesWithPieces
          }
        Move ->
          { model 
          | tilesWithPieces = movePieces id model.chosenPiece model.tilesWithPieces 
          , action = NoOp
          , chosenTile = id
          }
        NoOp ->
          { model | chosenTile = id } 


-- VIEW -------------------------------------------------------
      
chosenPieceDisplay : TileId -> (PieceId, Piece) -> Html Msg
chosenPieceDisplay tId (pId, p) = 
  div 
    [ class "display-list-piece"
    , id <| toString pId 
    , onClick <| SelectPiece (tId, pId)
    ] 
    []


displayChosenTile : TileId -> Tiles -> Html Msg
displayChosenTile tId tiles = 
  tiles
    |> Array.get tId
    |> Maybe.withDefault Array.empty
    |> Array.toIndexedList
    |> List.map (chosenPieceDisplay tId)
    |> div []


-- Take anything as a parameter and return an Html msg
createGameTile : Tile -> Html Msg
createGameTile (tId, pieces) = 
  div 
    [ class "tile"
    , id <| toString tId
    , onClick <| UpdateCount tId
    ]
    [ pieces
        |> Array.toList
        |> List.take 1
        |> List.map (\p -> div [ class "piece" ] [])
        |> div [ class "stack-head" ] 
    , pieces 
        |> Array.toList
        |> List.tail 
        |> Maybe.withDefault []
        |> List.map (\p -> div [ class "stacked-piece" ] []) 
        |> div [ class "stacked-pieces" ] 
    ]


view : Model -> Html Msg
view model =
  div [ class "game" ]
    [ h1 [ class "header" ] [ text "Tak.elm" ] 
    , div 
      [ class "main" ]
      [ model.tilesWithPieces
        |> Array.toIndexedList
        |> List.map createGameTile 
        |> div [ class "game-board" ] 
      , div
        [ class "main-right" ]
        [ displayChosenTile model.chosenTile model.tilesWithPieces ]
      ]
    , div [ class "footer" ]
      [ div 
        []
        [ button 
          [ class "action"
          , onClick StackPiece 
          ] 
          [ text "Add Road" ]
        , button 
            [ onClick MovePieces ]
            [ text "Move Pieces" ]
        , button 
            [ onClick HideTileInfo ]
            [ text "Clear Chosen Tile" ]
        ]
      ]
    ]
