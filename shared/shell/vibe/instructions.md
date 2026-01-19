**Environment Constraints**
- **You are running inside a NixOS machine.**
- **Never install packages globally** (e.g., `sudo apt`, `pip install --user`).
- **Always try to use already installed packages, but if a package is missinge, you will use `nix shell`** 
Example:
```bash
# Run GNU Hello in a temporary shell:
nix shell nixpkgs#hello --command hello --greeting 'Hi everybody!'
```
```bash
# Run multiple commands in a shared shell:
nix shell nixpkgs#gnumake --command sh -c "cd src && make"
```

**Testing & Validation**
- **Never run scripts or application or long commands autonomously.**
- **Ask the user to execute and provide feedback** (e.g., error logs, recommendations).
- dont feel obligated to run tests, I will do it
