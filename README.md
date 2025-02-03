# ExternalDNS Plugin CoreDNS Webhook

## Helm Deployment

```bash
$ cat <<EOF > custom-values.yaml
provider:
  name: "webhook"
  webhook:
    image: 
      repository: "ghcr.io/GDATASoftwareAG/external-dns-coredns-webhook"
      tag: "v0.6.0"
    securityContext:
      runAsNonRoot: true
      runAsUser: 65534
    env:
      - name: ETCD_URLS
        value: "https://etcd.lab:2379"
      - name: ETCD_USERNAME
        value: "etcd_external_dns_user"
      - name: ETCD_PASSWORD
        value: "etcd_external_dns_password"
      - name: ETCD_TLS_INSECURE
        value: "true"
    args:
      - external-dns-coredns-webhook
      - --log-level=debug
      - --webhook-provider-read-timeout=5s
      - --webhook-provider-write-timeout=5s
      - --webhook-provider-port="0.0.0.0:8888"
      - --prefix="/skydns/"
      - --txt-owner-id="app"
EOF
```

```bash
$ curl -sfLk https://lima.local:8443/config/external-dns/custom-values.yaml \
| helm upgrade --install external-dns external-dns/external-dns \
         --wait \
         --version="1.15.0" \
         --create-namespace \
         --namespace=external-dns \
         --values - 
```

## Commandline

```
usage: external-dns-coredns-webhook [<flags>]

ExternalDNS CoreDNS webhook

Flags:
  --help                    Show context-sensitive help (also try --help-long and --help-man).
  --version                 Show application version.
  --dry-run                 When enabled, prints DNS record changes rather than actually performing them (default: disabled)
  --log-format=text         The format in which log messages are printed (default: text, options: text, json)
  --log-level=info          Set the level of logging. (default: info, options: panic, debug, info, warning, error, fatal
  --webhook-provider-read-timeout=5s  
                            The read timeout for the webhook provider in duration format (default: 5s)
  --webhook-provider-write-timeout=5s  
                            The write timeout for the webhook provider in duration format (default: 5s)
  --webhook-provider-port="0.0.0.0:8888"  
                            Webhook provider port (default: 0.0.0.0:8888)
  --prefix="/skydns/"       Specify the prefix name
  --txt-owner-id="default"  When using the TXT registry, a name that identifies this instance of ExternalDNS (default: default)
  --pre-filter-external-owned-records  
                            Services are pre filter based on the txt-owner-id (default: false)
```

## ENVs for Etcd

| Name                 | Description                                                                        | Default                 |
|----------------------|------------------------------------------------------------------------------------|-------------------------|
| ETCD_URLS            | Optionally, can be used to configure the urls to connect to etcd, comma seperated. | "http://localhost:2379" |
| ETCD_USERNAME        | Optionally, can be used to configure for authenticating to etcd.                   | ""                      | 
| ETCD_PASSWORD        | Optionally, can be used to configure for authenticating to etcd.                   | ""                      |
| ETCD_CA_FILE         | Optionally, can be used to configure TLS settings for etcd.                        | ""                      |
| ETCD_CERT_FILE       | Optionally, can be used to configure TLS settings for etcd.                        | ""                      |
| ETCD_KEY_FILE        | Optionally, can be used to configure TLS settings for etcd.                        | ""                      |
| ETCD_TLS_SERVER_NAME | Optionally, can be used to configure TLS settings for etcd.                        | ""                      |
| ETCD_TLS_INSECURE    | Optionally, To insecure handle connection use "true", default is false.            | ""                      |

## Pre-filtering CoreDNS services based on ownerIDs

If you are running external-dns in multi cluster, you can use `--coredns-pre-filter-external-owned-records` and
`--txt-owner-id` to ignore external created services, for example from a different external-dns.

## Custom attributes

Coredns offers currently a single custom attribute:

* [Grouped](https://github.com/skynetservices/skydns#groups)
  records: `external-dns.alpha.kubernetes.io/webhook-coredns-group`
