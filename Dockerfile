FROM alpine:3.9 AS builder

# Dependencies
RUN set -x \
  && apk add --no-cache \
      alpine-sdk \
      ncurses-dev

# MDP installation
RUN set -x \
  && git clone https://github.com/visit1985/mdp.git \
  && cd mdp \
  && make \
  && make install

########

FROM alpine:3.9 AS mdp

# Dependencies
RUN set -x \
  && apk add --no-cache \
      ncurses

COPY --from=builder /usr/local/bin/mdp /usr/local/bin/mdp

WORKDIR "/opt/presentation"

VOLUME ["/opt/presentation"]

ENTRYPOINT ["mdp"]
