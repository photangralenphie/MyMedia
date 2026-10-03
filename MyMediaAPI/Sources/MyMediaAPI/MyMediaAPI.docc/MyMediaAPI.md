# ``MyMediaAPI``

Access a running MyMedia library through a read-only HTTP API.

## Overview

MyMedia embeds a Hummingbird server on the port selected in **Settings > API**
(8080 by default). The API can be disabled completely, started automatically,
or controlled manually. The interactive Scalar API reference is available at
`/api-docs`, the generated DocC website is available at `/docs`, and the
machine-readable OpenAPI 3.1 specification is served at `/openapi.yaml`.

The API listens on all network interfaces. It does not currently authenticate
requests, so only run it on a trusted network.

### Identity

Every `id` is the UUID stored in the corresponding `Movie`, `TvShow`, `Episode`,
or `MediaCollection` model's `id` property.

### Metadata and video separation

Metadata responses contain artwork links but never video links. All artwork is
served by `/api/v1/artwork/{id}`. Add `maxSize` to request a resized JPEG, or
omit it for the original artwork. Stream a movie or episode with `GET /api/v1/videos/{id}`, or
download it with `GET /api/v1/videos/{id}/download`.

### Pagination

List endpoints accept `page` and `perPage`. `page` starts at 1. When `perPage`
is omitted, MyMedia uses the page size configured in Settings (50 by default).
The maximum request page size is 200.

## Topics

### Using the API

- <doc:Endpoints>
- <doc:StreamingVideo>
