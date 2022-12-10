FROM node:18-alpine AS metamath-build
WORKDIR /build

# metamath.exe: get/build dependencies
RUN apk add curl
RUN apk add zip
RUN apk add clang
RUN apk add build-base

# metamath.exe: get source code
RUN curl https://us.metamath.org/downloads/metamath.zip -o metamath.zip
RUN unzip metamath.zip -d .

# metamath.exe: native Clang build
WORKDIR /build/metamath
RUN clang *.c -o metamath

# When run, launch the shell
CMD ["sh"]
