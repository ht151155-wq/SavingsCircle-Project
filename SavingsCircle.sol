
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IFactoryRegistry {
    function registerMember(address member) external;
}

contract SavingsCircle {

    address public creator;
    address public factory;
    string public circleName;

    uint256 public contributionAmount;
    uint256 public maxMembers;
    uint256 public roundDuration;
    uint256 public deadline;

    address public token;

    address[] public members;
    mapping(address => bool) public isMember;

    constructor(
        address _creator,
        address _factory,
        string memory _name,
        uint256 _contributionAmount,
        address _token,
        uint256 _maxMembers,
        uint256 _roundDuration,
        uint256 _deadline
    ) {
        creator = _creator;
        factory = _factory;
        circleName = _name;
        contributionAmount = _contributionAmount;
        token = _token;
        maxMembers = _maxMembers;
        roundDuration = _roundDuration;
        deadline = _deadline;

        members.push(_creator);
        isMember[_creator] = true;
    }

    function joinCircle() external {
        require(!isMember[msg.sender], "Already a member");
        require(members.length < maxMembers, "Circle is full");
        require(block.timestamp <= deadline, "Deadline passed");

        members.push(msg.sender);
        isMember[msg.sender] = true;

        IFactoryRegistry(factory).registerMember(msg.sender);
    }

    function getMembers()
        external
        view
        returns (address[] memory)
    {
        return members;
    }
}
