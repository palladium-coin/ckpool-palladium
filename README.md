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

## Quick Start

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

Create a `ckpool.conf` file:

```json
{
  "btcd": [{
    "url": "127.0.0.1:<rpcport>",
    "auth": "<rpcuser>",
    "pass": "<rpcpassword>",
    "notify": true
  }],
  "btcaddress" : "plm1qdq3gu2zvg9lyr8gxd6yln4wavc5tlp8prmvfay",
  "btcsig" : "/mined by ckpool-plm/",
  "blockpoll" : 100,
  "donation" : 2.0,
  "nonce1length" : 4,
  "nonce2length" : 8,
  "update_interval" : 30,
  "version_mask" : "1fffe000",
  "dropidle" : 0,
  "serverurl" : ["0.0.0.0:3333"],
  "nodeserver" : ["ckpool.org:3335"],
  "trusted" : ["ckpool.org:3336"],
  "mindiff" : 1,
  "startdiff" : 42,
  "maxdiff" : 0,
  "zmqblock" : "tcp://127.0.0.1:28332",
  "logdir" : "logs"
}
```

### Running

**Important**: This Palladium fork currently supports **standard pool mode only** using `ckpool.conf`. Other modes (proxy, node, passthrough, redirector) are available in the original ckpool but not yet adapted for Palladium.

**Supported Modes:**

**1. Solo Mining Mode** (Recommended for individual miners)
```bash
./ckpool -B -c ckpool.conf
```
- **What it does**: You mine directly to your own Palladium address
- **When to use**: Mining alone, keeping 100% of block rewards (minus 2% donation)
- **Requirements**: Running Palladium daemon (palladiumd) locally

**2. Pool Mode** (For running a public pool)
```bash
./ckpool -c ckpool.conf
```
- **What it does**: Runs a mining pool that accepts connections from multiple miners
- **When to use**: You want to operate a public Palladium mining pool
- **Requirements**: Running Palladium daemon locally, public IP address

**Note on Other Modes:**
- **Proxy mode** (`-p`): Not yet adapted for Palladium
- **Node mode** (`-N`): Not yet adapted for Palladium
- **Passthrough mode**: Not yet adapted for Palladium

These modes may be added in future releases. For now, use the standard pool configuration with either solo (`-B`) or pool mode.

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
