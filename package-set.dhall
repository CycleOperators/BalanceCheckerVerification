
-- Fix the version of motoko-base to 0.8.4
let packages =
  [
    { name = "base"
    , repo = "https://github.com/dfinity/motoko-base"
    , version = "moc-0.8.4"
    , dependencies = [] : List Text
    }
  ]

in packages
