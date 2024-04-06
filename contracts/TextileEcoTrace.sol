// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract TextileEcoTrace is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct ProductInfo {
        string sku;
        string name;
        string composition;
        string certificates;
        string manufacturingDate;
    }

    // Mapeamento de tokenID para ProductInfo
    mapping(uint256 => ProductInfo) public productInfo;

    constructor() ERC721("TextileEcoTraceNFT", "TET") {}

    function createProduct(
        address recipient,
        string memory sku,
        string memory name,
        string memory composition,
        string memory certificates,
        string memory manufacturingDate,
        string memory tokenURI
    ) public returns (uint256) {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);

        // Armazenar as informações do produto
        productInfo[newItemId] = ProductInfo(sku, name, composition, certificates, manufacturingDate);

        return newItemId;
    }

    // Função para obter os detalhes de um produto por ID do token
    function getProductInfo(uint256 tokenId) public view returns (ProductInfo memory) {
        require(_exists(tokenId), "ProductManagement: Query for nonexistent token");
        return productInfo[tokenId];
    }
}