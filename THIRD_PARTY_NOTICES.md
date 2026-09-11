# Third-party material

The repository rights notice applies to original contributions only. Dependencies
are installed separately and retain their own licenses and notices; they are not
vendored into this repository. Consult each installed distribution's metadata and
license files, and the pinned Mathlib checkout under `formalization/.lake/packages/`.
That generated directory is excluded from Git.

Runtime dependencies are listed in `requirements.txt`; development tools are in
`requirements-dev.txt`. Lean is pinned in `formalization/lean-toolchain`, and Lean
packages are pinned in `formalization/lake-manifest.json`. TeX packages retain
their own distribution licenses. No rights to those dependencies are restricted
by this repository's notice.

The manuscript's bibliography and acknowledgments identify prior work, including
the construction of Hamed Hatami, Pooya Hatami, William Pires, Ran Tao and Rosie
Zhao, the question of Vitaly Feldman, Pritish Kamath and Nathan Srebro, and the
simulation of Emmanuel Abbe, Pritish Kamath, Eran Malach, Colin Sandon and Nathan
Srebro. Attribution does not imply ownership or an endorsement from those authors.

Historical snapshots preserve their original attribution and research context.
They may contain superseded arguments and older verification claims. See
`docs/TOPIC_INDEX.md` and the current verification report before reusing results.
