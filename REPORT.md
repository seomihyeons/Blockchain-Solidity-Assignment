# Experimental Report: Memory, Storage, and Calldata in Solidity

**Student:** Mihyeon Seo  
**Environment:** Remix VM · Solidity 0.8.34  
**Experimental values:** Set 1 — starting score 80, target score 95, array length 20

*Set-selection note:* The handout lists five sets but provides no student-to-set assignment rule. I used Set 1; this should not be taken as confirmation that Set 1 was individually assigned.

## Objective and implementation

I implemented a `StudentRecord` contract to investigate the different data locations in Solidity. It has a `Student` struct with `id`, `name`, and `score`, plus an ID-to-student mapping. The six required functions are `addStudent`, `getStudent`, `updateScoreMemory`, `updateScoreStorage`, `sumScoresMemory`, and `sumScoresCalldata`. The score-summing functions store their outputs in state variables so their transactions have measurable gas costs.

## Experiment A — memory vs. storage

**Prediction before execution:** The memory function will return 95 but will not change the stored score of 80. The storage function will change the original score to 95.

| Operation | Observed result |
|---|---|
| `addStudent(1,"Mihyeon",80)`, then `getStudent(1)` | Student `(1, Mihyeon, 80)` |
| `updateScoreMemory(1,95)` | Returned `95` |
| `getStudent(1)` after memory update | Stored score still `80` |
| `updateScoreStorage(1,95)`, then `getStudent(1)` | Stored score now `95` |

A `memory` variable contains a temporary copy of the struct, so editing it does not modify the mapping entry. A `storage` reference points to the original record, so its changes persist.

## Experiment B — calldata is read-only

**Prediction before execution:** Assigning to `numbers[0]` in a `calldata` array will fail compilation, but editing a copied `memory` array will work.

The direct assignment `numbers[0] = 100;` generated **`TypeError: Calldata arrays are read-only.`** I then copied the input using `uint256[] memory copiedNumbers = numbers;`. After setting `copiedNumbers[0] = 100;`, the contract compiled successfully. Calling `testCalldata([10,20,30])` returned **100**. This verifies that calldata is immutable while its independent memory copy is writable.

## Experiment C — gas comparison

**Prediction before execution:** The calldata function will use less gas because no complete input-array copy is required.

Both functions received the same 20 integers, `[1,2,...,20]`, whose expected sum is 210.

| Measure | Memory | Calldata |
|---|---:|---:|
| Transaction cost | **57,759 gas** | **52,905 gas** |
| Execution cost | **33,615 gas** | **28,761 gas** |

The calldata variant used **4,854 less gas**, a reduction of approximately **8.4%** in transaction cost. The measured saving is consistent with avoiding a memory copy. Exact differences depend on the program and execution settings. The sum of 210 is calculated from the inputs; the supplied gas screenshots do not independently show the stored total values.

## Conceptual questions

**1. Difference between memory, storage, and calldata:** `storage` is persistent contract state; `memory` is temporary, writable data during execution; `calldata` is read-only data supplied to a call.

**2. Why does a memory edit not change the original?** The memory struct is a separate copy rather than the mapping's underlying record.

**3. Why does a storage edit change the original?** The storage reference refers directly to the same persistent struct.

**4. What happens after a function finishes?** Temporary memory contents do not persist as contract state after execution.

**5. Why is storage more expensive?** Persisting and updating blockchain state generally costs more gas than using temporary working memory.

**6. Why is calldata immutable and potentially cheaper?** It is a read-only function-input area. Reading directly from it can avoid a separate memory allocation and copy.

**7. Why `string calldata name` in `addStudent`?** The function only needs to read the supplied name before storing it. Using `memory` would still work but would require an intermediate copy and might use more gas. The eventual storage write is required in either case.

**Evidence:** Actual Remix screenshots are embedded in [README.md](README.md#remix-experiment-screenshots).  
**References:** [Solidity documentation](https://docs.soliditylang.org/) · [Remix IDE](https://remix.ethereum.org/).
