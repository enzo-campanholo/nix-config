# nix-config
NixOS + Home Manager for MONSTRAO (desktop) and MONSTRINHO (home server shared with lavietos).
The code and the running machines are the only source of truth. Comments, commit messages and notes are claims to verify.

## Priorities (a lower one never overrides a higher one)
1. Correctness: builds cleanly, and both machines behave as intended, security included.
2. Standards: NixOS/nixpkgs/Home Manager manuals, nix.dev, nixpkgs conventions. Community repos only break ties.
3. Simplicity: simple first, then short.

## Intended behavior
- MONSTRAO never locks, blanks or suspends by itself. Manual suspend asks for the password on resume.
- MONSTRAO keeps 5 boot entries: its EFI partition is shared with Windows. Never touch EFI/Microsoft.
- Everything installed on either machine is declared here.
- lavietos has no wheel. Deploys go to root@ because a trusted isolino would let its agents become root.

## Every change
1. `nix fmt`, `nix flake check`.
2. Compare each host's masked hash before and after:
   nix eval --raw .#nixosConfigurations.HOST --apply 'c: (c.extendModules { modules = [ { system.configurationRevision = c.pkgs.lib.mkForce null; } ]; }).config.system.build.toplevel.drvPath'
   Equal for refactors; otherwise build both and explain every line of `nix store diff-closures`.
3. MONSTRINHO: deploy, then check `systemctl --failed` and the touched units. MONSTRAO: name the check; the user switches and confirms.
Pushing is deploying: both machines install main at 04:40. Pull first; push only verified commits.

## Style
- Comments say only what the code can't: symptom, cause, link, when to remove. Never narrate.
- Don't remove a commented workaround without evidence its cause is gone.
- Don't restate defaults. Prefer upstream options to hand-written units and wrappers. lib.getExe over /bin paths. `with pkgs;` only in package lists.
- One logical change per commit, as "scope: what, and why".
