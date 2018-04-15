pragma solidity 0.4.18;

import "truffle/Assert.sol";
import "./helpers/ThrowProxy.sol";

import "../contracts/common/DelegateProxy.sol";
import "../contracts/evmscript/ScriptHelpers.sol";


contract Target {
    function returnSomething() public pure returns (bool) { return true; }
    function dontReturn() {}
    function fail() { revert(); }
    function die() { selfdestruct(0); }
}


contract TestDelegateProxy is DelegateProxy {
    using ScriptHelpers for *;

    Target target;
    ThrowProxy throwProxy;

    // Mock ERCProxy implementation
    function implementation() public {
        return this;
    }

    function proxyType() public {
        return FORWARDING;
    }

    // Tests
    function beforeEach() {
        target = new Target();
        throwProxy = new ThrowProxy(address(this));
    }

    function testMinReturn0WithoutReturn() {
        delegatedFwd(target, target.dontReturn.selector.toBytes(), 0);
    }

    function testMinReturn0WithReturn() {
        delegatedFwd(target, target.returnSomething.selector.toBytes(), 0);
    }

    function testMinReturn32WithReturn() {
        delegatedFwd(target, target.returnSomething.selector.toBytes(), 32);
    }

    function testFailsIfReturnLessThanMin() {
        TestDelegateProxy(throwProxy).revertIfReturnLessThanMin();
        throwProxy.assertThrows("should have reverted if return data was less than min");
    }

    function revertIfReturnLessThanMin() {
        delegatedFwd(target, target.dontReturn.selector.toBytes(), 32);
    }

    function testFailIfNoContract() {
        TestDelegateProxy(throwProxy).noContract();
        throwProxy.assertThrows("should have reverted if target is not a contract");
    }

    function noContract() {
        delegatedFwd(address(0x1234), target.dontReturn.selector.toBytes(), 0);
    }

    function testFailIfReverts() {
        TestDelegateProxy(throwProxy).revertCall();
        throwProxy.assertThrows("should have reverted if call reverted");
    }

    function revertCall() {
        delegatedFwd(target, target.fail.selector.toBytes());
    }

    function testIsContractZero() {
        bool result = isContract(address(0));
        Assert.isFalse(result, "should return false");
    }

    function testIsContractAddress() {
        address nonContract = 0x1234;
        bool result = isContract(nonContract);
        Assert.isFalse(result, "should return false");
    }

    /* TODO: this test doesn't work with ganache. To be restablished when we use geth for tests
    function testSelfdestructIsRevertedWithMinReturn() {
        TestDelegateProxy(throwProxy).revertIfReturnLessThanMinAndDie();
        throwProxy.assertThrows("should have reverted to stop selfdestruct");
    }

    function revertIfReturnLessThanMinAndDie() {
        delegatedFwd(target, target.die.selector.toBytes(), 32);
    }
    */

    // keep as last test as it will kill this contract
    function testDieIfMinReturn0() {
        delegatedFwd(target, target.die.selector.toBytes());
    }
}
