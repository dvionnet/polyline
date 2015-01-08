defmodule PolylineTest do
  use ExUnit.Case
  import Polyline

  @start_loc {48.8468847, 2.3651841}
  @end_loc {48.8403298, 2.374037}
  @polyline '_lciHk}lMBGDE@AR_@\\UNMTSh@i@d@i@X]vAiB@AHM@C|AaCh@}@`@o@Vc@JUDIDKBKDKDOBO@MDWFa@@I@GBKDKFSDGJUl@}@d@q@@CBEXa@@A?A@??A@ADG?AFGXc@?A@APWBGBCBE`@k@`@m@^i@d@u@z@kAj@u@DE~@kAlC_Dz@aA'

  defp round_coord({a, b}, n), do: {Float.round(a, n), Float.round(b, n)}
  defp e5_to_deg({a, b}), do: { a / 1.0e5, b / 1.0e5 } |> round_coord 5

  test "start location is the first tuple in the offset list and the point list" do
    {:ok, offsets} = to_offset_list @polyline
    {:ok, points} = to_point_list @polyline
    assert e5_to_deg(hd offsets) == round_coord @start_loc, 5
    assert (hd points) == round_coord @start_loc, 5
  end

  test "end location is the last tuple in the point list" do
    {:ok, points} = to_point_list @polyline
    assert (List.last points) === round_coord @end_loc, 5
  end

  test "polyline is the same after decoding and encoding" do
    {:ok, offsets} = to_offset_list @polyline
    {:ok, polyline} = make_polyline offsets
    assert polyline === @polyline
  end

  doctest Polyline

end
