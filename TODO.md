# TODO


Не критичное (заняться другими задачами):
- [ ] Right now if anything (for example a firewall rule) has been changed - changes are not gonna apply.

Критичное:
- [ ] В папке templates/cloud-init сейчас слишком много кастомных cloud-init скриптов. Сделать некий единый cloud-init скрипт, который будет делать минимальные настройки. Все остальные настройки виртуальной машины будут сделаны последующими ансибл ролями.