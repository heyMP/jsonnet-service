# JSONNET FAAS

Function as a service for (jsonnet)[https://jsonnet.org/]

## Usage

curl --header "Content-Type: text/plain" -d "local a = { x: 1, y: b.y, }, b = { x: a.x, y: 2, }; [a, b]" http://localhost:3000?y

## JSONNET cli Options

Currently supports the -e and -y flags. Add the options as query parameters in the request url

Example: `http://localhost:3000?y`

## OpenFaas

This function supports OpenFaas framework. A sample template.yml file is included. See OpenFaas documentation for deploying this function. (https://www.openfaas.com/)[https://www.openfaas.com/]