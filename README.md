# NovaGallery Container Image

Unofficial container image of [novafacile/novagallery](https://github.com/novafacile/novagallery).

Powered by [novafacile](https://novafacile.com/)

## 1. Features

This container image packages NovaGallery on top of openSUSE Leap and provides an out-of-the-box deployment experience with minimal configuration.

What it does:

- Builds the Apache and PHP environment required by NovaGallery.
- Allows users to adjust the `url` in `site.php` and the Apache `ServerName` in the vhost configuration file by setting environment variables at container runtime.

To understand how this works, please read [`start.sh`](https://github.com/JayHsu397/novagallery_container_image/blob/main/start.sh).

## 2. Startup

Pull the container image:

```bash
podman pull ghcr.io/jayhsu397/novagallery:latest
```

### 2-1. Command Line

Minimal startup command  
Visit the gallery at `http://127.0.0.1:8000`

```bash
podman run -p 8000:80 \
  -v /path/to/photos:/var/www/novagallery-free/galleries:z \
  ghcr.io/jayhsu397/novagallery:latest
```

Recommended startup command with persistent storage and custom URL settings:

```bash
podman run -p your-port:80 \
  -v /path/to/photos:/var/www/novagallery-free/galleries:z \
  -v /path/to/storage:/var/www/novagallery-free/storage:z \
  -e SERVER_NAME=your-ip-or-domain \
  -e URL=http://your-ip-or-domain:your-port \
  ghcr.io/jayhsu397/novagallery:latest
```

### 2-2. Quadlet

If you use systemd as your init system and want the container to start on boot, `Quadlet` may satisfy your needs.

```ini
[Unit]
Description=Novagallery Web Image Gallery
Wants=network.target
After=network.target

[Container]
Image=ghcr.io/jayhsu397/novagallery:latest
PublishPort=your-port:80
Volume=/path/to/photos:/var/www/novagallery-free/galleries:z
Volume=/path/to/storage:/var/www/novagallery-free/storage:z
Environment=SERVER_NAME=your-ip-or-domain
Environment=URL=http://your-ip-or-domain:your-port
AutoUpdate=registry
LogDriver=journald

[Service]
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
```

Remember to run the commands below after configuring your Quadlet file:

```bash
systemctl daemon-reload
systemctl start novagallery
```

## 3. Environment Variables

| Name | Description |
| - | - |
| `SERVER_NAME` | The `ServerName` used in the Apache vhost configuration |
| `URL` | The site URL written into `/var/www/novagallery-free/config/site.php` |

## 4. Volumes

| Path inside container | Purpose |
| - | - |
| `/var/www/novagallery-free/galleries` | Stores photo galleries |
| `/var/www/novagallery-free/storage` | Stores cache files that help accelerate photo loading when you restart the gallery |

On SELinux-enabled systems, keep the `:z` or `:Z` suffix on bind mounts.

## 5. Extended Features and Configurations

This image provides a basic environment based on the official examples. If you need more customized features, please visit [the source repo of NovaGallery](https://github.com/novafacile) and bind your own configuration file into the container.

## 6. License

This repository is a packaging project.

- My original packaging files, including `Containerfile` and `start.sh`, are licensed under MIT.
- The packaged upstream software, [NovaGallery](https://github.com/novafacile/novagallery), is licensed under AGPL-3.0-or-later.
- As a result, this repository should not be understood as MIT-only.
