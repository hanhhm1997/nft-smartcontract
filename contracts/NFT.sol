//SPDX-License-Identifier: UNLICENSED
pragma solidity <=0.8.10;

import "openzeppelin-solidity/contracts/utils/Context.sol";
import "openzeppelin-solidity/contracts/utils/Counters.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin-solidity/contracts/access/AccessControlEnumerable.sol";

interface INFT {
    function mint(string calldata cid) external returns (uint256);
}

contract NFT is ERC721Enumerable, Ownable, AccessControlEnumerable, INFT {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdTracker;
    string private _url;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    mapping(uint256 => string) private _cid;
    uint256 private _maxMintSupply;

    event Mint(uint256 tokenid);

    constructor() ERC721("Kiln Nft", "KLAY") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _maxMintSupply = 15;
    }

    function baseURI() external view returns (string memory _newBaseURI) {
        return _url;
    }

    function mint(string calldata cid) external override returns (uint256) {
        uint balance = balanceOf(msg.sender);
        require(_maxMintSupply > balance, "You have used up all your mints");
        require(msg.sender != address(0), "Address is zero");
        _tokenIdTracker.increment();
        uint256 token_id = _tokenIdTracker.current();
        _cid[token_id] = string(abi.encodePacked(_url, cid));
        _mint(msg.sender, token_id);
        emit Mint(token_id);
        return token_id;
    }

    function listTokenIds(
        address owner
    ) external view returns (uint256[] memory tokenIds) {
        uint balance = balanceOf(owner);
        uint256[] memory ids = new uint256[](balance);

        for (uint i = 0; i < balance; i++) {
            ids[i] = tokenOfOwnerByIndex(owner, i);
        }
        return (ids);
    }

    function setBaseUrl(string memory _newUrl) public onlyOwner {
        _url = _newUrl;
    }

    function setMaxMintSupply(uint256 _newMaxMintSupply) public onlyOwner {
        _maxMintSupply = _newMaxMintSupply;
    }

    function getMaxMintSupply() external view returns (uint256) {
        return _maxMintSupply;
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC721Enumerable, AccessControlEnumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721: URI query for nonexistent token");
        return _cid[tokenId];
    }
}
