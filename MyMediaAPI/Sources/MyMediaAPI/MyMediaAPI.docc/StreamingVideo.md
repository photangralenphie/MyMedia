# Streaming and Downloading Video

Stream movie or episode bytes without exposing file-system paths.

Both endpoints identify the item with the UUID stored in its model `id`.

## Request a complete file

```http
GET /api/v1/videos/{id} HTTP/1.1
Host: localhost:8080
```

## Request a byte range

Players can seek by sending one byte range:

```http
GET /api/v1/videos/{id} HTTP/1.1
Host: localhost:8080
Range: bytes=1048576-2097151
```

The server responds with `206 Partial Content`, `Accept-Ranges: bytes`, and a
`Content-Range` header. Open-ended (`bytes=1048576-`) and suffix
(`bytes=-1048576`) ranges are supported. Multiple ranges in one request are not
supported and return `416 Range Not Satisfiable`.

MyMedia keeps its security-scoped file access active for the duration of the
stream and releases it when the response finishes.

## Download a file

```http
GET /api/v1/videos/{id}/download HTTP/1.1
Host: localhost:8080
```

The download endpoint streams the same file with a
`Content-Disposition: attachment` header and the original filename.
