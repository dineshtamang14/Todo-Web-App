FROM node:16.17-alpine3.15
WORKDIR /usr/src/app 
COPY package.json yarn.lock ./
RUN yarn install
COPY . . 
ENV MONGO_URL=mongodb+srv://dinesh:dinesh1997@cluster0.cuuqa.mongodb.net/todo-project-db?retryWrites=true&w=majority
ENV PORT=3000
EXPOSE $PORT 
ENTRYPOINT [ "yarn", "run" ]
CMD [ "start" ]