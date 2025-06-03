# Introduction
This is to install Ollama service, with Web Chat and directly pull as a first model mistral:7b. This will give you your self-hosted LLM.

I tested on Intel i5-6500 and is not very responsive (takes 2-3 minutes long to reply) but I use it for async call by API and it works fine.

# Deployment
In /deployment.yaml you have an example of deployment, you can change ip of your service, namespace and secret to use and then just deploy:
```
kubetl apply -f deployment.yaml
```
As is it will deploy the service if you want to call web API on this url:
```
http://192.168.3.15:11434/api/generate
```

and the webui for using the web chat at this:
```
http://192.168.3.16:8088
```
