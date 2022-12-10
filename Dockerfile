# define the metamath-base container
FROM node:18-alpine AS metamath-base

# tools used as part of the build process which may also come in handy while running
RUN apk add curl
RUN apk add zip
RUN apk add git

# define the metamath-build container
FROM metamath-base AS metamath-build
WORKDIR /build

# metamath.exe: get/build dependencies
RUN apk add clang
RUN apk add build-base

# metamath.exe: get source code
RUN curl https://us.metamath.org/downloads/metamath.zip -o metamath.zip
RUN unzip metamath.zip -d .

# metamath.exe: native Clang build
WORKDIR /build/metamath
RUN clang *.c -o metamath

# define the final conatiner
FROM metamath-base

# metamath.exe: copy
COPY --from=metamath-build /build/metamath/metamath /usr/bin/metamath

# set.mm: shallow clone
RUN git clone --depth 1 https://github.com/metamath/set.mm.git

# When run, launch the shell in set.mm
WORKDIR /set.mm
CMD ["sh"]
