# base node image
FROM --platform=amd64 node:20-bullseye-slim as base

# set for base and all layer that inherit from it
ENV NODE_ENV production

# Install
RUN apt-get update 

# Install all node_modules, including dev dependencies
FROM base as deps

WORKDIR /myapp

ADD package.json ./
RUN npm install --include=dev

# Setup production node_modules
FROM base as production-deps

WORKDIR /myapp

COPY --from=deps /myapp/node_modules /myapp/node_modules
ADD package.json ./
RUN npm prune --omit=dev

# Build the app
FROM base as build

WORKDIR /myapp

COPY --from=deps /myapp/node_modules /myapp/node_modules

ADD . .
RUN npm run build

# Finally, build the production image with minimal footprint
FROM base

ENV NODE_ENV="production"

WORKDIR /myapp

COPY --from=production-deps /myapp/node_modules /myapp/node_modules

COPY --from=build /myapp/build /myapp/build
COPY --from=build /myapp/public /myapp/public
COPY --from=build /myapp/package.json /myapp/package.json
COPY --from=build /myapp/start.sh /myapp/start.sh
COPY --from=build /myapp/preprod/docker-compose.staging.yml /myapp/preprod/docker-compose.staging.yml
COPY --from=build /myapp/prod/docker-compose.yml /myapp/prod/docker-compose.yml

RUN ["chmod", "+x", "./start.sh" ]

ENTRYPOINT [ "./start.sh" ]
# CMD ["npm", "start"]