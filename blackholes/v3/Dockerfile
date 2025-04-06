ARG IMAGE
FROM --platform=linux/amd64 ${IMAGE}

WORKDIR /project

COPY mops.toml ./

# Let mops-cli install the dependencies defined in mops.toml and create
# mops.lock.
# Note: We trick mops-cli into not downloading binaries and not compiling
# anything. We also make it use the moc version from the base image.
RUN mkdir -p ~/.mops/bin \
    && ln -s /usr/local/bin/moc ~/.mops/bin/moc \
    && touch ~/.mops/bin/mo-fmt \
    && echo "actor {}" >tmp.mo \
    && mops-cli build tmp.mo -- --check \
    && rm -r tmp.mo target/tmp

COPY src /project/src/
COPY di[d] /project/did/
COPY build.sh /project

CMD ["/bin/bash"]
