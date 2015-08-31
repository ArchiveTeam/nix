{ stdenv, gettext, libidn, pkgconfig, fetchurl
, perl, perlPackages, LWP, python3, lua5_1
, libiconv, libpsl, gnutls ? null }:

  stdenv.mkDerivation rec {
    name = "wget-1.14.lua.20130523-9a5c";

    src = fetchurl {
      url = "http://warriorhq.archiveteam.org/downloads/wget-lua/wget-1.14.lua.20130523-9a5c.tar.bz2";
      sha256 = "0xxlyijz11lfishvgkcjxxfp85hcnk3gb10s245vipjr18qd7q0g";
    };

    preConfigure = ''
      for i in "doc/texi2pod.pl" "util/rmold.pl"; do
        sed -i "$i" -e 's|/usr/bin.*perl|${perl}/bin/perl|g'
      done
    '' + stdenv.lib.optionalString doCheck ''
      # Work around lack of DNS resolution in chroots.
      for i in "tests/"*.pm "tests/"*.px
      do
        sed -i "$i" -e's/localhost/127.0.0.1/g'
      done
    '' + stdenv.lib.optionalString stdenv.isDarwin ''
      export LIBS="-liconv -lintl"
    '';

    nativeBuildInputs = [ gettext pkgconfig ];
    buildInputs = [ libidn libiconv libpsl lua5_1 ]
      ++ stdenv.lib.optionals doCheck [ perl perlPackages.IOSocketSSL LWP python3 ]
      ++ stdenv.lib.optional (gnutls != null) gnutls
      ++ stdenv.lib.optional stdenv.isDarwin perl;

    configureFlags =
      if gnutls != null then "--with-ssl=gnutls" else "--without-ssl";

    doCheck = (perl != null && python3 != null && !stdenv.isDarwin);
	  
	patches = [ ./texi2pod.patch ];

    meta = with stdenv.lib; {
      description = "Tool for retrieving files using HTTP, HTTPS, and FTP";

      longDescription =
        '' GNU Wget is a free software package for retrieving files using HTTP,
           HTTPS and FTP, the most widely-used Internet protocols.  It is a
           non-interactive commandline tool, so it may easily be called from
           scripts, cron jobs, terminals without X-Windows support, etc.
        '';

      license = licenses.gpl3Plus;

      homepage = "https://github.com/ArchiveTeam/wget-lua";

      maintainers = with maintainers; [ joepie91 ];
      platforms = platforms.all;
    };
  }
