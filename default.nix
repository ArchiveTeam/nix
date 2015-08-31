let
	nixpkgs = import <nixpkgs> {};
in with nixpkgs;
	rec {
		maintainers = import ./maintainers.nix;
		lib = nixpkgs.stdenv.lib // { inherit maintainers; };
		stdenv = nixpkgs.stdenv // { inherit lib; };
		fetchurl = nixpkgs.fetchurl;
		
		wget_lua = import ./pkgs/dependencies/wget-lua {
			inherit stdenv fetchurl;
			inherit gettext libidn pkgconfig perl perlPackages python3 libiconv libpsl gnutls lua5_1;
			inherit (perlPackages) LWP;
		};
	}
