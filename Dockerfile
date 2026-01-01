FROM alpine:3.23 AS build

RUN apk add --no-cache build-base jq curl wget
WORKDIR /src
RUN DARKHTTPD_TAG=$(curl -s "https://api.github.com/repos/emikulic/darkhttpd/releases/latest" | jq -r .tag_name) && \
    wget https://github.com/emikulic/darkhttpd/archive/refs/tags/${DARKHTTPD_TAG}.tar.gz -O /tmp/darkhttpd.tar.gz && \
    tar -zxvf /tmp/darkhttpd.tar.gz -C /src --strip-components 1
RUN make darkhttpd && \
    strip darkhttpd


FROM scratch

COPY --chmod=755 --from=build /src/darkhttpd /darkhttpd
COPY --chmod=755 ./lunasea/html /web

ENTRYPOINT ["/darkhttpd","/web"]
CMD ["--port","80"]

EXPOSE 80
