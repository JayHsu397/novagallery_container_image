# NovaGallery Container Image

Unofficial container image of [novafacile/novagallery](https://github.com/novafacile/novagallery).

Powered by [novafacile](https://novafacile.com/)

## 1. Features

This container image packages NovaGallery on top of openSUSE Leap and provides an out-of-the-box deployment experience with minimal configuration.

What it does:

- Builds the Apache and PHP environment required by NovaGallery.
- Allows users to adjust the `url` in `site.php` and the Apache `ServerName` in the vhost configuration file by setting environment variables at container runtime.
- Supports generating `addons.php` at container runtime, including `Password Protection`, `Robots Meta Tag`, and the basic switch for `novaGallery Pro`.
- Automatically generates a password hash for `Password Protection` when private mode is enabled.
- Tries to keep the runtime logic simple and predictable instead of introducing an overly complex entrypoint design.

This image is intended to be simple and practical:

- If the required config files do not exist yet, the container generates them at startup.
- If a custom `site.php`, `addons.php`, or Apache vhost configuration is already present, the container will not overwrite it.
- This makes it possible to start with environment variables first, and later switch to bind-mounted custom configuration files if you need more control.

To be more specific:

- Environment variables only affect the initial generation of configuration files.
- If the files already exist inside the container, or are bind-mounted by the user, the container will not overwrite them.
- Runtime boolean addon-related environment variables are validated before config generation.
- Supported boolean values are strictly `true` and `false`.

To understand how this actually works, please read [`start.sh`](https://github.com/JayHsu397/novagallery_container_image/blob/main/start.sh).

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

This is the simplest way to start the container.

Notes:

- The gallery content should be mounted into `/var/www/novagallery-free/galleries`.
- Without an additional storage mount, cache-related files will remain inside the container filesystem.
- For testing or temporary use, this may be acceptable.
- For long-term use, mounting the storage directory is recommended.

Recommended startup command with persistent storage, custom URL settings, and private mode (password mode) enabled:

```bash
podman run -p your-port:80 \
  -v /path/to/photos:/var/www/novagallery-free/galleries:z \
  -v /path/to/storage:/var/www/novagallery-free/storage:z \
  -e SERVER_NAME=your-ip-or-domain \
  -e URL=http://your-ip-or-domain:your-port \
  -e ADDONS_PRIVATE_MODE_ENABLE=true \
  -e PASSWORD=your-password \
  ghcr.io/jayhsu397/novagallery:latest
```

This is the more practical setup for normal self-hosting use.

Notes:

- `SERVER_NAME` is used for the Apache vhost configuration.
- `URL` is written into NovaGallery's `site.php`.
- When `ADDONS_PRIVATE_MODE_ENABLE=true`, `PASSWORD` must also be provided if `addons.php` does not already exist.
- The password itself is not written directly into `addons.php`; a password hash is generated instead.
- If your own `addons.php` is already bind-mounted or already exists in the container, the container will not regenerate it.

If you want to explicitly disable search engine indexing through the built-in addon, you may additionally set:

```bash
-e ADDONS_ROBOTS_META_TAG_ENABLE=true \
-e ADDONS_ROBOTS_META_TAG_ALLOW_INDEX=false
```

You may also enable the `novaGallery Pro` entry in `addons.php` by setting:

```bash
-e ADDONS_NOVAGALLERY_PRO_ENABLE=true
```

Please note that addon-related boolean values must use `true` or `false`.  
Values such as `yes`, `no`, `1`, or `0` are not accepted by the startup script.

### 2-2. Quadlet

If you use systemd as your init system and want the container to start on boot, `Quadlet` may satisfy your needs.

Example with private mode enabled, placed in `$HOME/.config/containers/systemd/novagallery.container`

```Quadlet
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
Environment=ADDONS_PRIVATE_MODE_ENABLE=true
Environment=PASSWORD=your-password
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
systemctl --user daemon-reload
systemctl --user start novagallery
```

If you want the service to start automatically after login or boot, you may also want:

```bash
systemctl --user enable novagallery
```

## 3. Environment Variables

| Name | Description |
| - | - |
| `SERVER_NAME` | The `ServerName` used in the Apache vhost configuration |
| `URL` | The site URL written into `/var/www/novagallery-free/config/site.php` |
| `ADDONS_PRIVATE_MODE_ENABLE` | Enables the built-in `Password Protection` addon in `addons.php` |
| `PASSWORD` | The plain password used to generate the password hash automatically when private mode is enabled |
| `ADDONS_ROBOTS_META_TAG_ENABLE` | Enables the built-in `Robots Meta Tag` addon in `addons.php` |
| `ADDONS_ROBOTS_META_TAG_ALLOW_INDEX` | Controls whether search engines are allowed to index the gallery when `Robots Meta Tag` is enabled |
| `ADDONS_NOVAGALLERY_PRO_ENABLE` | Enables the `novaGallery Pro` entry in `addons.php` |

Additional notes:

- Boolean variables must use `true` or `false`.
- The startup script normalizes addon-related boolean values to lowercase before validation.
- `PASSWORD` is only required when private mode is enabled and `addons.php` still needs to be generated.
- These variables are meant for initial config generation, not for rewriting existing config files on every startup.

## 4. Volumes

| Path inside container | Purpose |
| - | - |
| `/var/www/novagallery-free/galleries` | Stores photo galleries |
| `/var/www/novagallery-free/storage` | Stores cache files that help accelerate photo loading when you restart the gallery |

Notes:

- Mounting `galleries` is normally required if you want your photo data to live outside the container.
- Mounting `storage` is strongly recommended if you want cache-related data to persist across container recreation or restart.
- On SELinux-enabled systems, keep the `:z` or `:Z` suffix on bind mounts.

## 5. Extended Features and Configurations

This image provides a basic environment based on the official examples.

If you need more customized features, please visit [the source repo of NovaGallery](https://github.com/novafacile) and bind your own configuration file into the container.

This image intentionally keeps the startup logic simple:

- It uses runtime file generation only when needed.
- It avoids overwriting existing configuration files.
- It is intended for normal URL values and normal self-hosting use cases.

If you want something more customized, it is completely acceptable to:

- bind your own `site.php`
- bind your own `addons.php`
- bind your own Apache vhost configuration
- modify [`start.sh`](https://github.com/JayHsu397/novagallery_container_image/blob/main/start.sh) for your own deployment needs

## 6. License

This repository is a packaging project.

- My original packaging files, including `Containerfile` and `start.sh`, are licensed under MIT.
- The packaged upstream software, [NovaGallery](https://github.com/novafacile/novagallery), is licensed under AGPL-3.0-or-later.
- As a result, this repository should not be understood as MIT-only.
