// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/AgentIDBadge.sol";

contract MockAgentID {
    mapping(address => uint256) public balances;

    function setBalance(address who, uint256 bal) external {
        balances[who] = bal;
    }

    function balanceOf(address owner) external view returns (uint256) {
        return balances[owner];
    }
}

contract AgentIDBadgeTest is Test {
    AgentIDBadge public badge;
    MockAgentID public mock;
    address constant AGENT_ID_ADDR = 0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F;

    address holder = address(0xA11CE);
    address nonHolder = address(0xB0B);

    function setUp() public {
        mock = new MockAgentID();
        mock.setBalance(holder, 1);
        mock.setBalance(nonHolder, 0);
        // Etch the mock over the real Agent ID address so the badge's hardcoded
        // gate can be tested locally.
        vm.etch(AGENT_ID_ADDR, address(mock).code);
        // Copy mock storage into the etched account.
        MockAgentID etched = MockAgentID(AGENT_ID_ADDR);
        etched.setBalance(holder, 1);
        badge = new AgentIDBadge();
    }

    function testMintHolderOk() public {
        vm.prank(holder);
        badge.mint();
        assertEq(badge.ownerOf(1), holder);
        assertEq(badge.balanceOf(holder), 1);
        assertEq(badge.totalSupply(), 1);
        assertTrue(badge.hasMinted(holder));
    }

    function testMintNonHolderReverts() public {
        vm.prank(nonHolder);
        vm.expectRevert(AgentIDBadge.AgentIDRequired.selector);
        badge.mint();
    }

    function testDoubleMintReverts() public {
        vm.prank(holder);
        badge.mint();
        vm.prank(holder);
        vm.expectRevert(AgentIDBadge.AlreadyMinted.selector);
        badge.mint();
    }

    function testTransferReverts() public {
        vm.prank(holder);
        badge.mint();
        vm.prank(holder);
        vm.expectRevert(AgentIDBadge.Soulbound.selector);
        badge.transferFrom(holder, nonHolder, 1);
        vm.prank(holder);
        vm.expectRevert(AgentIDBadge.Soulbound.selector);
        badge.safeTransferFrom(holder, nonHolder, 1);
    }

    function testApproveReverts() public {
        vm.prank(holder);
        badge.mint();
        vm.prank(holder);
        vm.expectRevert(AgentIDBadge.Soulbound.selector);
        badge.approve(nonHolder, 1);
    }

    function testTokenURI() public {
        vm.prank(holder);
        badge.mint();
        string memory uri = badge.tokenURI(1);
        assertTrue(bytes(uri).length > 100);
        // Must start with the data URI prefix.
        assertEq(bytes(uri)[0], bytes1("d"));
    }

    function testTokenURINonexistentReverts() public {
        vm.expectRevert(AgentIDBadge.NonexistentToken.selector);
        badge.tokenURI(99);
    }

    function testSupportsInterface() public {
        assertTrue(badge.supportsInterface(0x80ac58cd));
        assertTrue(badge.supportsInterface(0x01ffc9a7));
        assertTrue(badge.supportsInterface(0x5b5e139f));
        assertFalse(badge.supportsInterface(0xffffffff));
    }

    function testMintIsFree() public {
        uint256 before = holder.balance;
        vm.prank(holder);
        badge.mint();
        assertEq(holder.balance, before); // no BNB taken by the contract
    }
}
