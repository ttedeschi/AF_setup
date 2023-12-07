# Tier2 offloading

```
cd AF_setup/AF20/interlink
kubectl apply -n af-new -k ../vk/
sudo docker compose -f docker-compose-T2.yaml up -d
```

```
kubectl apply -f tests/wn_deployment_ba.yaml
sudo docker exec interlink-docker-sidecar-ba-1 bash -c "source condor-setup/Bari.sh && condor_q"
```
