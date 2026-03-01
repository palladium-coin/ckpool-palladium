# ckpool-palladium

Ultra-low overhead mining pool for Palladium (PLM) cryptocurrency. Built on ckpool's proven architecture with SHA256 support, multi-process design, and Stratum v1 protocol. Features efficient share validation, variable difficulty adjustment, and ZMQ block notifications. Optimized for scalability and minimal latency.

## About Palladium

Palladium (PLM) is a SHA256-based cryptocurrency. This mining pool software provides professional-grade infrastructure for both solo and pool mining operations.

## About This Fork

This project is a fork of [ckpool](https://bitbucket.org/ckolivas/ckpool) by Con Kolivas, specifically adapted for the Palladium blockchain.

**Fork Details:**
- Forked from ckpool commit: `590fb2a2` (8-12-2025)
- Original repository: https://bitbucket.org/ckolivas/ckpool
- Modifications for Palladium (PLM) cryptocurrency

## Key Features

- **Ultra-Low Overhead**: Hand-coded in C with minimal dependencies for maximum performance
- **Multi-Process Architecture**: Separate processes for connector, stratifier, and generator
- **Stratum v1 Protocol**: Full compatibility with standard mining clients (cgminer, cpuminer, etc.)
- **Variable Difficulty (vardiff)**: Automatic difficulty adjustment per worker
- **Solo Mining Mode**: Built-in support for solo mining with `-B` flag
- **Multiple Deployment Modes**: Pool, solo, proxy, passthrough, redirector, and node modes
- **ZMQ Block Notifications**: Real-time blockchain updates via ZeroMQ
- **Efficient Share Validation**: SHA256 hashing with hardware acceleration (SHA-NI, AVX2)
- **Detailed Statistics**: Per-pool and per-client accurate tracking
- **Flexible Configuration**: JSON-based configuration with sensible defaults

## Docker (with palladium-stack)

This is the recommended setup. The pool runs in a container attached to the `palladium-net` Docker network created by [palladium-stack](https://github.com/palladium-coin/palladium-stack), which already provides the node (`palladiumd`), ElectrumX, and the dashboard.

### Prerequisites

- [palladium-stack](https://github.com/palladium-coin/palladium-stack) running and synced
- `palladium-net` Docker network active (`docker network ls | grep palladium-net`)

### Configuration

Edit `ckpool.conf` — it is already pre-configured for Docker, only `btcaddress` and the RPC credentials need to be set:

```json
{
  "btcd": [{
    "url": "palladiumd:2332",
    "auth": "<rpcuser>",
    "pass": "<rpcpassword>",
    "notify": true
  }],
  "btcaddress": "<your PLM address>",
  "btcsig": "/mined by ckpool-plm/",
  "blockpoll": 100,
  "donation": 2.0,
  "nonce1length": 4,
  "nonce2length": 8,
  "update_interval": 30,
  "version_mask": "1fffe000",
  "dropidle": 0,
  "serverurl": ["0.0.0.0:3333", "0.0.0.0:4444"],
  "mindiff": 1,
  "startdiff": 42,
  "maxdiff": 0,
  "highdiff": 100000,
  "zmqblock": "tcp://palladiumd:28332",
  "logdir": "/var/log/ckpool"
}
```

- `btcd.url` / `zmqblock`: use the `palladiumd` hostname (Docker internal DNS, resolves to the node container)
- `btcaddress`: pool operator's address in solo mode (donation recipient); pool's address in pool mode (block reward recipient)
- `logdir`: must be `/var/log/ckpool` (absolute) — maps to `./logs/` on the host via the bind mount in `docker-compose.yml`
- RPC credentials must match `palladium-stack/.palladium/palladium.conf`

### Mining modes

Two modes are supported. Choose based on your use case.

#### Solo mode (default)

Each miner mines directly to their own PLM address. When a block is found, the reward goes entirely to that miner (minus the 2% donation). No payout logic required on the pool side.

`btcaddress` in `ckpool.conf` is the **pool operator's** address (receives the donation).
Miners authenticate with: `username = their PLM address`, `password = anything`.

This is the default — the image CMD already includes `-B`.

#### Private pool mode

All block rewards go to the pool's `btcaddress`. The pool operator is responsible for tracking shares and distributing payouts. ckpool records per-miner share stats in `logs/users/`.

Set `btcaddress` to the **pool's** PLM address. Miners still authenticate with their own address as username for share tracking.

To switch to pool mode, override the command in `docker-compose.yml`:

```yaml
services:
  ckpool:
    command: ["-c", "/etc/ckpool/ckpool.conf"]  # no -B flag
```

### Start

```bash
docker compose build
docker compose up -d

# Check logs
docker logs -f ckpool
```

### Exposed ports

| Port | Use |
|------|-----|
| `3333` | Stratum standard (variable difficulty) |
| `4444` | Stratum high-diff (high-hashrate ASICs) |

### Logs

Logs are written to `./logs/` and are readable from the host and other containers:

```
logs/ckpool.log       # main log
logs/pool/pool.status # pool statistics
logs/users/           # per-miner address statistics
```

To read them from another container, add to its compose file:

```yaml
volumes:
  - /path/to/ckpool-palladium/logs:/ckpool-logs:ro
```

---

## Quick Start (without Docker)

### Prerequisites

**System Requirements:**
- Linux operating system (64-bit only)
- **Note**: This software does NOT support 32-bit systems or Windows

**Tested Platforms:**
- x86_64 (Ubuntu)
- ARM64 (Debian - tested on Raspberry Pi)


**Building from GitHub/Git clone** (recommended):
```bash
sudo apt-get install build-essential yasm autoconf automake libtool libzmq3-dev pkgconf
```

### Building

```bash
./autogen.sh
./configure
make

# Optional: Install system-wide
sudo make install
```

### Configuration

> **Note**: `ckpool.conf` in this repo is pre-configured for Docker. For native use, copy this config instead:

```json
{
  "btcd": [{
    "url": "127.0.0.1:2332",
    "auth": "<rpcuser>",
    "pass": "<rpcpassword>",
    "notify": true
  }],
  "btcaddress": "<your PLM address>",
  "btcsig": "/mined by ckpool-plm/",
  "blockpoll": 100,
  "donation": 2.0,
  "nonce1length": 4,
  "nonce2length": 8,
  "update_interval": 30,
  "version_mask": "1fffe000",
  "dropidle": 0,
  "serverurl": ["0.0.0.0:3333", "0.0.0.0:4444"],
  "mindiff": 1,
  "startdiff": 42,
  "maxdiff": 0,
  "highdiff": 100000,
  "zmqblock": "tcp://127.0.0.1:28332",
  "logdir": "logs"
}
```

- `btcd.url` / `zmqblock`: use `127.0.0.1` to connect to a locally running `palladiumd`
- `btcaddress`: your PLM address (solo mode) or the pool's address (pool mode)
- `logdir`: relative path — logs are written to `./logs/` relative to where you run ckpool

### Running

> **Note on other modes**: proxy, node, passthrough, and redirector modes are available in upstream ckpool but not yet adapted for Palladium. Only solo and pool modes are supported.

#### Solo mode

Each miner mines to their own PLM address. Block rewards go directly to the miner. No payout system needed.

Set `btcaddress` to the **pool operator's** address (donation recipient).
Miners connect with: `username = their PLM address`, `password = anything`.

```bash
./ckpool -B -c ckpool.conf
```

#### Private pool mode

All block rewards go to the pool's `btcaddress`. ckpool tracks shares per miner in `logs/users/`. The pool operator handles payouts.

Set `btcaddress` to the **pool's** PLM address.
Miners connect with: `username = their PLM address` (for share tracking), `password = anything`.

```bash
./ckpool -c ckpool.conf
```

## Mining Client Configuration

Point your mining client to the pool:

**cgminer / bfgminer:**
```bash
cgminer -o stratum+tcp://pool-address:3333 -u YOUR_PLM_ADDRESS -p x
```

**cpuminer:**
```bash
cpuminer -a sha256d -o stratum+tcp://pool-address:3333 -u YOUR_PLM_ADDRESS -p x
```

## Documentation

- [Original ckpool README](README-CKPOOL.md) - Complete feature documentation
- [Solo Mining Guide](README-SOLOMINING) - Detailed solo mining setup

## Support

- **Issues**: Report bugs via GitHub Issues
- **Email**: davide.grilli@outlook.com
- **Original ckpool**: https://bitbucket.org/ckolivas/ckpool

## Credits

**Original ckpool:**
- Con Kolivas <kernel@kolivas.org> - Core author and maintainer
- Andrew Smith - ckdb author

**Palladium Fork:**
- Davide Grilli <davide.grilli@outlook.com> - Maintainer

See [AUTHORS](AUTHORS) for complete contributor list.

## License

GNU General Public License v3.0

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

See [COPYING](COPYING) for full license text.

## Acknowledgments

Special thanks to Con Kolivas for creating and maintaining the exceptional ckpool software that powers this Palladium mining pool.
