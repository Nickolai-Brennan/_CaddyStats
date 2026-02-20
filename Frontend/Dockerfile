# ---------- deps ----------
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json /app/package.json
RUN npm install

# ---------- dev ----------
FROM node:20-alpine AS dev
WORKDIR /app
COPY --from=deps /app/node_modules /app/node_modules
COPY . /app
EXPOSE 5173
CMD ["npm", "run", "dev"]

# ---------- build ----------
FROM node:20-alpine AS build
WORKDIR /app
COPY --from=deps /app/node_modules /app/node_modules
COPY . /app
RUN npm run build

# ---------- prod ----------
FROM nginx:alpine AS prod
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
