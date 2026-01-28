<div align="center">

# 📦 Hytale Container Image

[![Origin: Forgejo](https://img.shields.io/badge/Forgejo-Origin-orange?style=for-the-badge&logo=forgejo&logoSize=auto)](https://forgejo.sakul-flee.de/Containers/Hytale/)
[![Mirror: GitHub](https://img.shields.io/badge/GitHub-Mirror-blue?style=for-the-badge&logo=github&logoSize=auto)](https://github.com/SakulFlee/HytaleContainer/)

A feature rich Container image for running Hytale servers!

</div>

## Features

- Authentication token caching
- Automatic updating upon restart
- [Planned] Mod downloading

## Running

First, start the container:

```bash
# Or use docker!
podman run \
    -itd \
    --name hytale \
    -v hytale:/opt/hytale:U
    -p 5520:5520
    forgejo.sakul-flee.de/containers/hytale:latest
```

Next, the Hytale downloader needs to be authorized.
Check the container logs and follow the instructions:

```bash
podman logs -f hytale
```

After authorization, the latest server files will be downloaded and prepared.
This may take a few minutes based on your internet connection.

Eventually, the Hytale server should start.
Once again, it has to be authorized first.
Exit the logs and attach to the container instead:

```bash
podman attach -it hytale
```

You should have full access to the Hytale server console now.
In the console enter and follow the instructions:

```bash
auth login device
```

Your server should be running and authenticated now.
However, this is only a temporary authentication!
To make this permanent enter:

```bash
auth persistence Encrypted
```

Now, your server should be authenticated even after restarting the container.

> [!WARNING]
> This container automatically checks for updates upon (re-)starting!
> The server will be updated assuming there is a new version **and** your credentials are still valid.
> Otherwise, you will be prompted to re-authenticate.
>
> **None** of your save game, mods, configs, etc. should be affected by this!  
> **Only** the server files will be overwritten!  
> However, mods might struggle after an update.

### Volumes

| Path in container | Description |
| - | - |
| /opt/hytale | Location of the whole Hytale server. This includes saves ("Universe"), mods, configs and server files. |

### Ports

| Port | Protocol | Description |
| - | - | - |
| 5520 | UDP | Hytale Game Port |

## License

This project is licensed under [Apache License 2.0](https://spdx.org/licenses/Apache-2.0.html).
