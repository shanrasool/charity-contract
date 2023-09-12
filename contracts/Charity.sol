// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

error NotOwner();
error NotEnoughFund();

contract Charity {

    mapping(address => uint256) public s_addressToAmount;
    address[] public s_donators;

    uint256 private constant MIN_FUND = 0.001 ether;
    address private immutable i_owner;

    event DonationAdded(address indexed donator);

    constructor() {
        i_owner = msg.sender;
    }

    function fund () public payable {
        if (msg.value < MIN_FUND) {revert NotEnoughFund();}
        s_addressToAmount[msg.sender] += msg.value;
        s_donators.push(msg.sender);
        emit DonationAdded(msg.sender);
    }

    function withdraw() public onlyOwner {
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");

        require(callSuccess, "Call failed"); 
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) {revert NotOwner();}
        _;
    }

    function getDonator(uint256 index) public view returns(address){
        return s_donators[index];
    }

    function getMinimumAmountToFund() public pure returns(uint256) {
        return MIN_FUND;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

}