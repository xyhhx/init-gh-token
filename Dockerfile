FROM debian:latest 

RUN apt update && apt install -y jq curl perl

RUN curl -o ghtoken \
     -O -L -C  - \
     https://raw.githubusercontent.com/Link-/gh-token/main/gh-token && \
     echo "6a6b111355432e08dd60ac0da148e489cdb0323a059ee8cbe624fd37bf2572ae  ghtoken" | \
     shasum -c - && \
     chmod u+x ./ghtoken

ENV APP_ID=0
ENV PRIVATE_KEY=null

CMD ./ghtoken generate -b $PRIVATE_KEY -i $APP_ID -j | jq -r '.token' > /mnt/token
