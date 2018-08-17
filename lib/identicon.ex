defmodule Identicon do
  @moduledoc """
    Generate Identicon just like the ones from Github in png file
  """

  @doc """
    Main function
  """
  def main(input) do
    # Take input as an argument of hash_input function
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end
  @doc """
    Saves the generated image in png format
  """
  def save_image(image, input) do
    File.write("#{input}.png", image)
  end

  @doc """
    Draw image given by the RGB color and pixel_map, using :egd
  """
  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn ({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  @doc """
    Builds pixel_map
  """
  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map =
      Enum.map(grid, fn {_head, index} ->
        horizontal = rem(index, 5) * 50
        vertical = div(index, 5) * 50

        top_left = {horizontal, vertical}
        bottom_right = {horizontal + 50, vertical + 50}
        {top_left, bottom_right}
      end)

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  @doc """
    Filter out squares in odd code
  """
  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid =  Enum.filter grid, fn{code, _index} ->
      rem(code, 2) == 0
    end

    %Identicon.Image{image | grid: grid}
  end

  @doc """
    Builds 5 x 5 grid, each segment made as {code, index}
  """
  def build_grid(%Identicon.Image{hex: hex} = image) do
    # $ : passing function, /1 : arity of one, takes one argument
    # List of list --(Flatten)--> one list
    grid =
      hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten()
      |> Enum.with_index()

    %Identicon.Image{image | grid: grid}
  end

  @doc """
    Mirrors a row
    ## Examples
  iex> mirror = Identicon.mirror_row([143, 23, 100])
  iex> mirror
  iex> [143, 23, 100, 23, 143]
  """
  def mirror_row(row) do
    # [143, 23, 100]
    [first, second | _tail] = row
    # [143, 23, 100, 23, 143]
    row ++ [second, first]
  end


    @doc """
     Picks color from the first three elements
     "Image is a struct that has a list"
    """
  # |_tail: I know there exists more elements, but I don't care about it
  def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    # First three elements -> R,G,B
    # Take all the properties from image and throw on top a tuple of R, G and B
    %Identicon.Image{image | color: {r, g, b}}
  end

  @doc """
   hashes input value into a list of binary
  """
  def hash_input(input) do
    hex =
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list()

    %Identicon.Image{hex: hex}
  end
end
