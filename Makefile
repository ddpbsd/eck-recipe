all:
	echo "make elasticsearch to get started"

elasticsearch:
	kubectl apply -f 10-storageClass.yml
	kubectl apply -f 11-persistentVolume.yml
	kubectl apply -f 20-elasticsearch.yml

kibana:
	kubectl apply -f 21-kibana.yml

fleet:
	kubectl apply -f 22-fleetServer.yml

agents:
	kubectl apply -f 23-elastic-agents.yml

clean:
	kubectl delete -f 20-elasticsearch.yml
	kubectl delete -f 11-persistentVolume.yml
	kubectl delete -f 10-storageClass.yml
