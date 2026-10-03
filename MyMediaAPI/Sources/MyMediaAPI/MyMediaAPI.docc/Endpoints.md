# API Endpoints

Use the interactive Scalar API reference for complete parameter and response schemas.

## Library metadata

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/api/v1/appearance` | Effective light/dark scheme and app accent color |
| `GET` | `/api/v1/movies` | Paginated, filterable movie previews |
| `GET` | `/api/v1/movies/{id}` | Complete movie metadata |
| `PATCH` | `/api/v1/movies/{id}` | Set watched, favorite, pinned, or playback-progress values |
| `GET` | `/api/v1/tv-shows` | Paginated, filterable TV show previews |
| `GET` | `/api/v1/tv-shows/{id}` | Complete show metadata and episode previews |
| `PATCH` | `/api/v1/tv-shows/{id}` | Set watched, favorite, or pinned values |
| `GET` | `/api/v1/episodes/{id}` | Complete episode metadata |
| `PATCH` | `/api/v1/episodes/{id}` | Set watched, favorite, pinned, or playback-progress values |
| `GET` | `/api/v1/people/{name}` | Person metadata and role-grouped movie and episode previews |
| `GET` | `/api/v1/collections` | Paginated collection previews |
| `POST` | `/api/v1/collections` | Create a collection, optionally with initial media items |
| `GET` | `/api/v1/collections/{id}` | Complete collection metadata and item previews |
| `PATCH` | `/api/v1/collections/{id}` | Add or remove media items, or set the pinned value |

## Appearance

`GET /api/v1/appearance` returns the effective `light` or `dark` color scheme
currently used by MyMedia and the user's current macOS accent color as a
CSS-compatible uppercase sRGB hex value. Request it again when the user's
system appearance or accent-color setting may have changed.

## Library updates

Movie and episode PATCH requests accept any combination of `isWatched`,
`isFavorite`, `isPinned`, and `progressMinutes`. TV shows accept the three
Boolean fields; setting `isWatched` updates all episodes in the show.
`progressMinutes` must be between zero and the item's duration.

Create a collection with a `title`, an optional `collectionDescription`, and
an optional `mediaItemIDs` array. Patch an existing collection with `add` and
`remove` UUID arrays, and optionally `isPinned`. An ID cannot appear in both
arrays in one request.

## Movie and TV-show filters

The movie and TV-show list endpoints distinguish filtering from pagination:

| Query parameter | Type | Filter behavior |
| --- | --- | --- |
| `minYear` | Integer | Requires a release year greater than or equal to this value. |
| `maxYear` | Integer | Requires a release year less than or equal to this value. |
| `minLength` | Integer | Requires a duration greater than or equal to the supplied minutes. |
| `maxLength` | Integer | Requires a duration less than or equal to the supplied minutes. |
| `isFavorite` | Boolean | `true` returns favorites; `false` returns non-favorites. |
| `isWatched` | Boolean | `true` returns watched items; `false` returns unwatched items. |
| `genre` | Comma-separated strings | Requires at least one matching genre, matched case-insensitively. |

All supplied filters are combined with AND. They are applied before results are
sorted and paginated. `page` and `perPage` control pagination and are not
filters. Within the `genre` list, matching uses OR. For example,
`?minYear=1990&maxYear=1999&genre=Action,Comedy` returns items released in the
1990s that have either the Action or Comedy genre. For TV shows, length is the
sum of all episode durations.

## People and credits

Movie and episode `credits` objects return person names. URL-encode one of
those names as the path component in `/api/v1/people/{name}` to retrieve the
person's roles, credited movies and episodes, and previews grouped under the
same `cast`, `directors`, `coDirectors`, `screenwriters`, `producers`,
`executiveProducers`, and `composer` credit keys. Person-name matching ignores
case, diacritics, and character width.

## Discovery

`/api/v1/search` accepts a required `query`, plus `scope` (`all`, `title`,
`description`, or `credits`). It always searches movies, TV shows, and episodes.
Search comparisons ignore case, diacritics, and character width.

Use `/api/v1/genres` to list genres and `/api/v1/genres/{genre}` to list items
in one genre. Both accept `kind=movies`, `kind=tvShows`, or `kind=both`.

The `/api/v1/favorites` and `/api/v1/pinned` endpoints return paginated
mixed-item previews. `/api/v1/unwatched` returns unwatched movies and TV shows;
it does not include individual episodes.

## Assets

All artwork is available from `/api/v1/artwork/{id}`. Omit `maxSize` to receive
the original bytes, or use `?maxSize=600` to receive a JPEG whose largest pixel
dimension is at most 600. List previews use the size configured in Settings.
Video bytes are only available from the dedicated streaming and download endpoints.
