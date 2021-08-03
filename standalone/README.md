

You can find multiple versions of docker images of Magento on Docker Hub. For each images, there are two flavors: **Enterprise (ee)** and **Community (ce)** edition of Magento.

Here are the different image versions:

- A **simple version** with php-fpm, Nginx, MariaDB, ElasticSearch and Magento installed:
  - `odyssee/magento:2.4.1-p1-ce`
  - `odyssee/magento:2.4.1-p1-ee`

- A version with **Luma** sample data (plus everything in the simple version):
  - `odyssee/magento-luma:2.4.1-p1-ce`
  - `odyssee/magento-luma:2.4.1-p1-ee`

- A version with **PWA/Venia** sample data (plus everything in the simple version):
  - `odyssee/magento-pwa-venia:2.4.1-p1-ce`
  - `odyssee/magento-pwa-venia:2.4.1-p1-ee`


## How to run the Docker image

For the Community Edition of the simple version, run:
```
docker run -p 80:80 -t odyssee/magento:2.4.1-p1-ce
```

For the Community Edition of Luma version, run:
```
docker run -p 80:80 -t odyssee/magento-luma:2.4.1-p1-ce
```

For the Community Edition of PWA/Venia version, run:
```
docker run -p 80:80 -p 10000:10000 -t odyssee/magento-pwa-venia:2.4.1-p1-ce
```
*Note:* For the Enterprise edition switch the `ce` to `ee`

Access:
- For Magento: [http://localhost/](http://localhost)
- For Magento admin: [http://localhost/admin](http://localhost/admin)
  - User: `admin`
  - Password: `123123q`
- For PWA:
  - PWADevServer: [http://localhost:10000](http://localhost:10000)
  - GraphQL Playground: [http://localhost:10000/graphiql](http://localhost:10000/graphiql)


## Build

To build your own image, you will need to fill out the file `auth.json`. Then look at the script `build.sh`
