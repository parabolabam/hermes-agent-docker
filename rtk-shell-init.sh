#!/bin/sh
# RTK (Rust Token Killer) — transparent CLI proxy for token-efficient output.
# Defines shell functions so agent commands are silently routed through RTK.
# Shell functions only exist in the current shell; RTK's own subprocess calls
# run the real binaries directly, so there is no recursion risk.

if command -v rtk >/dev/null 2>&1; then
  git()    { rtk git    "$@"; }
  gh()     { rtk gh     "$@"; }
  docker() { rtk docker "$@"; }
  find()   { rtk find   "$@"; }
  grep()   { rtk grep   "$@"; }
  tree()   { rtk tree   "$@"; }
fi
