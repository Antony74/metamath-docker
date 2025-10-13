# define the metamath-base container
FROM ubuntu:24.04 AS metamath-base
RUN apt-get update

# tools used as part of the build process and/or which may also come in handy while
# running or monitoring our metamath commands
RUN apt-get install -y bash
RUN apt-get install -y curl
RUN apt-get install -y zip
RUN apt-get install -y git
RUN apt-get install -y hyperfine

# checkmm-ts: install node
RUN apt-get install -y nodejs
RUN apt-get install -y npm

# mmj2: add JRE
RUN apt-get install -y openjdk-17-jre

# mmverify.py: add Python
RUN apt-get install -y python3

# define the metamath-build container
FROM metamath-base AS metamath-build
WORKDIR /build

# metamath.exe, checkmm, hmm: dependencies for building C/C++ and Haskell programs
RUN apt-get install -y build-essential

# hmm: dependencies for building Haskell programs
RUN apt-get install -y ghc

# metamath-knife: dependencies for building Rust programs
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# metamath-knife: get and build
WORKDIR /build
RUN git clone --depth 1 https://github.com/david-a-wheeler/metamath-knife.git
WORKDIR /build/metamath-knife
RUN PATH="$HOME/.cargo/bin:$PATH" cargo build --release

# metamath.exe: get and build
WORKDIR /build
RUN curl https://us.metamath.org/downloads/metamath.zip -o metamath.zip
RUN unzip metamath.zip -d .
WORKDIR /build/metamath/src
RUN gcc m*.c -o metamath -O3 -funroll-loops -finline-functions -fomit-frame-pointer -Wall -pedantic

# mmverify.py: get
WORKDIR /build
RUN git clone --depth 1 https://github.com/david-a-wheeler/mmverify.py.git

# mmj2: get
WORKDIR /build
RUN git clone --depth 1 https://github.com/digama0/mmj2.git

# hmm: get and build
WORKDIR /build
RUN curl https://us.metamath.org/downloads/hmm.zip -o hmm.zip
RUN unzip hmm.zip -d .
WORKDIR /build/hmm
COPY hmm/Makefile Makefile
COPY hmm/Hmm.hs Hmm.hs
RUN make

# checkmm: get and build
WORKDIR /build/checkmm
COPY checkmm.cpp checkmm.cpp
RUN g++ checkmm.cpp -o checkmmc -O3 -funroll-loops -finline-functions -fomit-frame-pointer -Wall -pedantic -static -flto

# define the final container
FROM metamath-base

# metamath.exe: copy
COPY --from=metamath-build /build/metamath/src/metamath /usr/bin/metamath

# checkmm: copy
COPY --from=metamath-build /build/checkmm/checkmmc /usr/bin/checkmmc

# metamath-knife: copy
COPY --from=metamath-build /build/metamath-knife/target/release/metamath-knife /usr/bin/metamath-knife

# checkmm-ts
RUN npm install --global checkmm

# prettier-plugin-mm (beta)
RUN npm install --global prettier
RUN npm install --global prettier-plugin-mm

# alt-mm (beta)
WORKDIR /git
RUN git clone --depth 1 --no-single-branch https://github.com/Antony74/alt-mm
WORKDIR /git/alt-mm
RUN npm install --omit=dev
RUN npm install --global .

# set.mm: shallow clone
WORKDIR /
RUN git clone --depth 1 https://github.com/metamath/set.mm.git

# metamath-test: shallow clone
RUN git clone --depth 1 https://github.com/david-a-wheeler/metamath-test.git
WORKDIR /metamath-test
COPY metamath-test/test-metamath test-metamath
RUN chmod +x test-metamath

# metamath-test: satisfy its expectations about where to find things

COPY metamath-test/metamath-knife /root/.cargo/bin/metamath-knife
RUN chmod +x /root/.cargo/bin/metamath-knife

COPY metamath-test/checkmm checkmm
RUN chmod +x checkmm

# Comment hmm from metamath-test DRIVERS file
RUN sed -i 's/.\/test-hmmverify/# .\/test-hmmverify/g' DRIVERS

# mmj2: copy
COPY --from=metamath-build /build/mmj2/mmj2jar/mmj2 /usr/bin/mmj2
COPY --from=metamath-build /build/mmj2/mmj2jar/mmj2.jar /usr/bin/mmj2.jar
COPY --from=metamath-build /build/mmj2/mmj2jar/mmj2.jar /metamath-test/mmj2.jar

# mmverify.py: copy
WORKDIR /
COPY --from=metamath-build /build/mmverify.py/mmverify.py /set.mm/mmverify.py
COPY --from=metamath-build /build/mmverify.py/mmverify.py /metamath-test/mmverify.py

# banner, verifier-commands, and benchmark-all
ENV ENV=/root/.bashrc
COPY verifier-commands /set.mm/verifier-commands
COPY banner.js /set.mm/banner.js
RUN echo node /set.mm/banner.js > /root/.bashrc

COPY benchmark-all /set.mm/benchmark-all
RUN chmod +x /set.mm/benchmark-all

# hmm: copy
COPY --from=metamath-build /build/hmm/hmmverify /usr/bin/hmmverify
COPY --from=metamath-build /build/hmm/hmmprint /usr/bin/hmmprint
COPY --from=metamath-build /build/hmm/hmmextract /usr/bin/hmmextract

# When run, launch the shell in set.mm
WORKDIR /set.mm
CMD ["bash"]
