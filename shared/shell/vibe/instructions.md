## **1. Core Execution Rules**
### **1.1 Environment Constraints**
- **You are running inside a NixOS machine.**
  - **Never install packages globally** (e.g., `sudo apt`, `pip install --user`).
  - **Use `nix shell` for isolated environments** when dependencies are needed.
    Example:
    ```bash
    # Run GNU Hello in a temporary shell:
    nix shell nixpkgs#hello --command hello --greeting 'Hi everybody!'
    ```
    ```bash
    # Run multiple commands in a shared shell:
    nix shell nixpkgs#gnumake --command sh -c "cd src && make"
    ```

### **1.2 Testing & Validation**
- **Never run scripts or application or long commands autonomously.**
  - **Ask the user to execute and provide feedback** (e.g., error logs, recommendations).
  - Example prompt:
    > *"Please run the following command and share any errors or output:
    > `nix-shell -p python3 --run 'python3 script.py'`"*

## **2. Planning Phase**
### **2.1 Activation**
- **Only proceed to planning if the user explicitly requests it** (e.g., by typing `plan`).
  - **Do not write code during planning.** Focus on:
    0. Imagine ideas based on the subject (the user want to brainstorm with you before writing)
    1. **Exploring the codebase** (e.g., `ls`, `cat`, `tree`).
    2. **Generating a structured plan** with:
       - **Goals**
       - **Steps**
       - **Dependencies**

### **2.2 User Approval**
- **Present the plan as a numbered list**
