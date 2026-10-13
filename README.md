# Custom Lynis SSH Hardening Tests

A Linux security-auditing project that extends [Lynis](https://cisofy.com/lynis/) with six custom SSH configuration checks. The tests focus on login policy, authentication attempts, session liveness settings, and the configured SSH port.

> **Project status:** The scripts and example outputs are provided for learning and lab use. Run them on your own Ubuntu VM and replace any illustrative screenshots or results with genuine captures from your environment before presenting the project as tested evidence.

## Features

| Test ID | Check | Intended policy |
|---|---|---|
| CUST-9001 | SSH root login | `PermitRootLogin no` |
| CUST-9002 | SSH password authentication | `PasswordAuthentication no` when key-based access is configured |
| CUST-9003 | Empty-password authentication | `PermitEmptyPasswords no` |
| CUST-9010 | Authentication attempts | `MaxAuthTries` set to 4 or fewer |
| CUST-9011 | Session liveness | Positive `ClientAliveInterval` and a suitable `ClientAliveCountMax` |
| CUST-9012 | SSH port | Suggests considering a non-default port; this is optional hardening |

## Repository layout

- `tests_custom` — all six Lynis custom tests in one file.
- `option1_login.sh` — standalone reference for the three login-policy checks.
- `option2_hardening.sh` — standalone reference for authentication-attempt, session, and port checks.
- `screenshots/README.md` — guidance for adding real lab screenshots.

## Requirements

- An Ubuntu or compatible Linux VM.
- Lynis installed (the original lab used Lynis 3.1.6).
- Administrative access for auditing system settings.
- A backup and VM console access before changing SSH configuration.

Install Lynis on Ubuntu:

```bash
sudo apt update
sudo apt install lynis -y
lynis show version
```

Find the installed include directory:

```bash
lynis show includedir
```

## Install the custom tests

Back up the current custom test file if one exists, then create or edit the expected file:

```bash
sudo cp /usr/share/lynis/include/tests_custom /usr/share/lynis/include/tests_custom.bak 2>/dev/null || true
sudo cp /usr/share/lynis/include/tests_custom.template /usr/share/lynis/include/tests_custom
sudo nano /usr/share/lynis/include/tests_custom
```

Paste the contents of this repository's `tests_custom` file into the editor, save, and exit. On systems where Lynis is installed elsewhere, use the directory reported by `lynis show includedir`.

> **Important:** Confirm how your installed Lynis version loads custom tests before relying on this layout. Keep the file owned by root and do not make it writable by ordinary users.

## Run the tests

```bash
sudo lynis audit system --tests "CUST-9001 CUST-9002 CUST-9003 CUST-9010 CUST-9011 CUST-9012"
```

Inspect recent custom-test log lines:

```bash
sudo grep "CUST-9" /var/log/lynis.log
```

The displayed statuses depend on the configuration Lynis reads. The repository does not guarantee that a particular VM will show the example warnings, OK results, or suggestions.

## Configuration notes and limitations

1. These reference checks parse explicit directives from the main `/etc/ssh/sshd_config` file. They may not reflect the effective configuration when settings are supplied through `/etc/ssh/sshd_config.d/*.conf`, duplicated directives, or other OpenSSH configuration behavior.
2. For a more reliable view of effective server settings, inspect `sudo sshd -T` and review the output in the context of your OpenSSH version and configuration.
3. `ClientAliveInterval` and `ClientAliveCountMax` are server-side liveness controls; they should not be described as a strict interactive idle timeout in every situation.
4. Moving SSH away from port 22 can reduce some automated scan noise, but it is not a substitute for strong authentication, patching, and access controls.
5. Custom warnings and suggestions do not automatically increase the Lynis hardening index.
6. Validate custom-test compatibility against your installed Lynis release before using the scripts in production.

## Safe configuration changes

The following example shows common hardening directives. Apply them only after considering your access requirements:

```text
PermitRootLogin no
PasswordAuthentication no
PermitEmptyPasswords no
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
```

Before restarting SSH, back up the configuration and validate syntax:

```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sudo sshd -t
```

Only disable password authentication after confirming that key-based login works. Otherwise, you may lock yourself out of a remote machine. In a VM, keep access to the virtual console available. Restart the service only after validating the configuration and understanding the local service name.

## Screenshots

Add genuine terminal captures to the `screenshots/` directory. Do not present generated mockups as authentic terminal output. See [screenshots/README.md](screenshots/README.md).

## References

- [Lynis official website](https://cisofy.com/lynis/)
- [Lynis source repository](https://github.com/CISOfy/lynis)
- [OpenSSH sshd_config manual](https://man.openbsd.org/sshd_config)

## License

This project is distributed under the MIT License; see [LICENSE](LICENSE).
