# Ubuntu Desktop Server

## Local Deployment
```bash
docker build -t ubuntu-desktop-server:1.0.0 .
```

## Heroku deployment
### Using local build
1. Create heroku app
```bash
heroku create -a ubuntu-desktop-server
```
2. Login to heroku container registry
```bash
heroku container:login
```
3. Push & release to heroku
```bash
heroku container:push web
heroku container:release web
```
4. Open app
```bash
heroku open
```
### Using [heroku.yml](heroku.yml)
heroku.yml
```yaml
build:
  docker:
    web: Dockerfile
```
1. Create heroku app
```bash
heroku create -a ubuntu-desktop-server
```
2. Set stack to be container
```bash
heroku stack:set container
```
3. Login to heroku repository
```bash
heroku container:login
```
4. Push to heroku repository
```bash
git push heroku master
```

## Railway deployment
1. Connect the project
```bash
railway link project-id
```
2. Push to railway
```bash
railway up
```