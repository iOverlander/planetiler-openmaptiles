# Planetiler OpenMapTiles - iOverlander Fork

## What this repo does

Generates vector map tiles (.mbtiles) from OpenStreetMap data using Planetiler. This is a fork of the upstream OpenMapTiles schema with lower zoom thresholds so iOverlander maps show more detail (roads, labels, town names) at lower zoom levels.

This repo is only for **tile generation**. Tile serving (styles, config, deployment) lives in the [tiles](https://github.com/iOverlander/tiles) repo.

## Key files

- `src/main/java/org/openmaptiles/layers/Transportation.java` — Road zoom thresholds. Two control points:
  - `MINZOOMS` map (~line 197): primary zoom level for each road class
  - `switch` statement (~line 582): overrides MINZOOMS for service/track/path roads. **Both must be updated** when changing road visibility.
- `src/main/java/org/openmaptiles/layers/TransportationName.java` — Road label/shield zoom thresholds (~line 246)
- `src/main/java/org/openmaptiles/layers/Place.java` — Town/city label grid limits (~line 114)
- `Dockerfile` — Multi-stage build for custom Docker image
- `.dockerignore` — Excludes data/, target/, .git/ from Docker context

## Important: tile data vs style minzoom

Zoom thresholds are controlled in **two places**:
1. **Tile data** (this repo) — what features are included in tiles at each zoom level
2. **Style JSON** (tiles repo) — what features are rendered at each zoom level

Both must agree. If you lower a road's minzoom here, also update the corresponding style layer minzoom in the tiles repo.

## Building and running

```bash
# Build Docker image
docker build -t ioverlander-planetiler .

# Generate test tiles (Monaco)
docker run --rm -v "$(pwd)/data":/data ioverlander-planetiler \
  --force --download --area=monaco

# Generate planet (~3h on 16 cores)
docker run --rm -v "$(pwd)/data":/data \
  -e JAVA_TOOL_OPTIONS="-Xmx110g" \
  ioverlander-planetiler \
  --download --area=planet --bounds=planet \
  --download-threads=10 --download-chunk-size-mb=1000 \
  --fetch-wikidata \
  --force --output=data/planet.mbtiles \
  --nodemap-type=array --storage=mmap
```

## Output

Generated `.mbtiles` files go to `data/`. These are gitignored. The planet file (~96GB) is mounted into the tileserver via docker-compose in zarbazan-infra.

## Related repos

- [tiles](https://github.com/iOverlander/tiles) — Tile server config, styles, fonts, deployment scripts
- [zarbazan-infra](../zarbazan-infra) — Docker compose for tileserver, cloudflared tunnel
