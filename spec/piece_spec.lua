local Board = require "src.board"
local Piece = require "src.piece"
local tablex = require "pl.tablex"

describe("Piece generation", function()
  it("should geenrate pieces until bag is empty", function()
    -- given
    assert.are.equal(0, #Piece.bag)

    -- when
    local pieces = {}
    for _ = 1, 7 do
      table.insert(pieces, Piece.generate())
    end

    -- then
    assert.are.equal(0, #Piece.bag)
    assert.are.equal(7, #pieces)
    assert.are.unique(pieces)
  end)
end)

describe("Piece", function()
  local game
  local board
  local piece

  before_each(function()
    game = {}
    board = Board:new(game, 10, 22, 20)
    piece = Piece.generate(board)
  end)

  describe("Movement", function()
    it("willCollide should return true on collision", function()
      -- given
      local other = tablex.deepcopy(piece)

      -- when
      local willCollide = piece:willCollide(other, 'x', 0)

      -- then
      assert.is_true(willCollide)
    end)

    it("willCollide should return false on no collision", function()
      -- given
      local other = tablex.deepcopy(piece)
      other:move('x', 10)

      -- when
      local willCollide = piece:willCollide(other, 'x', 0)

      -- then
      assert.is_false(willCollide)
    end)

    it("willCollideAny should return true on collision", function()
      -- given
      local other1 = tablex.deepcopy(piece)
      local other2 = tablex.deepcopy(piece)
      other1:move('x', 10)

      -- when
      local willCollide = piece:willCollideAny({ other1, other2 }, 'x', 0)

      -- then
      assert.is_true(willCollide)
    end)

    it("willCollideAny should return false on no collision", function()
      -- given
      local other1 = tablex.deepcopy(piece)
      local other2 = tablex.deepcopy(piece)
      other1:move('x', 10)
      other2:move('x', 10)

      -- when
      local willCollide = piece:willCollideAny({ other1, other2 }, 'x', 0)

      -- then
      assert.is_false(willCollide)
    end)

    it("should update coordinates on move", function()
      -- given
      local old_coordinates = tablex.deepcopy(piece.coordinates)
      local DELTA = 1
      local AXIS = 'x'

      -- when
      piece:move(AXIS, DELTA)

      -- then
      for i = 1, #old_coordinates do
        assert.are.equal(old_coordinates[i][AXIS] + DELTA, piece.coordinates[i][AXIS])
      end
    end)
  end)

  -- TODO: Implement rotation tests (probably use fixtures)
  describe("Rotation", function()
    it("calculates midpoint correctly")
    it("calculates rotated coordinates correctly")
    it("can rotate if the rotated position is free")
    it("cannot rotate if the rotated position is not free")
    it("TODO: Tetris Guidelines rotation tests")
    it("Updates rotated coordinates correctly")
  end)

  describe("removeCoordinate", function()
    it("should remove coordinate if it exists", function()
      -- given
      local num_coordinates = #piece.coordinates
      local coordinate = piece.coordinates[1]

      -- when
      piece:removeCoordinate(coordinate.x, coordinate.y)

      -- then
      assert.are.equal(num_coordinates - 1, #piece.coordinates)
      assert.is_nil(tablex.find(piece.coordinates, coordinate))
    end)

    it("should not remove coordinate if it does not exist", function()
      -- given
      local num_coordinates = #piece.coordinates
      local coordinate = { x = piece.coordinates[1].x + 10, y = piece.coordinates[1].y + 10 }

      -- when
      piece:removeCoordinate(coordinate.x, coordinate)

      -- then
      assert.are.equal(num_coordinates, #piece.coordinates)
      assert.is_nil(tablex.find(piece.coordinates, coordinate))
    end)
  end)
end)
