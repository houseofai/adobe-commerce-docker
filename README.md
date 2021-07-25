# Adobe Commerce environment on Docker (formerly Adobe Magento Cloud)

*Note:* This integration should be used for demo or development purposes only as it is not correctly configured for production.


## Prerequisites
- Docker: It goes without saying, but Docker needs to be installed.

### For Magento
- [Composer](https://getcomposer.org/): If Composer is not installed, the init script will install it.
- A **Public/Private key** to access `repo.magento.com`. You can create them on [https://marketplace.magento.com/](https://marketplace.magento.com). Check [the official documentation](https://devdocs.magento.com/guides/v2.4/install-gde/prereq/connect-auth.html) on how to set it up.

## Setup

### 1. Clone this repository
```
git clone https://github.com/adobe-commerce-docker.git
cd adobe-commerce-docker
```

### 2. Composer authentication file:
Create a file named `auth.json` and insert the content below:

```
{
    "http-basic": {
        "repo.magento.com": {
            "username": "<public-key>",
            "password": "<private-key>"
        }
    }
}
```
Replace `<public-key>` and `<private-key>` with the keys you copied from the Magento website.

### 3. Download Docker images and initialize Magento
Run the `init.sh` script:
```
chmod +x init.sh
./init.sh
```
*Note:* As Docker needs to be run as a root user, the terminal might prompt for your root password when executing Docker commands (e.g.: `sudo docker run ...`)

*Note:* On the first run, Docker needs to download a couple of images to run Magento (Redis, Varnish, FPM, Nginx, MariaDB, AEM). If your system doesn't have those images locally, it might take a while, depending on your internet connection.


## Start
```
cd projects/magento
sudo docker-compose up
```

## Test

### Adobe Experience Manager: [http://localhost:4502](http://localhost:4502)
```
username = admin
password = admin
```

### Magento Web shop: [https://localhost](https://localhost)

### Magento back-end: [https://localhost/admin](https://localhost/admin)
```
username = Admin
password = 123123q
```

## Shutdown

```
cd projects/magento
sudo docker-compose stop
```
or to shut down docker containers and remove them (and lose all your changes)
```
cd projects/magento
sudo docker-compose down
```