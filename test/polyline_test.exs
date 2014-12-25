defmodule PolylineTest do
  use ExUnit.Case
  import Polyline

  @start_loc {48.8468847, 2.3651841}
  @end_loc {48.8403298, 2.374037}
  @polyline '_lciHk}lMBGDE@AR_@\\UNMTSh@i@d@i@X]vAiB@AHM@C|AaCh@}@`@o@Vc@JUDIDKBKDKDOBO@MDWFa@@I@GBKDKFSDGJUl@}@d@q@@CBEXa@@A?A@??A@ADG?AFGXc@?A@APWBGBCBE`@k@`@m@^i@d@u@z@kAj@u@DE~@kAlC_Dz@aA'

  test "start location is the first tuple in the offset list and the point list" do
    {lat, lng} = @start_loc
    start_loc = {e5(lat), e5(lng)}
    {:ok, offsets} = to_offset_list @polyline
    {:ok, points} = to_point_list @polyline
    assert (hd offsets) == start_loc
    assert (hd points) == start_loc
  end

  test "end location is the last tuple in the point list" do
    {lat, lng} = @end_loc
    end_loc = {e5(lat), e5(lng)}
    {:ok, points} = to_point_list @polyline
    assert (List.last points) === end_loc
  end

  test "polyline is the same after decoding and encoding" do
    {:ok, offsets} = to_offset_list @polyline
    {:ok, polyline} = make_polyline offsets
    assert polyline === @polyline
  end

end
