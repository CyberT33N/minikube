## Dependencies

<details>
<summary>Click to expand..</summary>

<br>

### 🐶 K9s
<details>
<summary>Click to expand..</summary>

K9s is a terminal-based UI that allows you to interact with your Kubernetes clusters in a more efficient and user-friendly way. It simplifies the management of Kubernetes resources and provides an intuitive interface for developers and operators alike.



## 📥 Install/Update

1. **Download the latest version of K9s:**
   Visit the [K9s Releases page](https://github.com/derailed/k9s/releases) and download the latest version for your operating system.

2. **Verify your architecture:**
   Use the following command to check your CPU architecture:
```shell
lscpu
```

   - For `x86_64`, use the `amd64` version.

3. **Install the corresponding version:**
   For example, to install version 0.32.5 for Linux (amd64), use the following command:
```shell
wget https://github.com/derailed/k9s/releases/download/v0.32.5/k9s_linux_amd64.deb
sudo dpkg -i k9s_linux_amd64.deb
```

<br>

Once the installation is complete, you can start K9s by running the command `k9s` in your terminal.

</details>
</details>
