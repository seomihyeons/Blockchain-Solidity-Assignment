// Name: Mihyeon Seo
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract StudentRecord {
    struct Student {
        uint256 id;
        string name;
        uint256 score;
    }

    mapping(uint256 => Student) private students;
    mapping(uint256 => bool) private studentExists;

    uint256 public totalMemory;
    uint256 public totalCalldata;

    // Add a new student; use calldata for the name argument.
    function addStudent(uint256 id, string calldata name, uint256 score) external {
        require(!studentExists[id], "Student ID already exists");
        students[id] = Student(id, name, score);
        studentExists[id] = true;
    }

    // Return student data, reverting for an unknown ID.
    function getStudent(uint256 id)
        external view returns (uint256, string memory, uint256)
    {
        require(studentExists[id], "Student ID does not exist");
        Student storage student = students[id];
        return (student.id, student.name, student.score);
    }

    // Modify a temporary memory copy only.
    function updateScoreMemory(uint256 id, uint256 newScore)
        external view returns (uint256)
    {
        require(studentExists[id], "Student ID does not exist");
        Student memory student = students[id];
        student.score = newScore;
        return student.score;
    }

    // Modify the original student record in storage.
    function updateScoreStorage(uint256 id, uint256 newScore) external {
        require(studentExists[id], "Student ID does not exist");
        Student storage student = students[id];
        student.score = newScore;
    }

    // Accumulate memory-array values; write to state so Remix reports gas.
    function sumScoresMemory(uint256[] memory scores) external {
        uint256 total = 0;
        for (uint256 i = 0; i < scores.length; i++) {
            total += scores[i];
        }
        totalMemory = total;
    }

    // Accumulate calldata-array values; write to state so Remix reports gas.
    function sumScoresCalldata(uint256[] calldata scores) external {
        uint256 total = 0;
        for (uint256 i = 0; i < scores.length; i++) {
            total += scores[i];
        }
        totalCalldata = total;
    }
}
