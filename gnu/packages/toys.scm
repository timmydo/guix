;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2017, 2018, 2020, 2021 Tobias Geerinckx-Rice <me@tobias.gr>
;;; Copyright © 2019 Jesse Gibbons <jgibbons2357+guix@gmail.com>
;;; Copyright © 2019, 2020, 2021 Timotej Lazar <timotej.lazar@araneo.si>
;;; Copyright © 2020 Efraim Flashner <efraim@flashner.co.il>
;;; Copyright © 2021 Leo Famulari <leo@famulari.name>
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (gnu packages toys)
  #:use-module (gnu packages)
  #:use-module (gnu packages bison)
  #:use-module (gnu packages flex)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages man)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages xorg)
  #:use-module (guix build-system gnu)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix utils))

(define-public oneko
  (package
    (name "oneko")
    (version "1.2.sakura.5")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "http://www.daidouji.com/oneko/distfiles/oneko-" version ".tar.gz"))
       (sha256
        (base32 "0bxjlbafn10sfi5d06420pg70rpvsiy5gdbm8kspd6qy4kqhabic"))
       (patches (search-patches "oneko-remove-nonfree-characters.patch"))
       (modules '((guix build utils)))
       (snippet
        ;; Remove bitmaps with copyright issues.
        '(begin
           (for-each delete-file-recursively
                     (cons* "bitmaps/bsd" "bitmaps/sakura" "bitmaps/tomoyo"
                            "bitmasks/bsd" "bitmasks/sakura" "bitmasks/tomoyo"
                            (find-files "cursors" "(bsd|card|petal).*\\.xbm")))
           #t))))
    (build-system gnu-build-system)
    (native-inputs
     (list imake))
    (inputs
     (list libx11 libxext))
    (arguments
     `(#:tests? #f ; no tests
       #:phases
       (modify-phases %standard-phases
         (replace 'configure
           (lambda _
             (invoke "xmkmf")
             ;; Fix incorrectly generated compiler flags.
             (substitute* "Makefile"
               (("(CDEBUGFLAGS = ).*" _ front) (string-append front "-O2\n")))
             #t))
         (replace 'install
           (lambda* (#:key outputs make-flags #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (bin (string-append out "/bin"))
                    (doc (string-append out "/share/doc/" ,name "-" ,version))
                    (man (string-append out "/share/man"))
                    (man6 (string-append man "/man6"))
                    (man6-ja (string-append man "/ja/man6")))
               (install-file "oneko" bin)
               (mkdir-p man6)
               (mkdir-p man6-ja)
               (copy-file "oneko.man" (string-append man6 "/oneko.6"))
               (copy-file "oneko.man.jp" (string-append man6-ja "/oneko.6"))
               (for-each (lambda (file) (install-file file doc))
                         (find-files "." "README.*")))
             #t)))))
    (home-page "http://www.daidouji.com/oneko/")
    (synopsis "Cute cat chasing your mouse pointer")
    (description "Displays a cat or another animated character that chases the
mouse pointer around the screen while you work.")
    (license license:public-domain))) ; see https://directory.fsf.org/wiki/Oneko

(define-public sl
  (package
    (name "sl")
    (version "5.02")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/mtoyoda/sl")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1zrfd71zx2px2xpapg45s8xvi81xii63yl0h60q72j71zh4sif8b"))))
    (build-system gnu-build-system)
    (inputs
     (list ncurses))
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (delete 'configure)            ; no configure script
         (delete 'check)                ; no tests
         (replace 'install              ; no ‘make install’ target
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (bin (string-append out "/bin"))
                    (man (string-append out "/share/man"))
                    (man1 (string-append man "/man1"))
                    (man1-ja (string-append man "/ja/man1")))
               (install-file "sl" bin)
               (install-file "sl.1" man1)
               (mkdir-p man1-ja)
               (copy-file "sl.1.ja" (string-append man1-ja "/sl.1"))
               #t))))))
    (home-page "http://www.tkl.iis.u-tokyo.ac.jp/~toyoda/index_e.html")
    (synopsis "Joke command to correct typing \"sl\" by mistake")
    (description
     "@dfn{SL} (for Steam Locomotive) displays one of several animated trains
on the text terminal.  It serves no useful purpose but to discourage mistakenly
typing @command{sl} instead of @command{ls}.")
    (license (license:non-copyleft "file://LICENSE"
                                   "See LICENSE in the distribution."))))

(define-public filters
  (package
    (name "filters")
    (version "2.55")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "git://git.joeyh.name/filters")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1gaigpda1w9wxfh8an3sam1hpacc1bhxl696w4yj0vzhc6izqvxs"))
       (modules '((guix build utils)))
       (snippet '(begin
                   ;; kenny is under nonfree Artistic License (Perl) 1.0.
                   (delete-file "kenny")
                   (substitute* "Makefile"
                     (("kenny")
                      ""))))))
    (build-system gnu-build-system)
    (arguments
     `(#:make-flags
       (list (string-append "CC=" ,(cc-for-target))
             (string-append "prefix=" (assoc-ref %outputs "out")))
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (add-after 'unpack 'respect-prefix
           (lambda _
             (substitute* "Makefile"
               (("/usr/games")
                "$(prefix)/bin/")
               (("/usr")
                "$(prefix)"))
             #t)))
       #:tests? #f))                    ; no test suite
    (native-inputs
     (list bison flex))
    (inputs
     (list perl))
    (home-page "https://joeyh.name/code/filters/")
    (synopsis "Various amusing text filters")
    (description
     "The filters collection harks back to the late 1980s, when various text
filters were written to munge written language in amusing ways.  The earliest
and best known were legends such as the Swedish Chef filter and B1FF.

This package contains the following filter commands:
@enumerate
@item b1ff: a satire of a stereotypical Usenet newbie
@item censor: comply with the @acronym{CDA, Communications Decency Act}
@item chef: convert English to Mock Swedish
@item cockney: Cockney English
@item elee: k3wl hacker slang
@item fanboy: a stereotypical fan (supports custom fandoms)
@item fudd: Elmer Fudd
@item jethro: hillbilly text filter
@item jibberish: a random selection of these filters
@item jive: Jive English
@item ken: turn English into Cockney
@item kraut: a bad German accent
@item ky00te: a very cute accent
@item LOLCAT: as seen in Internet GIFs everywhere
@item nethackify: wiped-out text as found in nethack
@item newspeak: à la 1984
@item nyc: Brooklyn English
@item pirate: talk like a pirate
@item rasterman: straight from the keyboard of Carsten Haitzler
@item scottish: fake Scottish (Dwarven) accent
@item scramble: scramble the \"inner\" letters of each word
@item spammer: turn honest text into something liable to be flagged as spam
@item studly: studly caps.
@item uniencode: use glorious Unicode to the fullest possible extent
@item upside-down: flip the text upside down
@end enumerate

The GNU project hosts a similar collection of filters, the GNU talkfilters.")
    (license                      ; see debian/copyright
     (list license:gpl2+          ; most of the filters
           license:gpl2           ; rasterman, ky00te.dir/* nethackify, pirate
           license:gpl3+          ; scramble, scottish
           license:public-domain  ; jethro, kraut, ken, studly
           license:gpl1+          ; cockney, jive, nyc only say "gpl"
           license:expat))))     ; newspeak

(define-public xsnow
  (package
    (name "xsnow")
    (version "3.4.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://www.ratrabbit.nl/downloads/xsnow/xsnow-"
             version ".tar.gz"))
       (sha256
        (base32 "17pxc955jgkjan8ax0lw3b3sibw7aikc7p9qbxsp0w7g7jkxf666"))))
    (build-system gnu-build-system)
    (arguments
     '(#:phases
       (modify-phases %standard-phases
         (add-before 'configure 'fix-install-path
           (lambda _
             ;; Install program to bin instead of games.
             (substitute* "src/Makefile.in"
               (("(gamesdir = \\$\\(exec_prefix\\)/)games" _ prefix)
                (string-append prefix "bin")))
             #t)))))
    (inputs
     (list gtk+ libx11 libxpm libxt libxml2))
    (native-inputs
     (list pkg-config))
    (home-page "https://www.ratrabbit.nl/ratrabbit/xsnow/index.html")
    (synopsis "Let it snow on the desktop")
    (description "@code{Xsnow} animates snowfall and Santa with reindeer on
the desktop background.  Additional customizable effects include wind, stars
and various scenery elements.")
    (license license:gpl3+)))

(define-public nyancat
  (package
    (name "nyancat")
    (version "1.5.2")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/klange/nyancat")
               (commit version)))
        (file-name (git-file-name name version))
        (sha256
         (base32
          "1mg8nm5xzcq1xr8cvx24ym2vmafkw53rijllwcdm9miiz0p5ky9k"))))
    (build-system gnu-build-system)
    (arguments
     `(#:make-flags '(,(string-append "CC=" (cc-for-target)))
       #:phases
       (modify-phases %standard-phases
         (delete 'configure) ; no configure script
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (bin (string-append out "/bin"))
                    (man (string-append out "/share/man/man1")))
               (install-file "src/nyancat" bin)
               (install-file "nyancat.1" man))
             #t)))))
    (home-page "https://nyancat.dakko.us/")
    (synopsis "Nyan cat telnet server")
    (description
     "This is an animated, color, ANSI-text telnet server that renders a loop
of the Nyan Cat / Poptart Cat animation.")
    (license license:ncsa)))

(define-public cbonsai
  (package
    (name "cbonsai")
    (version "1.3.1")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://gitlab.com/jallbrit/cbonsai.git")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1krsrf7gilmpnba6hjgz8mk32vs55b4i1rxlp7ajrw0v487blljw"))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f ; No test suite
       #:make-flags
       (list (string-append "CC=" ,(cc-for-target))
             (string-append "PREFIX=" (assoc-ref %outputs "out")))
       #:phases
       (modify-phases %standard-phases
         (delete 'configure) ; No ./configure script
         (add-after 'install 'install-doc
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (doc (string-append out "/share/doc/" ,name "-"
                                        ,(package-version this-package))))
               (install-file "README.md" doc)))))))
    (native-inputs
     (list pkg-config scdoc))
    (inputs
     (list ncurses))
    (home-page "https://gitlab.com/jallbrit/cbonsai")
    (synopsis "Grow bonsai trees in a terminal")
    (description "Cbonsai is a bonsai tree generator using ASCII art.  It
creates, colors, and positions a bonsai tree, and is configurable.")
    (license license:gpl3+)))
