# Polyline

Polyline is a tool to decode and encode polylines in **Google Maps API**. It can be useful if you want to bypass the limit of 25 WayPoints when querying Google API for directions. You get much more coordinates by decoding the polyline used to draw the path on the map.

See the [Google Maps API Documentation][1] for a description of the algorithm used to encode polylines.

## Encode

### List of Offsets

```iex
iex> Polyline.to_offset_list '_p~iF~ps|U_ulLnnqC_mqNvxq`@'
{:ok, [{3850000, -12020000}, {220000, -75000}, {255200, -550300}]}

```

### List of Coordinates

```iex
iex> Polyline.to_point_list '_p~iF~ps|U_ulLnnqC_mqNvxq`@' 
{:ok, [{3850000, -12020000}, {4070000, -12095000}, {4325200, -12645300}]}
```

## Decode

```iex
iex> Polyline.make_polyline [{38.5, -120.2}, {4070000, -12095000}, {4325200, -12645300}]
{:ok, '_p~iF~ps|U_flwFn`faV_t~fGfzxbW'}
```

## License

Copyright (c) 2014 David Vionnet. See the LICENSE file for license rights and limitations (MIT).

[1]: https://developers.google.com/maps/documentation/utilities/polylinealgorithm
