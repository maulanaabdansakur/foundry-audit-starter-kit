# Smart Contract Audit Checklist

Work through this checklist section by section against the target
contracts. For every check, record one of:

- **PASS** — checked, no issue
- **FAIL** — issue found (open a finding, see `REPORT-TEMPLATE.md`)
- **N/A** — does not apply, with a one-line reason
- **OPEN** — could not answer yet, come back to it

A check you cannot answer is not a pass.

---

## 0. Before you start

- [ ] Scope confirmed: which contracts, which version/commit, which chains?
- [ ] Documentation read: README, specs, NatSpec, deployment scripts.
- [ ] Roles mapped: who is owner/admin/operator, and what can each do?
- [ ] Trust assumptions written down: what is trusted, what is not?
- [ ] External dependencies listed: oracles, tokens, bridges, other protocols.
- [ ] Previous audit reports read (if any): known issues already covered?

## 1. Access control

- [ ] Every privileged function has an access check (owner/role/guard)?
- [ ] No function is accidentally `public`/`external` when it should be restricted?
- [ ] Role changes (grant/revoke/transfer ownership) are themselves protected?
- [ ] No `tx.origin` used for authorization (use `msg.sender`)?
- [ ] Initializers can only run once, and only by the deployer?
- [ ] No function lets an arbitrary caller act as another user (missing `msg.sender` check)?

## 2. Reentrancy

- [ ] State is updated before external calls (checks-effects-interactions)?
- [ ] Functions that move funds use a reentrancy guard where needed?
- [ ] No callback (ERC721/ERC777/token receiver hooks) can re-enter a
      sensitive function mid-execution?
- [ ] Cross-function reentrancy checked: can function A be re-entered
      through function B?
- [ ] Read-only reentrancy considered: can a view function be tricked
      mid-transaction?

## 3. Oracles and prices

- [ ] No price is taken from a single, manipulable source (spot price, single DEX pool)?
- [ ] Oracle prices are checked for staleness (timestamp/round freshness)?
- [ ] No user-supplied price is trusted without validation?
- [ ] TWAP / multi-source prices used where the value at stake is large?
- [ ] Price is part of any signed message it affects (EIP-712 digest)?
- [ ] Decimals handled correctly when combining prices from different sources?

## 4. Arithmetic and rounding

- [ ] Multiplication before division wherever precision matters?
- [ ] Rounding direction favors the protocol, not the user, on mint/withdraw?
- [ ] First-depositor inflation checked (tiny first deposit + donation)?
- [ ] Share math protected by a virtual offset or minimum deposit?
- [ ] No division by zero (zero total supply / zero total assets paths)?
- [ ] Overflow/underflow impossible (Solidity 0.8+ checks, or explicit guards)?
- [ ] No precision loss that lets dust amounts mint value from nothing?

## 5. Front-running and MEV

- [ ] Price-sensitive actions have slippage/deadline protection?
- [ ] No operation executes at a stale price (oracle update delay)?
- [ ] Commit-reveal or ordering protection where the order of transactions
      decides the outcome?
- [ ] Sandwich-vulnerable flows identified (large swaps, liquidations)?

## 6. Signatures

- [ ] EIP-712 domain includes chain ID and contract address?
- [ ] Every signature has a nonce (replay within the contract impossible)?
- [ ] Signatures expire (deadline) where appropriate?
- [ ] `ecrecover` return value checked (zero address rejected)?
- [ ] ECDSA malleability handled (`s` in the lower half, or OpenZeppelin's ECDSA)?
- [ ] No signature is verified against a caller-supplied claim without
      checking the signer matches the claimed identity?

## 7. Upgradeability and proxies

- [ ] Storage layout matches between proxy and implementation (no collisions)?
- [ ] `initialize` cannot be called twice or by an attacker (front-running)?
- [ ] Upgrade function is access-controlled, ideally timelocked?
- [ ] New implementation keeps the same storage gaps/slots?
- [ ] UUPS: `authorizeUpgrade` protected; no implementation left
      uninitialized and destructible?
- [ ] No `delegatecall` to untrusted addresses?

## 8. Token integration

- [ ] Fee-on-transfer / rebasing / non-standard ERC20 tokens handled?
- [ ] Token decimals never assumed to be 18?
- [ ] Return values of `transfer`/`transferFrom` checked (some tokens
      return nothing instead of reverting)?
- [ ] Approvals use safe patterns (no unlimited approval to untrusted contracts)?
- [ ] `transferFrom` caller is the approved spender, not an arbitrary address?

## 9. Denial of service and gas

- [ ] No unbounded loops over user-controlled arrays?
- [ ] No operation whose cost grows with the number of users?
- [ ] Pull-over-push used for mass payouts (users withdraw instead of the
      contract looping over recipients)?
- [ ] No griefing vector (an attacker making others' transactions fail)?

## 10. Centralization and admin power

- [ ] Owner/admin powers listed and justified (pause, mint, upgrade, fees)?
- [ ] No single EOA can drain funds or brick the protocol?
- [ ] Timelock or multisig on critical admin actions?
- [ ] Fee changes bounded (no 100% fee, no sudden rug)?
- [ ] Emergency pause exists and is itself access-controlled?

## 11. Randomness

- [ ] No `blockhash(block.number)` (always zero) or `block.timestamp`
      used as a randomness source?
- [ ] No randomness derived from data the caller controls?
- [ ] Chainlink VRF or equivalent used where fairness matters?

## 12. Logic and business rules

- [ ] Invariants written down and tested (e.g. total shares vs total assets)?
- [ ] Edge cases covered: zero amounts, first user, last user, empty pool?
- [ ] State machine transitions valid (no impossible states reachable)?
- [ ] Time-based logic handles long gaps (no updates for months)?
- [ ] Every error path leaves funds recoverable (no permanent lock)?

---

## After the checklist

1. Re-read every FAIL and write a finding (see `REPORT-TEMPLATE.md`).
2. Re-check every OPEN item before calling the audit done.
3. Write the PoC for each High/Critical finding and run it with
   `forge test`.
4. Summarize: what was checked, what was found, what was explicitly
   not checked.
