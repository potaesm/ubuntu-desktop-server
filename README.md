# Ubuntu Desktop Server
## Local Deployment
```bash
docker build -t ubuntu-desktop-server:1.0.0 .
```
## Railway deployment
1. Login to Railway
```bash
railway login
```
2. Connect the project
```bash
railway link project-id
```
3. Push to railway
```bash
railway up
```
