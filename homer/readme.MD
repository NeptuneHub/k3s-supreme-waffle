# Introduction
Homer is a static home page that you can use for your cluster. His goals is to be easy to install and configure and very light-weight.

# Install
To install it follow this commmand using helm, you can use as an example the **values.yaml** in this repo (remember to edit the **service list** and the **ingress** before using it):

```
helm repo add djjudas21 https://djjudas21.github.io/charts/
helm repo update djjudas21

# install with all defaults
helm install homer djjudas21/homer --namespace homer --create-namespace -f values.yaml
```
