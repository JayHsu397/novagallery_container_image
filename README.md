## Highlights
- Added boolean validation for runtime environment variables used by addon-related configuration.
- Invalid values are now rejected early during container startup instead of being silently written into generated config files.
- This improves the reliability of runtime-generated `addons.php` while keeping the image simple and lightweight.
- The image continues to provide runtime generation for `site.php`, Apache vhost configuration, and `addons.php`.
- Private mode remains supported through environment variables, including automatic password hash generation when enabled.

## What this image provides
This container image packages NovaGallery on top of openSUSE Leap and aims to provide a simple deployment experience with minimal setup.

At runtime, it can generate:
- `site.php`
- Apache vhost configuration
- `addons.php`

It also supports:
- adjusting the site URL through `URL`
- adjusting Apache `ServerName` through `SERVER_NAME`
- enabling built-in addon options such as:
  - `Password Protection`
  - `Robots Meta Tag`
  - the basic switch for `novaGallery Pro`

If private mode is enabled, the container can automatically generate the password hash from the plain `PASSWORD` environment variable.

As before, if users bind-mount their own `site.php`, `addons.php`, or Apache vhost configuration, the container will not overwrite them.

## Behavior Notes
- Environment variables only affect the initial generation of configuration files.
- If the target config file already exists inside the container, generation is skipped.
- If the user bind-mounts their own config file, that file is respected as-is.
- Boolean environment variables must use `true` or `false`.

## Known Restrictions
- This image uses sed-based runtime replacement intentionally to keep the image simple and lightweight.
- It is intended for normal URL values.
- If you want exotic or heavily customized values, adjust [`start.sh`](https://github.com/JayHsu397/novagallery_container_image/blob/main/start.sh) yourself or provide your own config files.
- This repository is a packaging project, not a fork that redesigns NovaGallery itself.

## Container Image
### Image
- GHCR: `ghcr.io/jayhsu397/novagallery:v1.2.0`
- Latest: `ghcr.io/jayhsu397/novagallery:latest`

### Pull
```bash
podman pull ghcr.io/jayhsu397/novagallery:v1.2.0
```

## Quick Example
```bash
podman run -p 8000:80 \
  -v /path/to/photos:/var/www/novagallery-free/galleries:z \
  -v /path/to/storage:/var/www/novagallery-free/storage:z \
  -e SERVER_NAME=127.0.0.1 \
  -e URL=http://127.0.0.1:8000 \
  ghcr.io/jayhsu397/novagallery:v1.2.0
```

Example with private mode enabled:

```bash
podman run -p your-port:80 \
  -v /path/to/photos:/var/www/novagallery-free/galleries:z \
  -v /path/to/storage:/var/www/novagallery-free/storage:z \
  -e SERVER_NAME=your-ip-or-domain \
  -e URL=http://your-ip-or-domain:your-port \
  -e ADDONS_PRIVATE_MODE_ENABLE=true \
  -e PASSWORD=your-password \
  ghcr.io/jayhsu397/novagallery:v1.2.0
```

## License
This repository is a packaging project.

- My original packaging files, including `Containerfile` and `start.sh`, are licensed under MIT.
- The packaged upstream software, [NovaGallery](https://github.com/novafacile/novagallery), is licensed under AGPL-3.0-or-later.
- Therefore, this repository should not be understood as MIT-only.
