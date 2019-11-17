defmodule Snake.Scene.Game do
  use Scenic.Scene

  import Scenic.Primitives, only: [rrect: 3]

  alias Scenic.ViewPort
  alias Scenic.Graph

  @graph Graph.build(clear_color: :dark_sea_green)
  @tile_size 32
  @tile_radius 8

  def init(_arg, opts) do
    viewport = opts[:viewport]

    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)

    num_tiles_width = trunc(vp_width / @tile_size)
    num_tiles_height = trunc(vp_height / @tile_size)

    state = %{
      width: num_tiles_width,
      height: num_tiles_height
    }

    snake = %{body: [{9, 9}, {10, 9}, {11, 9}], size: 5}

    # update the graph and push it to be rendered
    graph =
      @graph
      |> draw_object(snake)

    {:ok, state, push: graph}
  end

  defp draw_object(graph, %{body: snake}) do
    Enum.reduce(snake, graph, fn {x, y}, graph ->
      draw_tile(graph, x, y, fill: :dark_slate_gray)
    end)
  end

  # draw tiles as rounded rectangles to look nice
  defp draw_tile(graph, x, y, opts) do
    tile_opts = Keyword.merge([fill: :white, translate: {x * @tile_size, y * @tile_size}], opts)
    graph |> rrect({@tile_size, @tile_size, @tile_radius}, tile_opts)
  end
end
