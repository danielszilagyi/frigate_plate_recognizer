ARG BUILD_FROM
FROM ${BUILD_FROM}

WORKDIR /usr/src/app

COPY index.py Arial.ttf run.sh requirements.txt /usr/src/app/

RUN \
    apk add --no-cache gcc=12.2.1_git20220924-r10 zlib-dev=1.2.13-r1 jpeg-dev=9e-r1 musl-dev=1.2.4-r2 freetype-dev=2.13.0-r5 yq=4.33.3-r5 \
    && chmod a+x ./run.sh \
    && pip install -r requirements.txt --no-cache-dir 
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Home Assistant Add-ons" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}

CMD ["./run.sh"]
