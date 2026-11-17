# Local models

The desktop host serves language models on demand. Nothing runs until a client connects.

## Request path

A socket starts a proxy on the first connection. The proxy forwards to llama-swap, which reads the requested model, starts `llama-server` for it, and swaps models as clients ask for different ones.

The server is started with GPU offload and the tool-call support OpenCode needs.

## Shutdown

A model held in VRAM holds the GPU, so shutdown happens in two stages:

- llama-swap unloads a model after it has been idle.
- The proxy exits after a longer idle period, and systemd stops llama-swap with it.

The first request after an idle period waits for the model to load. That can take a while for a large model, so the health check waits and the client has no request timeout.

## Models

Models live on the data disk and are listed in one attribute. OpenCode reads the same set, so adding a model there adds it to the editor too. Nothing fetches the files; they have to be on the disk already.

## Access

The service is loopback-only. Tunnel to it from the tailnet:

```bash
ssh -L 8080:127.0.0.1:8080 miningpinguin@d-mk4-1
```

See [Network](network.md#tailnet-ssh).

## Graphics

The stack uses Vulkan, so it needs hardware graphics. This config never sets that on purpose: the desktop's X server makes nixpkgs turn it on. If the Vulkan drivers stop loading, see [Architecture](architecture.md#hardware-graphics).
