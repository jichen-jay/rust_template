{
  description = "Rust Development Environment with WASM Support";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , rust-overlay
    }:
    let
      # Systems supported
      allSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "x86_64-darwin" # 64-bit Intel macOS
        "aarch64-darwin" # 64-bit ARM macOS
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
        };
      });

    in
    {
      devShells = forAllSystems
        ({ pkgs }: {
          default = pkgs.mkShell {
            packages = with pkgs; [
              # Pin specific Rust version using rust-bin and add WASM targets
              (rust-bin.stable.latest.default.override {
                targets = [ "wasm32-wasip2" "wasm32-unknown-unknown" ];
                extensions = [ "rust-src" "rustfmt" ];
              })

              # Other useful Rust tools
              cargo-make
              cargo-edit
              cargo-audit
              cargo-deny
              rust-analyzer

              # General development tools
              pkg-config
              openssl
            ];

            # Set up rust-src for rust-analyzer
            env = {
              RUST_SRC_PATH = "${pkgs.rust-bin.stable.latest.default}/lib/rustlib/src/rust/library";
            };
          };
        });

      templates = {
        default = {
          path = ./.;
          description = "Rust Development Environment with WASM Support";
          welcomeText = ''
            # Rust Development Environment with WASM Support

            This is your new Rust development environment, with support for compiling to WebAssembly (WASM) using the wasm32-wasip2 target.

            To enter the development shell, run:

              nix develop

            You can now build and run your project:

              cargo build
              cargo run
          '';
        };
      };
    };
}
