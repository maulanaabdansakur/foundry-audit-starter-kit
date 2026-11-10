# Foundry Smart Contract Audit Starter Kit — Free Sample

A ready-to-run Foundry project for learning and practicing smart contract
security review. This is the **free sample** of the full kit — it includes
the audit checklist and a working proof-of-concept that demonstrates a real
vulnerability (first-depositor share inflation).

## What's in the free sample

| File | What it is |
| --- | --- |
| `CHECKLIST.md` | The audit checklist: 12 sections, 60+ checks, organized by vulnerability class |
| `src/MockToken.sol` | A minimal ERC20 used by the tests |
| `src/VulnerableVault.sol` | An ERC4626-style vault with the bug planted — practice target, do not deploy |
| `test/ExploitDemo.t.sol` | Proof-of-concept test: the first-depositor inflation exploit |
| `foundry.toml` | Foundry configuration (solc 0.8.20, remappings) |

## The full kit ($49)

The complete kit adds the fixed reference vault (`Vault.sol`), the full
4-test PoC suite (exploit + fix + round-trip + fork template), the
finding-report template with a filled example report, and the `.env`
fork-test setup.

Get it here: [Gumroad](https://maulanaabdansakur.gumroad.com/l/foundry-smart-contract-audit-starter-kit) · [Payhip](https://payhip.com/b/dqX9G)

## Requirements

- [Foundry](https://book.getfoundry.sh/getting-started/installation) (`forge`
  1.x).
- `forge-std` — it is a submodule, so clone with `--recursive`, or install
  it once:

```bash
forge install foundry-rs/forge-std
```

(The ZIP sold on Gumroad/Payhip includes `forge-std` vendored, so it
works out of the box, offline.)

## Quickstart

```bash
forge build
forge test -vv
```

You should see the exploit test pass: the attacker deposits 1 wei,
donates 1,000,000 tokens to the vault, the victim's 100,000-token deposit
rounds to 0 shares — and the attacker's single share drains the pool.

## The practice bug (spoilers)

`VulnerableVault` omits the virtual-shares offset and the zero-share
check in `deposit()`. A first depositor of 1 wei gets 1 share; a large
donation then inflates the share price so far that a later depositor's
shares round to zero — their tokens are locked in the vault, and the
attacker's single share becomes worth (almost) the whole pool.
The full kit's `Vault.sol` fixes it with a virtual offset (1000 virtual
shares, 1 virtual asset), the same technique used by OpenZeppelin's
ERC4626.

## Disclaimer

This kit is educational material. It does not guarantee that you will
find vulnerabilities, and passing its tests does not mean a contract is
safe. Real audits require manual review on top of any checklist or tool.
Never test against a live network with real funds — use local tests and
forks only.

## Version

v1.0 — November 2026. License: MIT (see `LICENSE`).
