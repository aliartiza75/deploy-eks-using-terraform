# Payever DevOps Task

## Overview

This repository contains the mainfest of the trial task given by Payever team.

## Details

The root repository contains the following files and folders.

```bash
├── aws
├── es-to-prom-exporter
├── mysql
├── monitoring
├── logging
├── namespaces.yaml
└── README.md
```

### Files and Folder Details




#### 1. aws

It contains the manifest regarding the cluster infrastructure.

```bash
├── eks
│   ├── kubeconfig_eks-cluster
│   ├── main.tf
│   ├── terraform
│   ├── terraform.tfstate
│   └── terraform.tfstate.backup
└── users
    ├── eks-user-policy.json
    ├── main.tf
    ├── terraform.tfstate
    └── terraform.tfstate.backup

```

### 2. mysql
### 3. monitoring
### 4. logging
### 5. namespace.yaml






deploy dashboard

https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html

https://github.com/kubernetes-sigs/metrics-server/releases/tag/v0.2.1