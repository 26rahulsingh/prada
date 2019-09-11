pragma solidity >=0.4.21 <0.6.0;

contract Owner {

    address public owners;

    modifier onlyOwner() {
        require( msg.sender == owners);
        _;
    }

    function changeOwner ( address _addr) onlyOwner public {
        owners = _addr;
    }
}