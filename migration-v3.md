1. Fix all skill files and temapltes;
- The description attribute must be in the header of the frontmatter and not in metadata.
- The version attribute must not be in the header of the frontmatter, it must be in metadata.

2. Naming conventions;
- Workflow names shoud be the {sme-name}-wf.md, remove all words like manage, add, create, drawer, review, creator. Only use the SME name that references the workflow, if the workflow should be dynamic use a generic descriptive name and ensure all references are updated.
- Subflow names must always follow the format of {flow-name}-{action-name}-sf.md, also remove the names as in the above point.