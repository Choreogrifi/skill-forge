The following changes must be done to the code base;

1. /skills folder must contain subfolders /sme & /workflow.
- /sme contains type sme skills
- /workflow contains workflow skills

2. Workflow skills in /skills/workflow must contain the following;
- SKILL.md
- Subflows for each action the skill can execute, [skill-name]-[action]-sf.md
- Templates for documents that the flow and subflows can use.

3. Read all SME in /skills/sme and where there is a empty SKILL.MD file, create a persona sme type content using a template. If a template for the file does not exists, add it to the root of the project in a /templates folder. If the folder does not exist, add it.

4. Each SME must have a small, powerful SKILL.MD file that introdcues it and its capabilities.

5. For each /skills/sme, where it makes sense, create a workflow and subflows. The followig SME skills would likely have more than a single workflow;
- Git SME;
    - The workflows, must be able to handle Github and Gitlab.
    - If there is significant differences in the products, consider a Github and Gitlab SME with their own workflof and subflow structure.
 - Document & Diagram SMEs
    - Should be generic skills, but be able to have knowledge of various formats.
    - To start only cater for the following document types;
        - Diagram should understand creating and reading Mermaid diagrams
        - Document should understand creating and reading Markdown diagrams
        - Other document skills can be added later.
- Skills SME;
    - It must be able to;
    - Create a skill by prompting the user, using the create_skill_template.md.
    - Discover skills while a user is engaging with the LLM in the CLI. It must function as per the discovery rule in the memory.md file.
    - All other skill functions, must be part of the agents.sh script.
        - Consider changing agents.sh to something that will not clash with the name "agents", maybe keep it "skillforge" 

6. Review each skill and how it is implemented to ensure that the following rules apply;
- Effective and efficient memory management.
- Token efficient.
- Strictly adheres to the single responsibility rule.
- Only uses what is needed.
- When no longer required, can eject from memory.

7. Review all templates in /templates;
- Fix what does not adhere to the required formats for LLMs like Claude and Gemini.
- Add additional templates of contents to make it more robust.
- Suggest only where a template item or artefact does not make sense.

8. Review the entire solution;
- For example, does a memory-sme make sense? Is it not a bloat skill, i.e. does the LLM not manage this or would it be of value to the user to have this as a guide to monitor usage of memory, tokens and context.

9. SME should be able to in their SME topic be able to;
- Always read in plan mode.
- Perform an action when approved by the user.
- For SMEs like GIT and GCP only create workflows and subflows for the most common commands normally used by a user. Additional workflows and subflows can be discovered and added to the repo by users.

10. Additional feautures that Skill Forge must offer are;
- Consider allowing skills to be invoked directly from the command line, i.e. skillforge claude add-new-skill, skillforge git add-new-repo. Where it makes sense if a llm is not directly required, use the CLI.
- Consider a python wrapper for skills that can be diretly used from the command line.
- Add robust help to skillforge, so that a user does not have to be in a LLM to be able to discover the functionality.
- Allow a user to add a LLM;
    - This process must create all resources required, i.e symlinks.
- When the Skill SME detects that a new SME skill or workflow can be created;
    - Add it silently to the Skill Forge install folder.
    - Send an email to the user at the email address that is provided when installing Skill Forge.
    - Allow the user to use the Skill SME in the LLM to review and refine the Skill SME, workflow or subflow.
    - The user should be allowed to approve or reject the new ite,/artefact;
        - If the user approves, use the Git SME to create a pull request in the Skill Forge repository and email me to review it.
        - If the user rejects the new item/artefact, delete it from the Skill Forge install folder.
For consideration, can logging be used or does it increase overhead and cost?

11. Governing rules;
- Ensure that all skills are aware of memory and workflows, but do not have any dependencies to them.
- Lazy loading and unloading is critical.
- When installing the user must be able to select (allow multi-selections) what skills they want to install and also for which LLM;
    - Start with Claude and Gemini only.
- Skills added to this repository should never be allowed to contain any personal personas, all SME personas must be generic and satisfy a specific use case, be it technical, administrative and be able to amplify a user who needs guidance on a specific SME topic.
- For a personal persona, i.e. the one that is symlinked to .gemini/GEMINI.md and claude/CLAUDE.md;
    - These types of files must never be committed to GIT, it remains a local resource for the user.
    - The skills SME must be able to guide a user to create their specific persona model.md file and save it locally to a .sourcforge folder.
        - This folder must be created at installation and a dummy model.md file must be created.
        the file in sourceforge/model.md must be symlinked to the selected LLMs specific folders.
- At installation any tools that are required must be verified by the installation or the user, i.e is Git/Gh available and does the user have a account.
- Record all these in a config.yaml file in the .skillforge folder.
- The installation, i.e via Brew, apt, winget or other must create the files in the users home folder.
- For consideration, should the installed folder be read only?

12. Documentation;
- Each subfolder must have its own README.md file that clearly explains in detail how the functionality is used. For consideration, should this be included in the installation or remain in the repo.
- In the root README.md, it must clearly be explained how this solution works, i.e. when and how are Skills activated/deactivated?, When is SME and dependent workflows, subflows and memory files inserted and flushed from memory. How are dependencies activated/deactivated?

13. Testing;
- Should there be a capability to test Skill Forge?

Objective;
- Understand the content of the file and validate it.
- Prompt me to gain insights to allow you to make better suggestions.
- Keep it simple, but powerful.
- Create the artefacts needed and restructure the folder to fit;
    
    ```bash
    .
    ├── docs
    │   ├── _config.yml
    │   ├── cli.md
    │   ├── getting-started.md
    │   ├── how-it-works.md
    │   ├── index.md
    │   ├── sitemap.xml
    │   └── skill-spec.md
    ├── LICENSE
    ├── memory
    │   ├── shared
    │   ├── sme
    │   ├── system
    │   └── workflow
    ├── migration.md
    ├── templates
    │   ├── persona
    │       └── model.md
    │   ├── sme
    │   ├── workflow
    │   ├── subflow
    │   └── memory
    ├── migration.md
    ├── README.md
    ├── scripts
    │   ├── agents.sh
    │   ├── check-skill-names.sh
    │   ├── hooks
    │   ├── install.sh
    │   └── refactor.sh
    └── skills
    │   ├── sme
    │       └── {skill-name}-sme.active
    │           ├── SKILL.MD
    │           └── References
    │   ├── workflow
    │       ├── {workflow-name}-wf.md
    │       ├── SKILL.MD
    │       └── References
    │       └── Subfows
    │           ├── {workflow-name}-{action-name}-sf.md
    ```
- Validate the the structure is fit for purpose.
- Ensure memory and references are not duplicated. All memory and reference dependencies must be consistent, unless the skill sme, flow or subflow needs a diferent one.