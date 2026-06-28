# sane-backends

`upstream/` is the original SANE backend repository:

```text
https://gitlab.com/sane-project/backends.git
```

This project keeps it as a submodule because the main repo will live on GitHub while SANE is hosted on GitLab.

`f3200.patch` is the local F-3200 change. It:

- adds USB product ID `04b8:080a`;
- changes F-3200 from unsupported to untested;
- enables extended identity discovery for ESC/I command level `D8`.

Apply it after cloning:

```sh
git submodule update --init sane-backends/upstream
git -C sane-backends/upstream apply ../f3200.patch
```

Build a local `scanimage`:

```sh
brew install pkg-config libusb

mkdir -p build/sane-backends local/sane-f3200
cd build/sane-backends

../../sane-backends/upstream/configure \
  --prefix="$PWD/../../local/sane-f3200" \
  --disable-locking \
  --disable-nls \
  --without-gphoto2 \
  --without-v4l \
  --without-snmp \
  --without-avahi \
  --without-libjpeg \
  --without-libtiff \
  --without-libpng \
  BACKENDS=epson2 \
  PRELOADABLE_BACKENDS=epson2

make -j"$(sysctl -n hw.ncpu)"
make install
cd ../..
```

Verify:

```sh
local/sane-f3200/bin/scanimage --version
local/sane-f3200/bin/scanimage -L
```
