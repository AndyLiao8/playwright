# build image
FROM mcr.microsoft.com/dotnet/sdk:6.0 As build

# ===build template project===
RUN mkdir /ms-playwright-demo && \
    cd /ms-playwright-demo && \
    dotnet new console && \
    dotnet add package Microsoft.Playwright -v 1.40.0 && \
    dotnet publish . -c release -o /release

# base image
FROM mcr.microsoft.com/dotnet/aspnet:6.0

WORKDIR /temp

COPY --from=build /release .

# === INSTALL dependencies ===

#Install powershell
RUN apt-get update -yq \
    && apt-get install wget -yq \
    && wget -q https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && apt-get update -yq \
    && apt-get install powershell -yq

# === BAKE BROWSERS INTO IMAGE ===
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

# Bake in browsers & deps.
#    Browsers will be downloaded in `/ms-playwright`.
#    Note: make sure to set 777 to the registry so that any user can access
#    registry.
RUN mkdir /ms-playwright && \
    ./playwright.ps1 install --with-deps chromium && \
    rm -rf /var/lib/apt/lists/* && \
    chmod -R 777 /ms-playwright

# remove wget and powershell
RUN apt-get remove -yq wget && \
    apt-get remove -yq powershell

WORKDIR /

RUN rm -rf /temp
