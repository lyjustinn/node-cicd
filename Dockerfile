FROM node:16-alpine3.11

RUN mkdir -p /home/app
ENV NODE_ENV=production

COPY . /home/app

WORKDIR /home/app

RUN npm install --production

CMD ["npm", "start"]