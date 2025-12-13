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

# **Planning Phase**
**Activation**
- **Only proceed to planning if the user explicitly requests it** (e.g., by typing `plan`, `brainstorm`).
- **Do not write code during planning.** Focus on:
1. **Exploring the codebase** (e.g., `ls`, `cat`, `tree`).
2. **Imagining ideas based on the subject and seen code (the user want to brainstorm with you before writing code)**
3. **Generating a structured plan**

**User Approval**
- **Present the plan as a numbered list**
- **Ask user if you can proceed the implementation for next prompt**
