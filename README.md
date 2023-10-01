# init-gh-token

This container generates a Github App installation token and writes it to a file.

It's intended to be used as an init container

### Example

The following is an example of how you might use this container alongside self-hosted renovate:

(you need to update the `user/repo` section in `spec.containers[1].args`)

```yml
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: renovate
  namespace: kube-system
spec:
  schedule: '@hourly'
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        spec:
          initContainers:
            - name: secrets-init
              image: ghcr.io/xyhhx/init-gh-token:main
              env:
                - name:  APP_ID
                  valueFrom:
                    secretKeyRef:
                      name:  renovate-env
                      key: RENOVATE_GH_APP_ID
                - name:  PRIVATE_KEY
                  valueFrom:
                    secretKeyRef:
                      name:  renovate-env
                      key: RENOVATE_GH_APP_PRIVATE_KEY
              volumeMounts:
                - mountPath: /mnt
                  name: token-vol
          containers:
            - name: renovate
              image: renovate/renovate:35.159.7
              command:
                - /bin/sh
              args:
                - -c
                - export RENOVATE_TOKEN=$(cat /mnt/token); renovate user/repo
              env:
                - name: LOG_LEVEL
                  value: debug
                - name: RENOVATE_PLATFORM_COMMIT
                  value: "true"
              envFrom:
                - secretRef:
                    name: renovate-env
              resources:
                limits:
                  memory: "2G"
              volumeMounts:
                - name: config-volume
                  mountPath: /opt/renovate/
                - name: work-volume
                  mountPath: /tmp/renovate/
                - name: token-vol
                  mountPath: /mnt
                  readOnly: true
          restartPolicy: Never
          volumes:
            - name: config-volume
              configMap:
                name: renovate-config
            - name: work-volume
              emptyDir: {}
            - name: token-vol
              emptyDir: {}
```
