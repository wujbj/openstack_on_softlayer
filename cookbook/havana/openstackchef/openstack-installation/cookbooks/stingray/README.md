# Description

Install/Configure stingray

Only support 'Simple HTTP', will support other protocols in the future.

# Recipes

* stingray::init_cluster

* stingray::join_cluster

* stingray::flipper

* stingray::pool

* stingray::vserver

# Usage

## Initial a new cluster

```
default['stingray']['url'] = 'http://172.16.1.24/stingray.tar.gz'
default['stingray']['license_key'] = ''
default['stingray']['password'] = 'passw0rd'
```

## Join an exist cluster

```
default['stingray']['url'] = 'http://172.16.1.24/stingray.tar.gz'
default['stingray']['license_key'] = ''
default['stingray']['password'] = 'passw0rd'
// cluster_host means you first stingray cluster host
#default['stingray']['cluster_host'] = '172.16.1.25'
```


## Add a traffic IP group

```
default['stingray']['flipper']['name'] = 'test-flipper'
default['stingray']['flipper']['ip'] = '172.16.1.253'
default['stingray']['flipper']['keeptogether'] = 'No'
default['stingray']['flipper']['machines'] = ['devr1n25.c2sdev.democentral.ibm.com.']
```

## Add a stingray pool

```
default['stingray']['pool']['name'] = 'test-pool'
default['stingray']['pool']['monitors'] = 'Simple HTTP'
default['stingray']['pool']['algorithm'] = 'roundrobin'
default['stingray']['pool']['nodes'] = ['172.16.0.1:80', '172.16.1.24:80']
```

## Add a stingray vserver with the pool

```
default['stingray']['vserver']['name'] = 'test-vserver'
default['stingray']['vserver']['port'] = 80
default['stingray']['vserver']['pool'] = default['stingray']['pool']['name']
```

## Bootstrap them

Must keep this order

Bootstrap first node:

```
# knife bootstrap 172.16.1.25 -x root -P test4pass -r "role[stingray_init_cluster],role[stingray_config]" -E grizzly-zhiwei -d rhel
```

Bootstrap second node:

```
# knife bootstrap 172.16.1.26 -x root -P test4pass -r "role[stingray_join_cluster]" -E grizzly-zhiwei -d rhel
```
