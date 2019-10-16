pragma solidity ^0.4.24;

contract Donation {

    uint amount;
    uint last_created;
    bytes32 tx_id;
    uint service_fee; // ufix type cannot be assigned, use uint instead
    uint evaluation_fee; // ufix type cannot be assigned, use uint instead
    Donator donator;
    Project project;

    bytes32 evidence;

    mapping(address => Project) projects;
    mapping(address => Donator) donators;

    struct Project {
        address funding;
        bool is_active;
        Donation[] pending;
        uint target;
    }

    struct Donator {
        address account;
        uint karma;
    }

    constructor(uint amount_from_donator, address donator_addr, address proj_addr) public {
        amount = amount_from_donator;
        last_created = now;
        tx_id = keccak256(donator_addr, last_created, amount_from_donator);
        service_fee = amount_from_donator * 10 / 9;
        evaluation_fee = amount_from_donator * 100 / 5;
        donator = donators[donator_addr];
        project = projects[proj_addr];
    }

    function donate() public {
        if (project.is_active) {
            if (donator.account.balance > amount) {
                project.funding.transfer(amount);
                donator.karma += amount;
            }
        }

        if (project.funding.balance >= project.target) {
            project.is_active = false;
        }

        project.pending.push(this);
    }

}
