{
  description = "syncorate.el - An emacs-interface for syncorate.com";

  outputs = { self }: {
    overlays.emacs = final: prev:
      let
        syncorate-el = final.emacsPackages.trivialBuild {
          pname = "syncorate.el";
          version = "1.0.0";

          src = ./.;

          buildInputs = [ final.emacs ];

          meta = {
            homepage = "https://github.com/sebastiant/syncorate.el";
            description = "Emacs interface for Syncorate";
            longDescription = ''
              Display Focus status in mode-line and start Focus sessions from Emacs.
            '';
            inherit (final.emacs.meta) platforms;
          };
        };
        overrides = efinal: eprev: { inherit syncorate-el; };
      in {
        emacsPackagesFor = emacs:
          (prev.emacsPackagesFor emacs).overrideScope overrides;
      };
  };
}
