# tom

Local e-book manager with a browser-based UI. Manages an EPUB/PDF library
on disk, serves a catalog and reader interface over HTTP on `localhost`.

**Status:** early development — nothing works yet.

## Goals

- Single self-contained binary, no runtime dependencies
- Browse, search, and read books in the browser
- Import EPUBs and PDFs, extract and edit metadata
- SQLite storage with full-text search
- Linux and macOS (Windows later)

## Tech

- **Backend:** Zig 0.16, SQLite (via `translate-c`), `std.http`
- **Frontend:** Svelte, Vite, TypeScript — embedded into the binary at build time

## Build

Requires [Zig 0.16+](https://ziglang.org/download/).

```sh
zig build        # compile
zig build test   # run tests
zig build run    # start the server
```

## Project Structure

```
src/           Zig source
frontend/      Svelte/Vite UI (added in a later phase)
testdata/      Fixture files for tests
PLAN.md        Phased development plan
```

## License

AGPL-3.0-or-later — see [LICENSE](LICENSE).
