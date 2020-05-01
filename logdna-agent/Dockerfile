FROM node:13-alpine
CMD ["node", "/src/index.js"]
WORKDIR /src

# Only run yarn when we need to do so.
COPY package.json ./
RUN yarn --production

COPY . .