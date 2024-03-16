# define the metamath-base container
FROM node:20-alpine AS metamath-base

# tools used as part of the build process which may also come in handy while running
RUN apk add curl
RUN apk add zip
RUN apk add git

# mmj2: add JRE
RUN apk add openjdk17-jre

# mmverify.py: add Python
RUN apk add python3

# define the metamath-build container
FROM metamath-base AS metamath-build
WORKDIR /build

# metamath.exe and checkmm: dependencies for building C/C++ programs
RUN apk add build-base

# metamath-knife: dependencies for building Rust programs
RUN apk add cargo

# metamath-knife: get and build
WORKDIR /build
RUN git clone --depth 1 https://github.com/david-a-wheeler/metamath-knife.git
WORKDIR /build/metamath-knife
RUN cargo build --release

# metamath.exe: get and build
WORKDIR /build
RUN curl https://us.metamath.org/downloads/metamath.zip -o metamath.zip
RUN unzip metamath.zip -d .
WORKDIR /build/metamath/src
RUN gcc m*.c -o metamath -O3 -funroll-loops -finline-functions -fomit-frame-pointer -Wall -pedantic

# checkmm: get and build
WORKDIR /build/checkmm
RUN curl https://raw.githubusercontent.com/Antony74/checkmm-ts/main/cpp/checkmm.cpp -o checkmm.cpp
RUN g++ checkmm.cpp -o checkmmc -O3 -funroll-loops -finline-functions -fomit-frame-pointer -Wall -pedantic

# mmverify.py: get
WORKDIR /build
RUN git clone --depth 1 https://github.com/david-a-wheeler/mmverify.py.git

# mmj2: get
RUN git clone --depth 1 https://github.com/digama0/mmj2.git

# define the final conatiner
FROM metamath-base

# metamath.exe: copy
COPY --from=metamath-build /build/metamath/src/metamath /usr/bin/metamath

# checkmm: copy
COPY --from=metamath-build /build/checkmm/checkmmc /usr/bin/checkmmc

# mmj2: copy
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
COPY metamath-test/DRIVERS DRIVERS
COPY metamath-test/test-checkmm test-checkmm
COPY metamath-test/test-metamath test-metamath
COPY metamath-test/test-mmj2 test-mmj2
COPY metamath-test/test-mmverifypy test-mmverifypy
COPY metamath-test/test-smetamath test-smetamath

# mmverify.py: copy
WORKDIR /
COPY --from=metamath-build /build/mmverify.py/mmverify.py /set.mm/mmverify.py

# banner
ENV ENV=/root/.ashrc
COPY ./banner.js /root/banner.js
RUN echo node /root/banner.js > /root/.ashrc

# When run, launch the shell in set.mm
WORKDIR /set.mm
CMD ["sh"]
