# Piping Server in D

## Required

- D Compiler [(DMD|LDC|GDC)](https://dlang.org/download.html)

## How to run

```bash
# build and run
dub --build=release --parallel
# build only
dub build --build=release --parallel
```

## Server-side help

```bash
Piping Server in D
Usage: piping-server [OPTIONS]
Options:
  --host <HOST>              Bind address, either IPv4 or IPv6 (e.g. 127.0.0.1, ::1) [default: 0.0.0.0]
  --http-port <HTTP_PORT>    HTTP port [default: 0]
  --enable-https             Enable HTTPS
  --https-port <HTTPS_PORT>  HTTPS port
  --crt-path <CRT_PATH>      Certification path
  --key-path <KEY_PATH>      Private key path
  -h, --help                 Print this help message
  -V, --version              Print version information
```

## Acknowledgement

- [Ryo Ota](https://github.com/nwtgck) original author from Piping Server

## Other implementations
* Original: <https://github.com/nwtgck/piping-server>
* Rust: <https://github.com/nwtgck/piping-server-rust>
* Go: <https://github.com/nwtgck/go-piping-server>
* Zig: <https://github.com/nwtgck/piping-server-zig>