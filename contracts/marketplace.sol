import "openzeppelin-solidity/contracts/token/ERC721/IERC721.sol";
import "openzeppelin-solidity/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-solidity/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract Marketplace is ERC721Enumerable {
    address _nftAddress;
    struct NftAuction {
        uint256 _highestBid;
        uint256 _time;
        address _auctioneer;
        address _highestBidder;
        bool completed;
    }
    mapping(uint256 => NftAuction) private _nftAuction;
    receive() external payable {}
    fallback() external payable {}
    constructor(address nftAddress) ERC721("Kiln Marketplace", "KLAY") {
        _nftAddress = nftAddress;
    }
    event BidPlaced(uint256 tokenId, address bidder, uint256 amount);
    event AuctionFinished(uint256 tokenId, address winner, uint256 amount);

    function createAuction(
        uint256 tokenId,
        uint256 price,
        uint256 time
    ) external {
        IERC721 nft = IERC721(_nftAddress);
        require(msg.sender == nft.ownerOf(tokenId), "khong phai chu so huu");
        require(
            nft.isApprovedForAll(msg.sender, address(this)),
            "chua approve"
        );
        _nftAuction[tokenId]._highestBid = price;
        _nftAuction[tokenId]._time = block.timestamp + time * 60;
        _nftAuction[tokenId]._auctioneer = msg.sender;
        _nftAuction[tokenId].completed = false;
        _nftAuction[tokenId]._highestBidder = address(0);
        nft.transferFrom(msg.sender, address(this), tokenId);
    }
    function listAuction() public view returns (uint256[] memory tokenIds) {
        IERC721 nft = IERC721(_nftAddress);
        IERC721Enumerable nftEnumerable = IERC721Enumerable(_nftAddress);

        uint balance = nft.balanceOf(address(this));
        uint256[] memory ids = new uint256[](balance);
        for (uint256 index = 0; index < balance; index++) {
            ids[index] = nftEnumerable.tokenOfOwnerByIndex(
                address(this),
                index
            );
        }
        return ids;
    }

    function bid(uint256 tokenId) external payable {
        require(
            block.timestamp < _nftAuction[tokenId]._time,
            "het thoi gian dau gia"
        );
        require(
            _nftAuction[tokenId].completed == false,
            "dau gia da hoan thanh"
        );
        require(msg.sender.balance > msg.value, "ban khong du tien de dau gia");
        require(
            msg.value > _nftAuction[tokenId]._highestBid,
            "gia nho hon gia hien tai"
        );
        require(
            msg.sender != _nftAuction[tokenId]._auctioneer,
            "Can not bid on your own auction"
        );
        if (_nftAuction[tokenId]._highestBid > 0) {
            require(
                address(this).balance >= _nftAuction[tokenId]._highestBid,
                "So du hop dong khong du de chuyen tien"
            );

            payable(_nftAuction[tokenId]._highestBidder).transfer(
                _nftAuction[tokenId]._highestBid
            ); // Hoàn lại KLAY
        }
        _nftAuction[tokenId]._highestBid = msg.value;
        _nftAuction[tokenId]._highestBidder = msg.sender;
        emit BidPlaced(tokenId, msg.sender, msg.value);
    }

    function finishAuction(uint256 tokenId) public {
        IERC721 nft = IERC721(_nftAddress);

        require(
            msg.sender == _nftAuction[tokenId]._auctioneer,
            "chi co nguoi ban moi co quyen ket thuc dau gia"
        );
        require(
            block.timestamp > _nftAuction[tokenId]._time,
            "chua den het thoi gian dau gia"
        );
        require(
            _nftAuction[tokenId].completed == false,
            "phien dau gia da ket thuc"
        );
        require(
            _nftAuction[tokenId]._highestBidder != address(0),
            "nguoi nhan nft phai la dia chi hop le"
        );
        require(_nftAuction[tokenId]._highestBid > 0, "gia nft phai > 0");
        require(
            address(this).balance > _nftAuction[tokenId]._highestBid,
            "So du hop dong khong du de chuyen tien"
        );

        _nftAuction[tokenId].completed = true;
        payable(_nftAuction[tokenId]._auctioneer).transfer(
            _nftAuction[tokenId]._highestBid
        );
        nft.safeTransferFrom(
            address(this),
            _nftAuction[tokenId]._highestBidder,
            tokenId
        );
        emit AuctionFinished(
            tokenId,
            _nftAuction[tokenId]._highestBidder,
            _nftAuction[tokenId]._highestBid
        );
    }

    function cancelAuction(uint256 tokenId) external {
        IERC721 nft = IERC721(_nftAddress);
        require(_nftAuction[tokenId].completed == false, "dau gia da ket thuc");
        require(
            msg.sender == _nftAuction[tokenId]._auctioneer,
            "chi co nguoi ban moi co quyen ket thuc dau gia"
        );
        require(
            nft.ownerOf(tokenId) == address(this),
            "hop dong khong co trong contract"
        );
        nft.safeTransferFrom(
            address(this),
            _nftAuction[tokenId]._auctioneer,
            tokenId
        );
        if (
            _nftAuction[tokenId]._highestBid > 0 &&
            _nftAuction[tokenId]._highestBidder != address(0)
        ) {
            require(
                address(this).balance > _nftAuction[tokenId]._highestBid,
                "So du hop dong khong du de chuyen tien"
            );
            payable(_nftAuction[tokenId]._highestBidder).transfer(
                _nftAuction[tokenId]._highestBid
            );
        }
        _nftAuction[tokenId].completed = true;
    }

    function getInfoAuction(
        uint256 tokenId
    ) external view returns (NftAuction memory nft) {
        return _nftAuction[tokenId];
    }
    function getInfoAuctionTime(
        uint256 tokenId
    ) external view returns (uint256) {
        return _nftAuction[tokenId]._time;
    }
    function getInfoAuctionAuctioneer(
        uint256 tokenId
    ) external view returns (address) {
        return _nftAuction[tokenId]._auctioneer;
    }

    function getInfoAuctionHighestBid(
        uint256 tokenId
    ) external view returns (uint256) {
        return _nftAuction[tokenId]._highestBid;
    }
}
