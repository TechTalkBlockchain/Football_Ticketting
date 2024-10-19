// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SongNFT is ERC721URIStorage, Ownable {
    uint256 private _tokenIds;

    struct SongMetadata {
        string title;
        string artist;
        string album;
        string genre;
        string licenseType; // e.g., "exclusive", "non-exclusive", "streaming rights"
    }

    mapping(uint256 => SongMetadata) private _songDetails;

    constructor() ERC721("SongNFT", "SNFT") {}

    // Mint a new Song NFT
    function mintSongNFT(
        address recipient,
        string memory metadataURI,
        string memory title,
        string memory artist,
        string memory album,
        string memory genre,
        string memory licenseType
    ) public onlyOwner returns (uint256) {
        _tokenIds++;

        // Mint the NFT
        uint256 newSongId = _tokenIds;
        _mint(recipient, newSongId);
        _setTokenURI(newSongId, metadataURI);

        // Store the song details
        _songDetails[newSongId] = SongMetadata({
            title: title,
            artist: artist,
            album: album,
            genre: genre,
            licenseType: licenseType
        });

        return newSongId;
    }

    // Get details of a specific Song NFT
    function getSongDetails(uint256 tokenId)
        public
        view
        returns (
            string memory title,
            string memory artist,
            string memory album,
            string memory genre,
            string memory licenseType
        )
    {
        require(_exists(tokenId), "SongNFT: Query for nonexistent token");

        SongMetadata memory song = _songDetails[tokenId];
        return (song.title, song.artist, song.album, song.genre, song.licenseType);
    }
}
