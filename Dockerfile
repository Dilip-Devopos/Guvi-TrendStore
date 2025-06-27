FROM public.ecr.aws/nginx/nginx:1.25

RUN rm -rf /usr/share/nginx/html/*

COPY /dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]