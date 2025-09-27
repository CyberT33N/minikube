### 🌩️ MinIO
- I was unable to get the included MinIO release running due to the self-signed TLS certificate issue.
    - [Related Issue](https://gitlab.com/gitlab-org/charts/gitlab-runner/-/issues/75#note_211405230)

- Instead, we can deploy our own MinIO instance and use it within our GitLab Runner. Please refer to the MinIO installation section above or run `./minio/setup.sh`.
  - The setup will also create the necessary `runner-cache` bucket for the GitLab Runner.
  - Additionally, it will generate the required secret `minio-dev` within our `dev` namespace.
```yaml
gitlab-runner:
  runners:
    cache:
    ## S3 secret name.
      secretName: minio-dev
```

- To utilize our own MinIO instance with the GitLab Runner, ensure that the correct configuration is set:
```yaml
# Provide GitLab Runner with the secret object containing the self-signed certificate chain
gitlab-runner:
  install: true
  certsSecretName: gitlab-dev-wildcard-tls-chain

  runners:
    cache:
    ## S3 secret name.
      secretName: minio-dev
    ## Use this line for access using gcs-access-id and gcs-private-key
    # secretName: gcsaccess
    ## Use this line for access using a google-application-credentials file
    # secretName: google-application-credentials
    ## Use this line for access using Azure with azure-account-name and azure-account-key
    # secretName: azureaccess

    config: |
      [[runners]]
        image = "ubuntu:22.04"

        {{- if .Values.global.minio.enabled }}
        [runners.cache]
          Type = "s3"
          Path = "gitlab-runner"
          Shared = true
          [runners.cache.s3]
            AccessKey = "test69696969"
            SecretKey = "test69696969"
            ServerAddress = "192.168.49.2.nip.io:30000"
            BucketName = "runner-cache"
            BucketLocation = "us-east-1"
            Insecure = true
        {{ end }}
```
- **Note:** Both the AccessKey and SecretKey must be set; otherwise, you will encounter an error indicating that the URL cannot be found. The values must be valid.
- In our scenario, the MinIO instance is not using HTTPS, so `Insecure` must be set to `true`.
- As mentioned earlier, the bucket must already exist. You can create it using `mc mb minio/runner-cache`.
