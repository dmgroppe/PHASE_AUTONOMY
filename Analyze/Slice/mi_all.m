function [] = mi_all()
[supra infra] = load_master();
mi_group(supra, 1);
mi_group(infra, 1);