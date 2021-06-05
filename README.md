# Distance learning project
## Prerequisites

1. Maven
2. Node js
3. JDK 11
4. Docker
5. Docker installed on the server machine

#### CI
1. Code is pushed into develop - https://github.com/Devnician/welearn-back-end
2. Travis automation script is activated
3. Access the server machine
4. Clone the current repository - https://github.com/Devnician/welearn
5. Checkout develop branch
6. Check if /start.sh has executable rights and add them if it doesn't
8. Create a logs folder in the directory where /start.sh is
7. Run the /start.sh script

## Travis
<details>
<summary>Travis backend script details - click to expand</summary>

1. The script activates under the conditions `if: type = pull_request OR branch = develop OR branch = main OR tag IS present`
2. The script creates a jar on the virtual machine from travis `script: mvn package -DskipTests`
3. Deploy section from the script is activated when code is pushed into develop `deploy:
    provider: script
    skip_existing: true
    skip_cleanup: true
    script: echo "DONE!"
    on:
      branch: develop`
4. Before_deploy script is executed
* Login as docker user in order to be able to push into docker hub subsequently - `- docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD`. Note that environment variables must be declared for the project in the travis client which is accessed via browser - https://travis-ci.com/github/Devnician/welearn-back-end
* Create a docker image on the travis VM `docker build -t welearn-backend .`
* Validation check if the image is available - `docker images`
* Tag the image so that it can be easily pulled from docker hub `docker tag welearn-backend $DOCKER_USERNAME/welearn-backend`
* Push the image into docker hub `docker push $DOCKER_USERNAME/welearn-backend`
</details>

<details>
<summary>Travis frontend script details - click to expand</summary>

1. The script activates under the conditions `if: type = pull_request OR branch = develop OR branch = main OR tag IS present`
2. The script builds the angular project `script: npm run build:ci`
3. Deploy section from the script is activated when code is pushed into develop `deploy:
    provider: script
    skip_existing: true
    skip_cleanup: true
    script: echo "DONE!"
    on:
      branch: develop`
4. Before_deploy script is executed
* Login as docker user in order to be able to push into docker hub subsequently - `- docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD`. Note that environment variables must be declared for the project in the travis client which is accessed via browser - https://travis-ci.com/github/Devnician/welearn-front-end
* Create a docker image on the travis VM `docker build -t welearn-backend .`
* Validation check if the image is available - `docker images`
* Tag the image so that it can be easily pulled from docker hub `docker tag welearn-backend $DOCKER_USERNAME/welearn-backend`
* Push the image into docker hub `docker push $DOCKER_USERNAME/welearn-backend`
</details>

## /start.sh
<details>
<summary> Start script details </summary>

1. Stops and deletes the data for all images from the doker compose `docker-compose -f docker-compose-welearn.yml down`
2. Pulls the latest versions of the images from docker hub `docker-compose -f docker-compose-welearn.yml pull`
3. Builds and runs the images from the docker compose and outputs the logs from the images into a .log file with a timestamp built into its name `docker-compose -f docker-compose-welearn.yml up --build > ./logs/welearn-$(date +%s).log 2>&1 &`
</details>

## Project configuration
<details>
<summary> Details </summary>

1. The docker compose contains a mariadb:10.4 service. 
`environment:`
      `- "MYSQL_USER=welearn"`
      `- "MYSQL_PASSWORD=welearn"`
      `- "MYSQL_ROOT_PASSWORD=welearn"`
      `- "MYSQL_DATABASE=welearn"`
Environment variables need to match the ones from docker spring profile for the backend - https://github.com/Devnician/welearn-back-end/blob/develop/src/main/resources/application-docker.yml. Note that the user and password must match and the stringtype, useunicode and character encoding path parameters are needed inside the database url in order to show valid cyrillic text inside the project
  `datasource:`
  `  url: "jdbc:mysql://mariadb-ci:3306/welearn?stringtype=unspecified&``useUnicode=true&characterEncoding=UTF-8"`
  `  username: "welearn"`
  `  password: "welearn"`
  `  driver-class-name: com.mysql.jdbc.Driver`
  `flyway:`
  `  enabled: true`
  `  url: "jdbc:mysql://mariadb-ci:3306/welearn?stringtype=unspecified&``useUnicode=true&characterEncoding=UTF-8"`
  `  user: "welearn"`
  `  password: "welearn"`
2. Backend port - configure inside the docker compose file. The one on the left must match the one that the frontend connects to, the one on the right needs to match the port from the spring profile
 `welearn-ci:`
  `ports:`
      `"8081:8080"`
3. Frontend configuration
* package.json - https://github.com/Devnician/welearn-front-end/blob/main/package.json - needs a ng build command that uses the ci configuration: `"build:ci": "ng build --configuration ci"`
* Configuration file must be created - https://github.com/Devnician/welearn-front-end/blob/main/src/environments/environment.ci.ts - restUrl constant needs to have the backend port matching from above `restUrl: 'http://172.16.250.30:8081'`
* angular.json - - needs to have a fileReplacement configuration that uses the new environment. and it needs to be defined in a command that the package.json is going to use
`"ci": {`
`"fileReplacements": [`
`{`
`"replace": "src/environments/environment.ts",`
`"with": "src/environments/environment.ci.ts"`
`}`
* Dockerfile needs to use the newly defined build command - `RUN npm run build:ci` - https://github.com/Devnician/welearn-front-end/blob/main/Dockerfile
* Travis script needs to use the newly defined build command - `  - npm run build:ci` - https://github.com/Devnician/welearn-front-end/blob/main/.travis.yml
</details>

# Predefined users:
* Username: admin
* Username: teacher
* Username: teacher2
* Username: student
* Username: student2
* Username: observer
* Password: admiN123+

# Project is accessed via url:
http://{host}:4200