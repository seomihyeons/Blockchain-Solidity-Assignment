# Experimental Report: Memory, Storage, and Calldata in Solidity

**Student:** Mihyeon Seo  
**Environment:** Remix VM · Solidity 0.8.34  
**Experimental values:** Set 1 — starting score 80, target score 95, array length 20

I used Set 1 because the assignment did not explain how the sets were assigned to students.

## Purpose and implementation

The goal of this assignment was to learn the difference between `memory`, `storage`, and `calldata` in Solidity. I made a `StudentRecord` contract with a `Student` struct (`id`, `name`, and `score`) and a mapping to find students by ID. I added the six required functions: `addStudent`, `getStudent`, `updateScoreMemory`, `updateScoreStorage`, `sumScoresMemory`, and `sumScoresCalldata`. The last two functions save their sums in state variables so I could compare their gas costs in Remix.

## Experiment A — memory vs. storage

**Prediction:** I expected the memory function to return 95 while the saved score stayed at 80. I expected the storage function to change the saved score to 95.

| Operation | Observed result |
|---|---|
| `addStudent(1,"Mihyeon",80)`, then `getStudent(1)` | Student `(1, Mihyeon, 80)` |
| `updateScoreMemory(1,95)` | Returned `95` |
| `getStudent(1)` after memory update | Stored score still `80` |
| `updateScoreStorage(1,95)`, then `getStudent(1)` | Stored score now `95` |

**What I learned:** With `memory`, I changed a copy of the student record, so `getStudent` still returned 80. With `storage`, I changed the actual saved record, so `getStudent` returned 95.

## Experiment B — calldata is read-only

**Prediction:** I expected a compiler error when trying to change `numbers[0]` directly in `calldata`. I expected it to work after copying the array into `memory`.

**Result:** When I tried `numbers[0] = 100;`, Remix showed **`TypeError: Calldata arrays are read-only.`** Next, I used `uint256[] memory copiedNumbers = numbers;` and changed `copiedNumbers[0]` to 100. This compiled successfully, and `testCalldata([10,20,30])` returned **100**. So I could read the calldata array, but I had to make a memory copy to change its values.

## Experiment C — gas comparison

**Prediction:** I expected `sumScoresCalldata` to use less gas because the input array does not need to be copied into memory.

I used the same 20 numbers, `[1,2,...,20]`, for both functions. Their sum should be 210.

| Measure | Memory | Calldata |
|---|---:|---:|
| Transaction cost | **57,759 gas** | **52,905 gas** |
| Execution cost | **33,615 gas** | **28,761 gas** |

**Result:** `sumScoresCalldata` used **4,854 less gas** than `sumScoresMemory`, which is about **8.4% less** in transaction cost. This matches my prediction: reading from calldata can save gas by avoiding an extra memory copy. The exact gas amount can change depending on the code and execution settings. I calculated 210 from the input numbers, but the gas screenshots do not show the stored totals.

## Conceptual questions

**1. What is the difference between memory, storage, and calldata?** `storage` keeps data in the contract after a function ends. `memory` is temporary data used while a function runs. `calldata` holds input data and cannot be changed directly.

**2. Why doesn't changing memory change the original data?** The value in memory is a copy, so changing it does not update the student stored in the mapping.

**3. Why does changing storage update the original data?** A storage reference points to the student record itself, so the changes are saved.

**4. What happens to memory after the function ends?** The temporary data is no longer kept as part of the contract state.

**5. Why does storage cost more gas?** Saving data in the blockchain state usually takes more gas than working with temporary memory.

**6. Why can't calldata be changed, and why can it be cheaper?** Calldata is a read-only area for function inputs. If a function only needs to read the input, it may save gas by avoiding a memory copy.

**7. Why did I use `string calldata name` in `addStudent`?** The function only needs to read the name and save it. Using `memory` would also work, but it would create another copy of the input and could cost more gas. The name still needs to be written to storage.

**Screenshots:** See [README.md](README.md#remix-experiment-screenshots).  
**References:** [Solidity documentation](https://docs.soliditylang.org/) and [Remix IDE](https://remix.ethereum.org/).
