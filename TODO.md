# TODO

Не критичное (заняться другими задачами):
- [ ] Right now if anything (for example a firewall rule) has been changed - changes are not gonna apply.
- [ ] Set temporary password for a mws_compute_vm_ssh_username using cloud-init


Критичное:
- [ ] templates/cloud-init/lvm.yml, который будет создавать ubuntu виртуалку, в которой /boot будет отдельно, а всё остальное будет в LVM
- [ ] Доделать роль так, чтобы её можно было запускать из gitlab пайплайна:
1) Dockerfile
2) Передача ключа для mws init через переменные окружения
- [ ] Доработать данную роль так, чтобы с помощью неё можно было создавать ресурс Egress NAT https://console.mws.ru/vpc/ved/networks/stage-net/egress-nats/stage-egress-nat

mws vpc egress-nat get stage-egress-nat --network stage-net
kind: vpc/v1/egressNat
metadata:
  id: vpc/projects/ved/networks/stage-net/egressNats/stage-egress-nat
  name: stage-egress-nat
  displayName: stage-egress-nat
  createTime: "2026-01-08T21:01:35Z"
  updateTime: "2026-01-08T21:01:38Z"
  etag: 90361d12761f417989e4923d78671bc5
spec:
  internal:
    subnets:
      - stage-private-subnet
      - stage-dbms-subnet
  external:
    addresses:
      - ref: stage-egress-nat-address
status:
  ready:
    state: OK
  internal: {}
  external:
    addresses:
      - ref: stage-egress-nat-address
        ipAddress: 2.59.80.132
  pba:
    blockSize: 256

