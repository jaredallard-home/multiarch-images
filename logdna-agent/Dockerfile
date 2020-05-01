FROM mhart/alpine-node:13
CMD ["node", "/src/index.js"]
WORKDIR /src

# Only run yarn when we need to do so.
COPY package.json ./
RUN yarn

COPY . .