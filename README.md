#  **[SpeedTest by OpenSpeedTest™](https://openspeedtest.com?Run&ref=Github)** - Free & Open-Source HTML5 Network Performance Estimation Tool.
##  **[OpenSpeedTest™ Docker Image](https://hub.docker.com/r/openspeedtest/latest)**

[![OpenSpeedTest Docker Image](https://github.com/openspeedtest/v2-Test/raw/main/images/10G-S.gif)](https://hub.docker.com/r/openspeedtest/latest  "OpenSpeedTest Docker Image")
**No client-side software or plugin is required. You can run a network speed test from any device with a [Web Browser that is IE10 or new.](https://www.youtube.com/watch?v=9f-OM_WQ7Bw&list=PLt-deStxFJOMEAs2O1lJhscMNzcg9E3Po&index=1)**

**This is docker implementation using nginxinc/nginx-unprivileged:stable-alpine. uses significantly fewer resources.**

- NGINX Docker image that runs NGINX as a non root, unprivileged user.
 
 ###  Docker install instructions:

 Install Docker and run the following command!

````bash

sudo docker run --restart=unless-stopped --name openspeedtest -d -p 3000:3000 -p 3001:3001 openspeedtest/latest

````
#### Or use docker-compose.yml 
````
version: '3.3'
services:
    speedtest:
        restart: unless-stopped
        container_name: openspeedtest
        ports:
            - '3000:3000'
            - '3001:3001'
        image: openspeedtest/latest
````
- Warning! If you run it behind a **[Reverse Proxy](https://github.com/openspeedtest/Speed-Test/issues/4#issuecomment-1229157193)**, you should increase the `post-body content length` to 35 megabytes.

- **[Follow our Nginx Config.](https://github.com/openspeedtest/Nginx-Configuration)**

Now open your browser and direct it to:

A: For **HTTP** use: `http://YOUR-SERVER-IP:3000`

B: For **HTTPS** use: `https://YOUR-SERVER-IP:3001`

#### Container-Port for http is 3000
If you need to run this image on a different port for `HTTP`, Eg: change to `80` = `-p 80:3000`
#### Container-Port for https is 3001
If you need to run this image on a different port for `HTTPS`, Eg: change to `443` =  `-p 443:3001`

### Setup Free LetsEncrypt SSL with Automatic Certificate Renewal
***Requirements***
- PUBLIC IPV4 and/or IPV6 address.
- A domain name that resolves to speed test server's IP address.
- Email ID

The following command will generate a Let's Encrypt certificate for your domain name and configure a cron job to automatically renew the certificate.

````
docker run -e ENABLE_LETSENCRYPT=True -e DOMAIN_NAME=speedtest.yourdomain.com -e USER_EMAIL=you@yourdomain.pro --restart=unless-stopped --name openspeedtest -d -p 80:3000 -p 443:3001 openspeedtest/latest
````
#### Or use docker-compose.yml 
````
version: '3.3'
services:
    speedtest:
        environment:
            - ENABLE_LETSENCRYPT=True
            - DOMAIN_NAME=speedtest.yourdomain.com
            - USER_EMAIL=you@yourdomain.pro
        restart: unless-stopped
        container_name: openspeedtest
        ports:
            - '80:3000'
            - '443:3001'
        image: openspeedtest/latest
````

###  How to Use Your Own Secure Sockets Layer (SSL) Certificate, Self-Signed or Paid?
***Requirements***
- Folder with your Certificate, Self-Signed or Paid.
- Rename .cet file and .key file to `nginx.crt` & `nginx.key`

  The folder needs to contain:

- `nginx.crt`

- `nginx.key`


````
sudo docker run --restart=unless-stopped --name openspeedtest -d -p 3000:3000 -p 3001:3001 openspeedtest/latest
````

To mount a folder with your own SSL certificate to this Docker container, append the following line to the above command:
  

````bash

-v /${PATH-TO-YOUR-OWN-SSL-CERTIFICATE}:/etc/ssl/

````
  
I am adding a folder with nginx.crt and nginx.key from my desktop by using the following command.

````bash

sudo docker run -v /Users/vishnu/Desktop/docker/:/etc/ssl/ --restart=unless-stopped --name openspeedtest -d -p 3000:3000 -p 3001:3001 openspeedtest/latest

````
#### Or use docker-compose.yml 
````
version: '3.3'
services:
    speedtest:
        volumes:
            - '/Users/vishnu/Desktop/docker/:/etc/ssl/'
        restart: unless-stopped
        container_name: openspeedtest
        ports:
            - '3000:3000'
            - '3001:3001'
        image: openspeedtest/latest
````
## Advanced Configuration Options 

- Container Port Configuration
  
To enable port changes, set the `CHANGE_CONTAINER_PORTS` environment variable to `"True"` and provide appropriate values for the following variables.

`CHANGE_CONTAINER_PORTS=True`

`HTTP_PORT=3000`

`HTTPS_PORT=3001`

- Set User
  
`SET_USER=101`

- Only Allow `CORS Request` from listed domains. 

`ALLOW_ONLY=domain1.com;domain2.com;domain3.com`

- `SET_SERVER_NAME` Display the server name on the UI.
  
`SET_SERVER_NAME=HOME-NAS` 

- Show platform badge text/logo (for demo environments such as Kubernetes).

`PLATFORM_NAME=Amazon EKS`

`PLATFORM_LOGO_FILE=/usr/share/nginx/html/platform/platform-logo.svg`  (ConfigMap file mount)

`PLATFORM_LOGO_WEB_PATH=/platform/platform-logo.svg`  (Recommended for Kubernetes)

`PLATFORM_LOGO_SVG=<svg ...>...</svg>`  (Use env var if you prefer inline SVG text)

For automatic dark/light switch:

`PLATFORM_LOGO_FILE_LIGHT=/usr/share/nginx/html/platform/platform-logo-light.svg`

`PLATFORM_LOGO_FILE_DARK=/usr/share/nginx/html/platform/platform-logo-dark.svg`

`PLATFORM_LOGO_WEB_PATH_LIGHT=/platform/platform-logo-light.svg`

`PLATFORM_LOGO_WEB_PATH_DARK=/platform/platform-logo-dark.svg`

Second logo (optional):

`PLATFORM_LOGO2_FILE_LIGHT=/usr/share/nginx/html/platform/platform-logo2-light.svg`

`PLATFORM_LOGO2_FILE_DARK=/usr/share/nginx/html/platform/platform-logo2-dark.svg`

`PLATFORM_LOGO2_WEB_PATH_LIGHT=/platform/platform-logo2-light.svg`

`PLATFORM_LOGO2_WEB_PATH_DARK=/platform/platform-logo2-dark.svg`

Kubernetes example:

````yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: speedtest-platform
data:
  PLATFORM_NAME: "Amazon EKS"
  platform-logo-light.svg: |
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
      <circle cx="32" cy="32" r="28" fill="#0f62fe"/>
      <path d="M20 24h24v16H20z" fill="#fff"/>
    </svg>
  platform-logo-dark.svg: |
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
      <circle cx="32" cy="32" r="28" fill="#111"/>
      <path d="M20 24h24v16H20z" fill="#fff"/>
    </svg>
  platform-logo2-light.svg: |
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
      <rect x="8" y="18" width="48" height="28" rx="6" fill="#0f62fe"/>
    </svg>
  platform-logo2-dark.svg: |
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
      <rect x="8" y="18" width="48" height="28" rx="6" fill="#fff"/>
    </svg>
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: speedtest
spec:
  template:
    spec:
      containers:
      - name: speedtest
        image: your-registry/speedtest:latest
        env:
        - name: PLATFORM_NAME
          valueFrom:
            configMapKeyRef:
              name: speedtest-platform
              key: PLATFORM_NAME
        - name: PLATFORM_LOGO_FILE
          value: /usr/share/nginx/html/platform/platform-logo-light.svg
        - name: PLATFORM_LOGO_FILE_LIGHT
          value: /usr/share/nginx/html/platform/platform-logo-light.svg
        - name: PLATFORM_LOGO_FILE_DARK
          value: /usr/share/nginx/html/platform/platform-logo-dark.svg
        - name: PLATFORM_LOGO_WEB_PATH_LIGHT
          value: /platform/platform-logo-light.svg
        - name: PLATFORM_LOGO_WEB_PATH_DARK
          value: /platform/platform-logo-dark.svg
        - name: PLATFORM_LOGO2_FILE_LIGHT
          value: /usr/share/nginx/html/platform/platform-logo2-light.svg
        - name: PLATFORM_LOGO2_FILE_DARK
          value: /usr/share/nginx/html/platform/platform-logo2-dark.svg
        - name: PLATFORM_LOGO2_WEB_PATH_LIGHT
          value: /platform/platform-logo2-light.svg
        - name: PLATFORM_LOGO2_WEB_PATH_DARK
          value: /platform/platform-logo2-dark.svg
        volumeMounts:
        - name: platform-logo
          mountPath: /usr/share/nginx/html/platform
      volumes:
      - name: platform-logo
        configMap:
          name: speedtest-platform
          items:
          - key: platform-logo-light.svg
            path: platform-logo-light.svg
          - key: platform-logo-dark.svg
            path: platform-logo-dark.svg
          - key: platform-logo2-light.svg
            path: platform-logo2-light.svg
          - key: platform-logo2-dark.svg
            path: platform-logo2-dark.svg
````
