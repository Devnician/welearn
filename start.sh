docker-compose -f docker-compose-welearn.yml down
docker-compose -f docker-compose-welearn.yml pull
docker-compose -f docker-compose-welearn.yml up --build > ./logs/welearn-$(date +%s).log 2>&1 &