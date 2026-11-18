// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice Minimal read-only interface of the SPACE ID Agent ID contract (ERC-721, non-transferable).
interface IAgentID {
    function balanceOf(address owner) external view returns (uint256);
}

/// @title Agent ID Badge
/// @notice Free soulbound badge for Binance Agent ID (.ai) holders.
///         One badge per holder, minted free (value 0, minter pays only gas).
///         Built for the Binance Agent ID Hackathon (Nov–Dec 2026).
/// @dev No owner. No admin functions. No fees, no treasury, no pause, no upgrade.
///      The contract cannot receive BNB and holds no funds. It promises no returns.
///      Transfers and approvals always revert (soulbound, in the spirit of Agent ID itself).
contract AgentIDBadge {
    IAgentID public constant AGENT_ID =
        IAgentID(0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F);

    string public constant name = "Agent ID Badge";
    string public constant symbol = "AIDB";

    uint256 public totalSupply;
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(address => bool) public hasMinted;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    error AgentIDRequired();
    error AlreadyMinted();
    error Soulbound();
    error NonexistentToken();

    /// @notice Mint your one free badge. Requires holding a Binance Agent ID.
    function mint() external {
        if (AGENT_ID.balanceOf(msg.sender) == 0) revert AgentIDRequired();
        if (hasMinted[msg.sender]) revert AlreadyMinted();
        hasMinted[msg.sender] = true;
        unchecked {
            totalSupply += 1;
        }
        uint256 tokenId = totalSupply;
        _owners[tokenId] = msg.sender;
        unchecked {
            _balances[msg.sender] += 1;
        }
        emit Transfer(address(0), msg.sender, tokenId);
    }

    function balanceOf(address owner) external view returns (uint256) {
        require(owner != address(0), "zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) external view returns (address) {
        address owner = _owners[tokenId];
        if (owner == address(0)) revert NonexistentToken();
        return owner;
    }

    // ---- Soulbound: every transfer / approval reverts ----

    function transferFrom(address, address, uint256) external pure {
        revert Soulbound();
    }

    function safeTransferFrom(address, address, uint256) external pure {
        revert Soulbound();
    }

    function safeTransferFrom(address, address, uint256, bytes calldata) external pure {
        revert Soulbound();
    }

    function approve(address, uint256) external pure {
        revert Soulbound();
    }

    function setApprovalForAll(address, bool) external pure {
        revert Soulbound();
    }

    function getApproved(uint256) external pure returns (address) {
        return address(0);
    }

    function isApprovedForAll(address, address) external pure returns (bool) {
        return false;
    }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165
            interfaceId == 0x80ac58cd || // ERC721
            interfaceId == 0x5b5e139f; // ERC721Metadata
    }

    /// @notice On-chain metadata: SVG badge embedded as a data URI. No off-chain dependency.
    function tokenURI(uint256 tokenId) external view returns (string memory) {
        if (_owners[tokenId] == address(0)) revert NonexistentToken();
        string memory svg = string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">',
                '<rect width="512" height="512" fill="#0b0b12"/>',
                '<rect x="16" y="16" width="480" height="480" rx="24" fill="none" stroke="#f0b90b" stroke-width="6"/>',
                '<text x="256" y="150" font-family="monospace" font-size="42" fill="#f0b90b" text-anchor="middle">AGENT ID</text>',
                '<text x="256" y="215" font-family="monospace" font-size="42" fill="#ffffff" text-anchor="middle">BADGE</text>',
                '<text x="256" y="300" font-family="monospace" font-size="28" fill="#aaaaaa" text-anchor="middle">Proof of Agent ID Holder</text>',
                '<text x="256" y="360" font-family="monospace" font-size="24" fill="#f0b90b" text-anchor="middle">#',
                _toString(tokenId),
                "</text>",
                '<text x="256" y="420" font-family="monospace" font-size="20" fill="#666666" text-anchor="middle">BNB Chain</text>',
                "</svg>"
            )
        );
        string memory json = string(
            abi.encodePacked(
                '{"name":"Agent ID Badge #',
                _toString(tokenId),
                '","description":"Free soulbound badge for Binance Agent ID (.ai) holders. One per holder, non-transferable, no monetary value.","image":"data:image/svg+xml;base64,',
                _base64(bytes(svg)),
                '","attributes":[{"trait_type":"Type","value":"Agent ID Badge"},{"trait_type":"Soulbound","value":"Yes"}]}'
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", _base64(bytes(json))));
    }

    // ---- helpers ----

    string internal constant _BASE64_TABLE =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    function _base64(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return "";
        bytes memory table = bytes(_BASE64_TABLE);
        uint256 encodedLen = 4 * ((data.length + 2) / 3);
        bytes memory result = new bytes(encodedLen);
        uint256 j = 0;
        for (uint256 i = 0; i < data.length; i += 3) {
            uint256 a = uint256(uint8(data[i]));
            uint256 b = i + 1 < data.length ? uint256(uint8(data[i + 1])) : 0;
            uint256 c = i + 2 < data.length ? uint256(uint8(data[i + 2])) : 0;
            uint256 triple = (a << 16) | (b << 8) | c;
            result[j++] = table[(triple >> 18) & 0x3F];
            result[j++] = table[(triple >> 12) & 0x3F];
            result[j++] = i + 1 < data.length ? table[(triple >> 6) & 0x3F] : bytes1("=");
            result[j++] = i + 2 < data.length ? table[triple & 0x3F] : bytes1("=");
        }
        return string(result);
    }

    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
