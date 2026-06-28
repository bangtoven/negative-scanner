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
cd sane-backends/upstream
git apply ../f3200.patch
```
