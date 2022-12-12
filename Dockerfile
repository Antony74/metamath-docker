# define the metamath-base container
FROM node:18-alpine AS metamath-base

# tools used as part of the build process which may also come in handy while running
RUN apk add curl
RUN apk add zip
RUN apk add git

# define the metamath-build container
FROM metamath-base AS metamath-build
WORKDIR /build

# metamath.exe and checkmm: dependencies for building C/C++ programs
RUN apk add clang
RUN apk add build-base

# metamath-knife: dependencies for building Rust programs
RUN apk add cargo

# metamath.exe: get and build
RUN curl https://us.metamath.org/downloads/metamath.zip -o metamath.zip
RUN unzip metamath.zip -d .
WORKDIR /build/metamath
RUN clang *.c -o metamath

# checkmm: get and build
WORKDIR /build/checkmm
RUN curl https://us.metamath.org/downloads/checkmm.cpp -o checkmm.cpp
RUN g++ checkmm.cpp -o checkmmc

# metamath-knife: get and build
WORKDIR /build
RUN git clone --depth 1 https://github.com/david-a-wheeler/metamath-knife.git
WORKDIR /build/metamath-knife
RUN cargo build --release

# mmverify.py: get
WORKDIR /build
RUN git clone --depth 1 https://github.com/david-a-wheeler/mmverify.py.git

# mmj2: get
RUN git clone --depth 1 https://github.com/digama0/mmj2.git

# define the final conatiner
FROM metamath-base

# metamath.exe: copy
COPY --from=metamath-build /build/metamath/metamath /usr/bin/metamath

# checkmm: copy
COPY --from=metamath-build /build/checkmm/checkmmc /usr/bin/checkmmc

# mmj2: add JDK and copy
RUN apk add openjdk17
COPY --from=metamath-build /build/mmj2/mmj2jar/mmj2 /usr/bin/mmj2
COPY --from=metamath-build /build/mmj2/mmj2jar/mmj2.jar /usr/bin/mmj2.jar

# metamath-knife: copy
COPY --from=metamath-build /build/metamath-knife/target/release/metamath-knife /usr/bin/metamath-knife

# checkmm-ts
RUN npm install --global checkmm

# prettier-plugin-mm (beta)
RUN npm install --global prettier
RUN npm install --global prettier-plugin-mm

# alt-mm (beta)
# WORKDIR /git
# RUN git clone --depth 1 --no-single-branch https://github.com/Antony74/alt-mm
# WORKDIR /git/alt-mm
# RUN npm install
# RUN npm install --global .

# set.mm: shallow clone
RUN git clone --depth 1 https://github.com/metamath/set.mm.git

# mmverify.py: add Python and copy
RUN apk add python3
COPY --from=metamath-build /build/mmverify.py/mmverify.py /set.mm/mmverify.py

# banner
ENV ENV=/root/.ashrc
RUN echo echo Metamath command line tools > /root/.ashrc

# When run, launch the shell in set.mm
WORKDIR /set.mm
CMD ["sh"]
