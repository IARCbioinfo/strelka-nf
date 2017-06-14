#!/bin/bash

curl -H "Content-Type: application/json" --data "{\"source_type\": \"Branch\", \"source_name\": \"$CIRCLE_BRANCH\"}" -X POST https://registry.hub.docker.com/u/iarcbioinfo/strelka-nf/trigger/b9b6d36d-390b-4cdf-ac1b-51ca996c0539/
