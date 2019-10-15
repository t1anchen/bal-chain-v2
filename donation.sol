pragma solidity ^0.4.10;

contract Donation {

    uint amount;
    string unit;
    mapping(address => Donator) donators;


    struct Donator {
        address id;
        string name;
        uint factor;
    }

    struct ServiceProvider {
        address id;
        string name;
        uint factor;
    }

    constructor(address donotor, uint amount) {
        amount = amount;
        unit = "RMB";
        donators[donotor].factor += amount;
    }

    


}
