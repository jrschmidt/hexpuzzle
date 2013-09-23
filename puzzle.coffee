class PuzzleApp

  constructor: () ->

    @grid = new PuzzleGridModel
    @puzzle_view = new PuzzleView
    @piece = new PuzzlePiece(this)
    @piece.draw_piece(0,0)
    alert(":-)")
    @piece.draw_piece(2,1)



class PuzzleGridModel

  get_xy: (a,b) ->
    if @in_range(a,b)
      t_dx = -3 # (temporary offsets for development)
      t_dy = -2
      x = 103 + 14.5*a + (a%2)/2 + t_dx
      y = 28 + 19*b + (a%2)*10 + t_dy
      xy = [x,y]
    else
      xy = [0,0]
    xy


  in_range: (a,b) ->
    a = 0 if not a?
    b = 0 if not b?
    ok = true
    ok = false if a<1 || a>24
    ok = false if b<1 || b>10
    ok = false if b == 10 && a%2 == 1
    ok



class PuzzlePiece

  constructor: (puzzle_app) ->

    @dim = @get_dim()
    @width = @dim[0]
    @height = @dim[1]

    @redraw = document.createElement('canvas')
    @redraw.width = @width
    @redraw.height = @height

    @puzzle = puzzle_app
    @grid = @puzzle.grid

    @canvas = document.getElementById("puzzle-widget")
    @context = @canvas.getContext("2d")

    # TODO When we code movement of the puzzle piece across the grid, we will
    #      extract these lines to a 'reset(a,b)' method.
    #         (which lines?)

    dxy = @get_piece_xy_offset()
    @dx = dxy[0]
    @dy = dxy[1]

    @redraw = document.createElement('canvas')
    @redraw.width = @width
    @redraw.height = @height

  draw_piece:  (a,b) ->
    @pc_img = document.getElementById("piece")
    if @grid.in_range(a,b)
      xy = @grid.get_xy(a,b)
      xx = xy[0]+@dx
      yy = xy[1]+@dy

      # FIXME 'index out of range' error for jasmine, but okay for standalone
      if @redraw.width > 0 && @redraw.height > 0
        ctx = @redraw.getContext('2d')
        ctx.drawImage(@canvas,xx,yy,@width,@height,0,0,@width,@height)
      else
        alert("redraw image not yet ready")

      @context.drawImage(@redraw,300,100)

      @context.drawImage(@pc_img,xx,yy)
    else
      @context.drawImage(@pc_img,0,100)

  get_dim: () ->
    dim = [63,87] # (temporarily hard code these values)
    dim

  get_piece_xy_offset: () ->
    dx = -14 # (temporarily hard code these values)
    dy = 0
    dxy = [dx,dy]
    dxy



class RedrawBuffer

  constructor: () ->
    @buffer = document.createElement('canvas')
    @width = 1
    @height = 1

  reset_size: (x,y) ->
    @width = x
    @height = y



class PuzzleView

  constructor: () ->

    @canvas = document.getElementById("puzzle-widget")
    @context = @canvas.getContext("2d")

    @img = document.getElementById("frame")
    @context.drawImage(@img,100,30)


#   #   #   #   #   #
#   Global Scope Statements
#   #   #   #   #   #


start = () ->
  @app = new PuzzleApp()


window.onload = start


