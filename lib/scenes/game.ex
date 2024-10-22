defmodule Snake.Scene.Game do
  use Scenic.Scene

  import Scenic.Primitives, only: [rrect: 3]

  alias Scenic.ViewPort
  alias Scenic.Graph

  @graph Graph.build(clear_color: :dark_sea_green)
  @tile_size 32
  @tile_radius 8
  @frame_ms 192

  def init(_arg, opts) do
    viewport = opts[:viewport]

    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)

    number_of_columns = div(vp_width, @tile_size)
    number_of_rows = div(vp_height, @tile_size)

    state = %{
      width: number_of_columns,
      height: number_of_rows,
      snake: %{body: [{9, 9}, {10, 9}, {11, 9}], direction: {1, 0}}
    }

    # start timer
    {:ok, _timer} = :timer.send_interval(@frame_ms, :frame)

    {:ok, state, push: @graph}
  end

  def handle_info(:frame, state) do
    new_state = move_snake(state)
    graph = draw_objects(@graph, new_state)

    {:noreply, new_state, push: graph}
  end

  defp draw_objects(graph, %{snake: %{body: body}}) do
    Enum.reduce(body, graph, fn {x, y}, graph ->
      draw_tile(graph, x, y, fill: :dark_slate_gray)
    end)
  end

  # draw tiles as rounded rectangles to look nice
  defp draw_tile(graph, x, y, opts) do
    tile_opts = Keyword.merge([fill: :white, translate: {x * @tile_size, y * @tile_size}], opts)
    graph |> rrect({@tile_size, @tile_size, @tile_radius}, tile_opts)
  end

  defp move_snake(%{snake: snake} = state) do
    %{body: body, direction: direction} = snake

    # new head
    [head | _] = body
    new_head = move(state, head, direction)

    # truncate body
    size = length(body)
    new_body = Enum.take([new_head | body], size)

    state
    |> put_in([:snake, :body], new_body)
  end

  defp move(%{width: w, height: h}, {pos_x, pos_y}, {vec_x, vec_y}) do
    # We use the remainder function `rem` to make the snake appear from the opposite side
    # of the screen when it reaches the limits of the graph.
    x = rem(pos_x + vec_x + w, w)
    y = rem(pos_y + vec_y + h, h)
    {x, y}
  end

  def handle_input({:key, {"left", :press, _}}, _context, state) do
    {:noreply, update_snake_direction(state, {-1, 0})}
  end

  def handle_input({:key, {"right", :press, _}}, _context, state) do
    {:noreply, update_snake_direction(state, {1, 0})}
  end

  def handle_input({:key, {"up", :press, _}}, _context, state) do
    {:noreply, update_snake_direction(state, {0, -1})}
  end

  def handle_input({:key, {"down", :press, _}}, _context, state) do
    {:noreply, update_snake_direction(state, {0, 1})}
  end

  # Ignore all the other inputs
  def handle_input(_input, _context, state), do: {:noreply, state}
  # Change the snake's current direction.
  defp update_snake_direction(state, direction) do
    put_in(state, [:snake, :direction], direction)
  end
end
