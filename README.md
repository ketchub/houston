# Ketch
---

This is the root repository for the entire Ketch stack. To run locally, you'll need Docker (+ Compose) and GNU Make tools.

```
$: git clone --recursive https://github.com/ketchub/houston
$: cd houston && make start
```

> http://localhost:8080 (web UI)

> http://localhost:8081 (rethink admin)

To access the web UI via https (using a self-signed cert), ensure you have an entry in your hosts file pointing at your loopback address 127.0.0.1 (or 0.0.0.0) with at least one ".", eg:
```
127.0.0.1   lo.cal
```

> https://lo.cal:4433

---

Misc. *todos*:
- Ensure NTP on all system services
