# ChunkHound devenv module
#
# Usage in devenv.yaml:
#   inputs:
#     nix-shared:
#       url: github:itsthatguy/nix-shared
#
#   imports:
#     - nix-shared/modules/devenv/chunkhound.nix
#
# Usage in devenv.nix:
#   {
#     chunkhound.enable = true;
#
#     # Optional overrides:
#     # chunkhound.embedding.model = "nomic-embed-text";
#     # chunkhound.embedding.baseUrl = "http://localhost:11434/v1";
#     # chunkhound.ollama.enable = false;
#     # chunkhound.extraExcludePatterns = [ "**/vendor/**" ];
#   }
#
# Provides:
#   - chunkhound command (wraps chunkhound with config)
#   - chunkhound-setup (pulls the embedding model)
#   - ollama process (via devenv up, if ollama.enable = true)

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.chunkhound;

  defaultExcludes = [
    "**/node_modules/**"
    "**/.git/**"
    "**/dist/**"
    "**/.next/**"
    "**/coverage/**"
    "**/*.lock"
    "**/pnpm-lock.yaml"
    "**/target/**"
    "**/.devenv/**"
    "**/.direnv/**"
  ];

  # Isolated chunkhound paths
  chunkhoundVenv = "$DEVENV_STATE/chunkhound-venv";
  chunkhoundConfig = "$DEVENV_STATE/chunkhound.json";

  # Base config from devenv options
  baseConfigJson = builtins.toJSON {
    embedding = {
      provider = cfg.embedding.provider;
      model = cfg.embedding.model;
      base_url = cfg.embedding.baseUrl;
    };
    llm.provider = cfg.llm.provider;
    indexing.exclude = cfg.excludePatterns ++ cfg.extraExcludePatterns;
    mcp.transport = "stdio";
  };
in
{
  options.chunkhound = {
    enable = lib.mkEnableOption "ChunkHound code search";

    embedding = {
      provider = lib.mkOption {
        type = lib.types.str;
        default = "openai";
      };
      model = lib.mkOption {
        type = lib.types.str;
        default = "nomic-embed-text";
      };
      baseUrl = lib.mkOption {
        type = lib.types.str;
        default = "http://localhost:11434/v1";
      };
    };

    llm.provider = lib.mkOption {
      type = lib.types.str;
      default = "claude-code-cli";
    };

    excludePatterns = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = defaultExcludes;
    };

    extraExcludePatterns = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };

    ollama.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    packages = [
      pkgs.jq
    ]
    ++ lib.optionals cfg.ollama.enable [ pkgs.ollama ];

    processes = lib.mkIf cfg.ollama.enable {
      ollama.exec = "pgrep -x ollama > /dev/null && { echo 'ollama already running'; sleep infinity; } || ollama serve";
    };

    enterShell = ''
      # Install chunkhound to isolated venv (separate from project Python)
      if [ ! -x "${chunkhoundVenv}/bin/chunkhound" ]; then
        echo "Installing chunkhound to isolated environment..."
        ${pkgs.python312}/bin/python -m venv "${chunkhoundVenv}"
        "${chunkhoundVenv}/bin/pip" install --quiet chunkhound
      fi

      # Generate config in devenv state: merge defaults with .chunkhound.json overrides
      _base_config='${baseConfigJson}'
      if [ -f "$DEVENV_ROOT/.chunkhound.json" ]; then
        echo "$_base_config" | ${pkgs.jq}/bin/jq -s '.[0] * .[1]' - "$DEVENV_ROOT/.chunkhound.json" > "${chunkhoundConfig}"
      else
        echo "$_base_config" | ${pkgs.jq}/bin/jq . > "${chunkhoundConfig}"
      fi

      # Check ollama is running
      if ! pgrep -x ollama > /dev/null; then
        echo ""
        echo "⚠️  Ollama is not running. ChunkHound code search will not work effectively."
        echo "   Start Ollama with: ollama serve (or: devenv up)"
      # Check for embedding model (only if ollama is running)
      elif ! ${pkgs.ollama}/bin/ollama list 2>/dev/null | grep -q "${cfg.embedding.model}"; then
        echo ""
        echo "⚠️  ${cfg.embedding.model} model not found. Run: chunkhound-setup"
      fi
    '';

    scripts.chunkhound.exec = ''
      cmd="$1"
      shift
      "$DEVENV_STATE/chunkhound-venv/bin/chunkhound" "$cmd" --config "$DEVENV_STATE/chunkhound.json" "$@"
    '';

    scripts.chunkhound-setup.exec = ''
      echo "Pulling ${cfg.embedding.model} model..."
      ${pkgs.ollama}/bin/ollama pull ${cfg.embedding.model}
      echo "✓ Setup complete"
    '';
  };
}
