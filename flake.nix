{
  description = "syncorate.el - An emacs-interface for syncorate.com";

  outputs = { self }: {
    overlays.default = final: prev: {
      syncorate-el = final.emacsPackages.trivialBuild rec {
        pname = "syncorate.el";
        version = "1.0.0";

        src = ./.;

        buildInputs = [ final.emacs ];

        meta = with final.lib; {
          homepage = "https://github.com/sebastiant/syncorate.el";
          description = "Emacs interface for Syncorate";
          longDescription = ''
            Display Focus status in mode-line and start Focus sessions from Emacs.
          '';
          inherit (final.emacs.meta) platforms;
        };
      };
    };
  };
}
