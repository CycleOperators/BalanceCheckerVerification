
-- Fix the version of motoko-base to 0.12.1
let packages =
  [
    { name = "base"
    , repo = "https://github.com/dfinity/motoko-base"
    , version = "moc-0.12.1"
    , dependencies = [] : List Text
    },
  ]

in packages
