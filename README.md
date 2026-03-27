# MockAD

MockAD is a lightweight tool designed to simulate and visualize Active Directory (AD) environments. It is particularly useful for testing, education, and demonstrating AD concepts without requiring a full production deployment.

**Built with assistance from AI**

---
## 💡 About

MockAD was created to simplify the process of designing and understanding Active Directory environments without the overhead of deploying real infrastructure.

It blends familiarity with flexibility, giving administrators and engineers a safe space to experiment, learn, and document.

---

## 🚀 Features

* **Mock Active Directory Structure**

  * Create domains, OUs, users, gmsa, groups, policies, and computers
  * Drag & Drop items to move them around the tree
  * Ctrl+C and Ctrl+V to copy and paste a node and its children to another location

* **Visualization**

  * Tree-based UI similar to ADUC
  * Optional color formatting for tiering and security boundaries

* **Markdown Descriptions**

  * Add rich descriptions with edit mode and switch back to read mode for markdown preview
* **Validation Logic**

  * Simulate naming conventions and structural rules
<img width="1922" height="1034" alt="MockAD_RHm5UT5zWA" src="https://github.com/user-attachments/assets/39741592-d22f-4f99-b822-4fcaf6937417" />
<img width="1922" height="1034" alt="MockAD_NPEO4hzLdD" src="https://github.com/user-attachments/assets/1118c9c7-4e52-4f8f-a8a5-1eb886d2c908" />

* Powershell scripts are available in the repository to assist with importing current production environments into MockAD. You can look at the Wiki for more information. **Exercise caution when doing this in large environments, this will create large file sizes, and utilize large chunks of memory**
    * In testing a environment with ~20,000 users and 5,000 computers, hundreds of groups - an export from production is about ~400MB and utilizes ~1GB of memory.

---

## 🧠 Use Cases

* Lab simulation without standing up real domain controllers
* Demonstrating AD tiering and security models
* Training and documentation
* Planning OU structures before deployment
* Testing automation logic against a mock directory
  
---

## ⚙️ Getting Started

### Prerequisites

* Windows OS
* .NET Runtime / SDK (version depending on build target)

---

## 🎨 UI Overview

MockAD mimics the look and feel of traditional Active Directory tools:

* TreeView navigation similar to ADUC
* Context menus for object creation
* Icons inspired by legacy Microsoft tools

---

## ✏️ Markdown Support

Descriptions within MockAD support Markdown formatting:

* **Bold**, *Italic*
* Lists and tables
* Code blocks

This allows for rich documentation directly within the tool.
