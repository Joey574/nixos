{ pkgs, ... }:

{
  config = {
    nixpkgs.overlays = [
      (final: prev: {
        embree = (import prev.path { inherit (prev) system; }).embree;

        rapidjson = prev.rapidjson.overrideAttrs (old: {
          checkFlagsArray = (old.checkFlagsArray or [ ]) ++ [ "ARGS=-E valgrind_unittest" ];
        });

        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (pyFinal: pyPrev: {
            astropy = pyPrev.astropy.overridePythonAttrs (old: {
              disabledTests = (old.disabledTests or [ ]) ++ [
                "test_iers_b_out_of_range_handling"
              ];
            });
          })
        ];

        conky = prev.conky.overrideAttrs (old: {
          version = "1.24.2";
          src = pkgs.fetchFromGitHub {
            owner = "brndnmtthws";
            repo = "conky";
            rev = "v1.24.2";
            hash = "sha256-fnH87Ts28t2FIKQkrXjlOFG1NIDPq0JqfDR9aIfog6I=";
          };
          buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.libXi ];
        });

        c-blosc = prev.c-blosc.overrideAttrs (old: {
          doCheck = false;
        });

        gavl = final.stdenv.mkDerivation rec {
          pname = "gavl";
          version = "1.4.0";
          src = final.fetchurl {
            url = "mirror://sourceforge/gmerlin/gavl/${version}/gavl-${version}.tar.gz";
            hash = "sha256-UaqsQTkakVvZutB3EJV0JLBGQQonbn3q/ySocJKdM84=";
          };
          nativeBuildInputs = [ final.pkg-config ];
          buildInputs = [ final.libpng ];
          configureFlags = [ "--without-doxygen" ];
          env.NIX_CFLAGS_COMPILE = "-msse -msse2 -mfpmath=sse -Wno-error=implicit-function-declaration";
          env.NIX_LDFLAGS = "-lmvec";
          postPatch = ''
            sed -i '/#include <png.h>/a #include <string.h>' src/fill_test.c
          '';
        };

        frei0r = prev.frei0r.overrideAttrs (old: {
          version = "3.2.3";
          src = final.fetchFromGitHub {
            owner = "dyne";
            repo = "frei0r";
            rev = "253addfd4bea3c90b0bf765589ca28ea18f3ddc0";
            hash = "sha256-DcimKzQHlS9qXxaRHQ5wIGFtnEijHQjtm6pTBEW0OPk=";
          };
          buildInputs = (old.buildInputs or [ ]) ++ [ final.gavl ];
        });

        python313 = prev.python313.override {
          packageOverrides = pyfinal: pyprev: {

            numcodecs = pyprev.numcodecs.overridePythonAttrs (old: {
              disabledTests = (old.disabledTests or [ ]) ++ [ "blosc" ];
            });

            looptime = pyprev.looptime.overridePythonAttrs (old: {
              disabledTests = (old.disabledTests or [ ]) ++ [
                "test_with_sleep"
                "test_stepping_with_no_limit"
              ];
            });

            # https://github.com/NixOS/nixpkgs/issues/451233
            tornado = pyprev.tornado.overridePythonAttrs (old: {
              disabledTests = (old.disabledTests or [ ]) ++ [
                "test_disposition_param_linear_performance"
                "test_gc"
              ];
            });

            httpcore = pyprev.httpcore.overridePythonAttrs (old: {
              disabledTests = (old.disabledTests or [ ]) ++ [
                "test_connection_pool_timeout_during_request"
              ];
            });

            websockets = pyprev.websockets.overridePythonAttrs (old: {
              disabledTests = (old.disabledTests or [ ]) ++ [
                "test_writing_in_recv_events_fails"
                "test_to_thread"
              ];
            });

            pytest-subprocess = pyprev.pytest-subprocess.overridePythonAttrs (old: {
              disabledTests = (old.disabledTests or [ ]) ++ [
                "test_multiple_wait"
              ];
            });

            scipy = pyprev.scipy.overridePythonAttrs (old: {
              doCheck = false;
            });

            torchcodec = pyprev.torchcodec.overridePythonAttrs (old: {
              disabledTests = (old.disabledTests or [ ]) ++ [
                "test_against_cli"
              ];
            });

            torchaudio = pyprev.torchaudio.overridePythonAttrs (old: {
              disabledTests = (old.disabledTests or [ ]) ++ [
                "test_batch_pitch_shift"
              ];
            });
          };
        };

        gjs = prev.gjs.overrideAttrs (old: {
          mesonCheckFlags = (old.mesonCheckFlags or [ ]) ++ [
            "--no-suite"
            "Debugger"
          ];
        });

        # https://github.com/nodejs/node/issues/50245
        nodejs-slim = prev.nodejs-slim.overrideAttrs (old: {
          postPatch = (old.postPatch or "") + ''
            echo "test-emit-after-on-destroyed: PASS,FLAKY" >>test/async-hooks.status
          '';
        });

        prometheus-qbittorrent-exporter = prev.prometheus-qbittorrent-exporter.overrideAttrs (old: {
          checkFlags = (old.checkFlags or [ ]) ++ [ "-skip=TestSkipCertValidation" ];
        });
      })
    ];
  };
}
