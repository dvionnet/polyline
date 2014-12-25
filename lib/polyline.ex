defmodule Polyline do
  
  @moduledoc """
  Encode and decode the Google Maps API `polyline` format. Implements the
  algorithm described in [Google Maps API Documentation][1]
  
  [1]: https://developers.google.com/maps/documentation/utilities/polylinealgorithm
  """

  import Bitwise, only: :macros

  @doc """
  Converts a (GoogleMapsAPI-flavored) base64-encoded `polyline` to a
  list of points.

  Points are tuples of the form `{latitude, longitude}`.

  `latitude` and `longitude` are signed integers: the rounded value of (degrees * 1e5).

      iex> Polyline.to_point_list '_p~iF~ps|U_ulLnnqC_mqNvxq`@'
      [{3850000, -12020000}, {4070000, -12095000}, {4325200, -12645300}]
  """
  @spec to_point_list(char_list) :: {:ok, [{integer, integer}]}
  def to_point_list polyline do
    { :ok, offset_list } = to_offset_list polyline
    { :ok, offset_list |> Stream.scan(fn({a,b}, {c,d}) -> {a + c, b + d} end)
                       |> Enum.to_list }
  end

  @doc """
  Converts a (GoogleMapsAPI-flavored) base64-encoded `polyline` into a
  list of a start point concatenated with a list of offsets:

  `offset_list = [{start_lat, start_lng}, {offset1, offset2}, ...]`.
    
      iex>  Polyline.to_offset_list '_p~iF~ps|U_ulLnnqC_mqNvxq`@'
      [{3850000, -12020000}, {220000, -75000}, {255200, -550300}]
  """
  @spec to_offset_list(char_list) :: {:ok, [{integer, integer}]}
  def to_offset_list polyline do
    { :ok, polyline |> parse
                    |> Stream.chunk(2)
                    |> Stream.map(&List.to_tuple/1)
                    |> Enum.to_list }
  end

  @doc """
  Encode a list of a start point concatenated with a list of offsets
  into an ASCII string (formatted as a Google Maps API `polyline`).

      iex>  Polyline.make_polyline [{38.5, -120.2}, {220000, -75000}, {255200, -550300}]      
      '_p~iF~ps|U_ulLnnqC_mqNvxq`@'
  """
  @spec make_polyline([{number, number}]) :: {:ok, char_list}
  def make_polyline offset_list do
    { :ok, offset_list |> Enum.flat_map(fn({x,y}) -> encode(x) ++ encode(y) end) }
  end

  @doc """
  Multiply a floating number coordinate in degrees with a factor of
  10,000 and round it to the nearest signed integer. If the input is
  already in the desired format, do nothing.

      iex> Polyline.e5 38.5
      3850000
      iex> Polyline.e5 -2
      -2

  """
  @spec e5(number) :: integer
  def e5(coord) when abs(coord) <= 180 and is_float(coord), do: coord * 1.0e5 |> round
  def e5(coord), do: coord |> round

  defp lshift(n) when n < 0, do: bnot(n <<< 1)
  defp lshift(n), do: n <<< 1

  defp rshift(n, 0), do: n >>> 1
  defp rshift(n, 1), do: bnot(n >>> 1)

  defp encode(n), do: encode(<<(n |> e5 |> lshift)::30>>, [])
  defp encode(<<0::5, t::bitstring>>, []) when t != "", do: encode(t, [])
  defp encode(<<h::5, t::bitstring>>, []), do: encode(t, [h + 63])
  defp encode(<<h::5, t::bitstring>>, acc), do: encode(t, [(bor(h, 32) + 63)|acc])
  defp encode(<<>>, acc), do: acc

  defp parse(polyline), do: parse(polyline, [], [])
  defp parse([h|t], coord, acc) when h >= 95, do: parse(t, [h|coord], acc)
  defp parse([h|t], coord, acc), do: parse(t, [], [(decode [h|coord])|acc])
  defp parse([], [], acc), do: Enum.reverse acc

  defp decode chunk do
    [h|_] = Enum.reverse chunk
    decode(chunk, <<>>) |> :binary.decode_unsigned
                        |> rshift (band (h - 63), 1)
  end
  defp decode([h|t], acc), do: decode(t, <<acc::bitstring, (h - 63)::5>>)
  defp decode([], acc) when bit_size(acc) < 32 do
    diff = 32 - bit_size(acc)
    <<0::size(diff), acc::bitstring>>
  end
  defp decode([], acc), do: acc
end
