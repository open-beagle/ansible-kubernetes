# 证书

```bash
# ca
openssl genrsa -out ca.key 2048
openssl req -new -key ca.key -out ca.csr -subj "/CN=admin/C=CN/ST=BeiJing/L=Beijing/O=system:masters/OU=System"
openssl x509 -req -in ca.csr -CAcreateserial -out ca.crt -days 36500 -extensions v3_req -signkey ca.key

# peer
openssl genrsa -out peer.key 2048
openssl req -new -key peer.key -out peer.csr -subj "/CN=peer/C=CN/ST=BeiJing/L=Beijing/O=system:masters/OU=System"
openssl x509 -req -in peer.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out peer.crt -days 36500 -extensions v3_req
```
