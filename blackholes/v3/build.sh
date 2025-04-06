#!/bin/bash

MOC_GC_FLAGS="" ## place any additional flags like compacting-gc, incremental-gc here
MOC_FLAGS="$MOC_GC_FLAGS -no-check-ir --release --public-metadata candid:service --public-metadata candid:args"
OUT=out/out_$(uname -s)_$(uname -m).wasm
mops-cli build --lock --name out src/blackhole.mo -- $MOC_FLAGS
cp target/out/out.wasm $OUT
ic-wasm $OUT -o $OUT shrink
if [ -f did/service.did ]; then
    echo "Adding service.did to metadata section."
    ic-wasm $OUT -o $OUT metadata candid:service -f did/service.did -v public
else
    echo "service.did not found. Skipping metadata update."
fi
if [ "$compress" == "yes" ] || [ "$compress" == "y" ]; then
  gzip -nf $OUT
  sha256sum $OUT.gz
else
  sha256sum $OUT
fi
