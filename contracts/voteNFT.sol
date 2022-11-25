// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VoteNFT is ERC1155, Ownable {
    mapping(string => uint8) public ROLES;

    constructor() public ERC1155("https://vote.example/api/item/{id}.json") {}

    function safeMint(string memory _role, address _receiver, uint8 _amount) public onlyOwner {
        uint8 role = ROLES[_role];
        _mint(_receiver, role, _amount, "");
    }

    function addRole(string memory _role, uint8 _id) public onlyOwner {
        ROLES[_role] = _id;
    }

    function removeRole(string memory _role) public onlyOwner {
        delete ROLES[_role];
    }
}