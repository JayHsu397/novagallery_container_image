# NovaGallery Container Image

Unofficial container image of [novafacile/novagallery](https://github.com/novafacile/novagallery).

Powered By [novafacile](https://novafacile.com/)

## Features

This container image packages NovaGallery on top of openSUSE Leap and provides an out-of-the-box deployment experience with minimal configuration.

What it does:

1. Builds the Apache and PHP environment required by NovaGallery.
2. Allows users to adjust the `url` in `site.php` and the Apache `ServerName` in the vhost configuration file by setting environment variables at container runtime.

To understand how this works, please read `start.sh`.

## Startup

Pull the container image:

```bash
podman pull ghcr.io/jayhsu397/novagallery:latest
```

### Command Line

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

## Environment Variables

| Name | Description |
|-|-|
| `SERVER_NAME` | The `ServerName` used in the Apache vhost configuration |
| `URL` | The site URL written into `/var/www/novagallery-free/config/site.php` |

## Volumes

| Path inside container | Purpose |
|-|-|
| `/var/www/novagallery-free/galleries` | Stores photo galleries |
| `/var/www/novagallery-free/storage` | Stores cache that helps accelerate the loading of you photo when you restart the gallery|

## Notes

- Mounting `/var/www/novagallery-free/storage` as a volume is recommended for persistence and faster loading.
- On SELinux-enabled systems, keep the `:z` suffix on bind mounts.
- This image is intended for simple self-hosted deployment.

## Extended features and Configurations

This image provides a basic envirommemt based on official examples ,if you need more customized features ,please visit [the source repo of NovaGallery](https://github.com/novafacile) and bind your own configuaration file into the container.

## License

Though this repo uses MIT License ,this container image includes third-party software such as NovaGallery, which remain licensed under their respective licenses.
