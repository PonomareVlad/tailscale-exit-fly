# fly-tailscale-exit

Run a [Tailscale](https://tailscale.com/) exit node on [Fly.io](https://fly.io/) with no public endpoint — all traffic is routed through your Tailnet (via DERP).

## Prerequisites

- [Fly CLI](https://fly.io/docs/flyctl/install/) (`flyctl`)
- A [Fly.io](https://fly.io/) account
- A [Tailscale](https://tailscale.com/) account and an [auth key](https://tailscale.com/kb/1085/auth-keys)

## Setup

1. **Create the Fly app:**

   ```sh
   fly apps create fly-tailscale-exit
   ```

2. **Set the Tailscale auth key as a secret:**

   ```sh
   fly secrets set TAILSCALE_AUTHKEY=tskey-auth-...
   ```

3. **Deploy:**

   ```sh
   fly deploy
   ```

Once deployed, the exit node will appear in your Tailnet. Enable it as an exit node in the [Tailscale admin console](https://login.tailscale.com/admin/machines).

## How it works

```
Internet ──✕──▶ Fly VM (no public IP)
                  └── tailscaled (exit node + SSH)

Tailnet ──────▶ Fly VM ──▶ Internet (exit traffic)
```

- **Tailscale** connects the VM to your Tailnet, advertises it as an exit node, and enables SSH.
- **Fly.io** provides a shared-cpu-1x VM with persistent RootFS for Tailscale state.
- No public IP is allocated — the `fly.toml` has no `[[services]]` or `[http_service]` section.

## Configuration

| Variable | Description |
|---|---|
| `TAILSCALE_AUTHKEY` | Tailscale auth key used to join your Tailnet (set via `fly secrets set`) |
| `TAILSCALE_HOSTNAME` | Optional hostname for the node (default: `fly-<FLY_REGION>`) |

Key settings in `fly.toml`:

| Setting | Value | Notes |
|---|---|---|
| `primary_region` | `fra` | Change to a [region](https://fly.io/docs/reference/regions/) closer to you |
| `vm.size` | `shared-cpu-1x` | Smallest Fly VM tier |
| `vm.persist_rootfs` | `always` | Persist RootFS across restarts and deploys |

### Optional: Auto approve exit nodes

Add the following ACLs in [Tailscale](https://login.tailscale.com/admin/acls/file):

```json
{
  "tagOwners": {
    "tag:fly-exit": ["autogroup:admin"]
  },
  "autoApprovers": {
    "exitNode": ["tag:fly-exit"]
  }
}
```

### Regions

To add more exit nodes in different regions:

```sh
fly scale count 1 --region hkg
fly scale count 1 --region fra

# or multiple at once:
fly scale count 3 --region hkg,fra,ams
```
