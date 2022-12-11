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

# metamath.exe: get and build
RUN curl https://us.metamath.org/downloads/metamath.zip -o metamath.zip
RUN unzip metamath.zip -d .
WORKDIR /build/metamath
RUN clang *.c -o metamath

# checkmm: get and build
WORKDIR /build/checkmm
RUN curl https://us.metamath.org/downloads/checkmm.cpp -o checkmm.cpp
RUN g++ checkmm.cpp -o checkmmc

# define the final conatiner
FROM metamath-base

# metamath.exe: copy
COPY --from=metamath-build /build/metamath/metamath /usr/bin/metamath

# checkmm: copy
COPY --from=metamath-build /build/checkmm/checkmmc /usr/bin/checkmmc

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

# When run, launch the shell in set.mm
WORKDIR /set.mm
CMD ["sh"]
