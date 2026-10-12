# Local language models on d-mk4, served on demand.
{ lib, pkgs, user, ... }:
let
  modelsDir = "/mnt/extra/models";
  port = 8080; # what clients talk to
  backendPort = 8081; # llama-swap, behind the proxy
  defaultContext = 120000;
  modelTtl = 300; # seconds idle before a model is unloaded
  idleExit = "10min"; # idle time before the whole stack stops

  defaultModel = "qwen3.8-27b-iq3";

  # id (what clients ask for) -> file, display name and optional context
  models = {
    "qwen3.8-27b-iq3" = {
      file = "Qwen3.8-27B-UD-IQ3_XXS.gguf";
      title = "Qwen3.8 27B IQ3_XXS";
    };
    "qwen3.8-27b-iq2" = {
      file = "Qwen3.8-27B-UD-IQ2_XXS.gguf";
      title = "Qwen3.8 27B IQ2_XXS";
    };
    "qwen3.6-27b" = {
      file = "Qwen3.6-27B-4bpw-16GB-VRAM.gguf";
      title = "Qwen3.6 27B 4bpw";
    };
    "north-mini-code" = {
      file = "North-Mini-Code-1.0-UD-IQ3_S.gguf";
      title = "North Mini Code 1.0";
    };
    "ornith-1.0-9b" = {
      file = "ornith-1.0-9b-Q8_0.gguf";
      title = "Ornith 1.0 9B Q8_0";
    };
    "ornith-1.5-9b-uncensored" = {
      file = "Ornith-1.5-9B-uncensored.Q4_K_M.gguf";
      title = "Ornith 1.5 9B uncensored Q4_K_M";
    };
    "qwen3.5-9b-defiant" = {
      file = "Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-IQ3_M.gguf";
      title = "Qwen3.5 9B Defiant Fable IQ3_M";
    };
  };

  # defaultContext, unless a model sets its own.
  modelsWith = lib.mapAttrs (_: m: (m // { context = defaultContext; }) // m) models;

  llamaServer = "${pkgs.llama-cpp-vulkan}/bin/llama-server";

  # llama-swap fills in ${PORT} itself, hence the escape.
  swapConfig = (pkgs.formats.yaml { }).generate "llama-swap.yaml" {
    healthCheckTimeout = 300; # a cold 27B load can take a while
    models = lib.mapAttrs (_: m: {
      cmd = lib.concatStringsSep " " [
        llamaServer
        "--port \${PORT}"
        "-m ${modelsDir}/${m.file}"
        "-ngl 999"
        "-c ${toString m.context}"
        "--jinja" # needed for tool calls, which opencode relies on
      ];
      ttl = modelTtl;
    }) modelsWith;
  };
in
{
  systemd.sockets.llm = {
    wantedBy = [ "sockets.target" ];
    listenStreams = [ "127.0.0.1:${toString port}" ];
  };

  # Activated by llm.socket (same name). Starting it pulls llama-swap up.
  systemd.services.llm = {
    requires = [ "llama-swap.service" ];
    after = [ "llama-swap.service" ];
    serviceConfig = {
      ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=${idleExit} 127.0.0.1:${toString backendPort}";
      PrivateTmp = true;
    };
  };

  systemd.services.llama-swap = {
    description = "llama-swap: on-demand model switching";
    # No wantedBy: only the proxy starts it, and it goes away with the proxy.
    unitConfig.StopWhenUnneeded = true;
    serviceConfig = {
      # Runs as the user: the GPU and the model files just work.
      User = user;
      ExecStart = "${pkgs.llama-swap}/bin/llama-swap --config ${swapConfig} --listen 127.0.0.1:${toString backendPort}";
      # Hold the start job until llama-swap answers, so the first request
      # through the proxy does not hit a closed port.
      ExecStartPost = "${pkgs.bash}/bin/bash -c 'until ${pkgs.curl}/bin/curl -sf http://127.0.0.1:${toString backendPort}/health; do sleep 0.2; done'";
      TimeoutStartSec = 30;
    };
  };

  home-manager.users.${user} = {
    home.packages = [ pkgs.llama-cpp-vulkan ];

    # opencode: one provider, every model above.
    xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      model = "llama/${defaultModel}";
      provider.llama = {
        npm = "@ai-sdk/openai-compatible";
        name = "llama.cpp (local)";
        options = {
          baseURL = "http://127.0.0.1:${toString port}/v1";
          timeout = false; # the first request waits for a model to load
        };
        models = lib.mapAttrs (_: m: {
          name = m.title;
          limit = {
            context = m.context;
            output = 8192;
          };
        }) modelsWith;
      };
    };
  };
}
