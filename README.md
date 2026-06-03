# proto-TOOL_NAME

Proto WASM plugin for **TOOL_NAME**.

## Getting Started

Clone this template and run the initializer to replace all placeholders:

```sh
git clone https://github.com/ORGANIZATION/proto-template.git proto-TOOL_NAME
cd proto-TOOL_NAME
./init.sh
```

The script will prompt for:

| Prompt | Example | Description |
| --- | --- | --- |
| Tool name | `AWS CLI` | Display name used in metadata and docs |
| Plugin ID | `awscli` | Identifier for `proto install <id>` (snake_case) |
| Organization | `ageha734` | GitHub org or user for the repository |
| Author | `ageha734` | `authors` field in Cargo.toml |

After running, all `TOOL_NAME` / `ORGANIZATION` / `USERNAME` placeholders are replaced and `init.sh` can be removed.

## Usage

Add to `.prototools`:

```toml
TOOL_NAME = "x.y.z"

[plugins.tools]
TOOL_NAME = "github://ORGANIZATION/proto-TOOL_NAME"
```

Then:

```sh
proto install TOOL_NAME
```

## Development

### Prerequisites

- Rust (version specified in `rust-toolchain.toml`)
- `wasm32-wasip1` target

### Build

```sh
cargo build --target wasm32-wasip1 --release --features wasm
```

### Test

```sh
cargo test
```

### Lint

```sh
cargo fmt -- --check
cargo clippy --target wasm32-wasip1 --features wasm -- -D warnings
```

## Configuration

Plugin configuration can be set in `.prototools`:

```toml
[tools.tool_name]
dist-url = "https://example.com/releases/{version}/{platform}-{arch}.{ext}"
```

### Placeholders

| Placeholder  | Description                         |
| ------------ | ----------------------------------- |
| `{version}`  | Resolved version                    |
| `{platform}` | `linux`, `darwin`, or `windows`     |
| `{arch}`     | `x86_64`, `aarch64`, etc.           |
| `{ext}`      | `tar.gz` (Unix) or `zip` (Windows)  |

## Release

Releases are automated via GitHub Actions:

1. Push to `master` triggers `auto-release.yaml` which creates a release PR with a pre-release version.
2. Merging the release PR triggers `on-release-merge.yaml` which tags and publishes a draft pre-release.
3. Use `promote-release.yaml` (workflow_dispatch) to promote a pre-release to stable.

## License

[MIT](LICENSE)
