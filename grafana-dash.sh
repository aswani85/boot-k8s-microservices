#!/bin/bash
NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
GRAFANA_PORT=$(kubectl get --namespace default -o jsonpath="{.items[0].spec.ports[0].nodePort}" services -l component=grafana)
PROMETHEUS_DNS=$(kubectl get --namespace default -o jsonpath="{.items[0].metadata.name}" services -l component=prometheus)
echo "Creating Datasource"
curl -sf -X POST -H "Content-Type: application/json" --data-binary "{\"name\":\"prom\",\"type\":\"prometheus\",\"url\":\"http://$PROMETHEUS_DNS:9090\",\"access\":\"proxy\",\"isDefault\":true}" http://$NODE_IP:$GRAFANA_PORT/api/datasources
echo ""
echo "Creating Dashboard"
echo '{"dashboard": ' > data.json
cat Hollywood-Devoxx-2017.json >> data.json
echo ', "inputs": [{"name": "DS_PROM", "label": "prom", "description": "", "type": "datasource", "pluginId": "prometheus", "pluginName": "Prometheus" }], "overwrite": true}' >> data.json
curl -sf -X POST -H "Content-Type: application/json" --data-binary @data.json http://$NODE_IP:$GRAFANA_PORT/api/dashboards/import
echo ""
