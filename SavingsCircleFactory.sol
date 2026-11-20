
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./SavingsCircle.sol";

contract SavingsCircleFactory {

    address public owner;

    address[] public allCircles;

    mapping(address => bool) public approvedTokens;
    mapping(address => bool) public isCircle;

    mapping(address => address[]) private circlesByCreator;
    mapping(address => address[]) private circlesByMember;

    mapping(address => mapping(address => bool))
        private memberRegistered;

    event CircleCreated(
        address indexed circleAddress,
        address indexed creator,
        string name
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setApprovedToken(
        address token,
        bool approved
    ) external onlyOwner {
        require(token != address(0), "Invalid token");
        approvedTokens[token] = approved;
    }

    function createCircle(
        string memory name,
        uint256 contributionAmount,
        address token,
        uint256 maxMembers,
        uint256 roundDuration,
        uint256 deadline
    ) external returns (address) {

        require(bytes(name).length > 0, "Name required");
        require(contributionAmount > 0, "Invalid amount");
        require(maxMembers >= 2 && maxMembers <= 10, "Invalid members");
        require(roundDuration >= 1 days, "Round too short");
        require(deadline > block.timestamp, "Deadline in past");
        require(approvedTokens[token], "Token not approved");

        SavingsCircle circle = new SavingsCircle(
            msg.sender,
            address(this),
            name,
            contributionAmount,
            token,
            maxMembers,
            roundDuration,
            deadline
        );

        address circleAddress = address(circle);

        allCircles.push(circleAddress);
        circlesByCreator[msg.sender].push(circleAddress);

        isCircle[circleAddress] = true;

        memberRegistered[circleAddress][msg.sender] = true;
        circlesByMember[msg.sender].push(circleAddress);

        emit CircleCreated(
            circleAddress,
            msg.sender,
            name
        );

        return circleAddress;
    }

    function registerMember(address member) external {
        require(isCircle[msg.sender], "Not an official circle");
        require(member != address(0), "Invalid member");
        require(
            !memberRegistered[msg.sender][member],
            "Already registered"
        );

        memberRegistered[msg.sender][member] = true;
        circlesByMember[member].push(msg.sender);
    }

    function getAllCircles()
        external
        view
        returns (address[] memory)
    {
        return allCircles;
    }

    function getCirclesByCreator(address creator)
        external
        view
        returns (address[] memory)
    {
        return circlesByCreator[creator];
    }

    function getCirclesByMember(address member)
        external
        view
        returns (address[] memory)
    {
        return circlesByMember[member];
    }
}
