### 🦊 Git (SSH)
- We utilize NodePort for GitLab shell access, allowing us to push to our repositories. Git is available over port 32022. Refer to this guide for instructions on creating and adding SSH keys: [Git Cheat Sheet](https://github.com/CyberT33N/git-cheat-sheet/blob/main/README.md#ssh).

- https://gitlab.local.com/-/user_settings/ssh_keys

After setting up your SSH keys, run:
```shell
git remote add gitlabInternal ssh://git@gitlab.local.com:32022/websites/test.git
```
