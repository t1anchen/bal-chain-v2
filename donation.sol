pragma solidity ^0.4.24;

contract Donation {

    uint amount;
    uint last_created;
    bytes32 tx_id;
    Donator donator;
    Project project;
    ServiceProdiver sp;
    Evaluator evaluator;

    address evidence;

    mapping(address => Project) projects;
    mapping(address => Donator) donators;
    mapping(address => ServiceProdiver) serviceProviders;
    mapping(address => Evaluator) evaluators;
    mapping(address => bytes32) acknowledge;

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

    struct ServiceProdiver {
        address account;
        uint karma;
    }

    struct Evaluator {
        address account;
        uint karma;
    }

    constructor(uint amount_from_donator, address donator_addr, address proj_addr) public {
        amount = amount_from_donator;
        last_created = now;
        tx_id = keccak256(abi.encodePacked(donator_addr, last_created, amount_from_donator));
        donator = donators[donator_addr];
        project = projects[proj_addr];
    }

    function service_fee() public view returns(uint) {
        return amount * 10 / 9;
    }

    function evaluation_fee() public view returns(uint) {
        return amount * 100 / 5;
    }

    function donate() public {

        require(msg.sender == donator.account, "donation must be performed by a donator");

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

    function serve(Evidence work) public {
        sp = serviceProviders[msg.sender];
        work.provide(sp.account);
        evidence = work;
    }

    function evalute(Evaluation work) public {
        evaluator = evaluators[msg.sender];
        work.evaluate(evaluator.account);
    }

}

contract Evidence {

    enum State {
        UNACKED,
        UNVERIFIED,
        VERIFIED
    }

    struct Evaluator {
        address account;
        uint karma;
    }

    mapping(address => Evaluator) evaluators;

    ServiceProdiver sp;
    Evaluator evaluator;
    Donation donation;
    State public phase;
    bytes32 checksum;

    constructor(bytes32 _checksum, Donation related) public {
        checksum = _checksum;
        phase = State.UNACKED;
        donation = related;
    }

    struct ServiceProdiver {
        address account;
        uint karma;
    }

    mapping(address => ServiceProdiver) serviceProviders;

    function provide(address server_addr) public {
        sp = serviceProviders[server_addr];
        phase = State.UNVERIFIED;
    }

    function acknowledge(address evaluator_addr) public {
        evaluator = evaluators[evaluator_addr];
        phase = State.VERIFIED;
        sp.karma += donation.service_fee();
    }

}

contract Evaluation {

    Evidence evidence;
    Donation donation;
    Evaluator evaluator;

    mapping(address => Evaluator) evaluators;

    struct Evaluator {
        address account;
        uint karma;
    }

    constructor(Evidence work, Donation related) public {
        evidence = work;
        donation = related;
    }

    mapping(address => bool) verify;

    function evaluate(address evaluator_addr) public {
        evaluator = evaluators[evaluator_addr];
        evaluator.karma += donation.evaluation_fee();

        if (verify[evidence]) {
            evidence.acknowledge(evaluator.account);
        }
    }
}
