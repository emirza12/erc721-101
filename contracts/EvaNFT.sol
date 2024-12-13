// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract EvaNFT is ERC721 {

    address public constant evaluatorAddress = 0x7759a66191f6e80ff8A2C0ab833886C7b632bbB7;
    uint256 public constant legs = 3;
    uint256 public constant sex = 0;
    string public constant tokenName = "foEWhRvyKGPe2rc";
    bool public constant wings = false;
    uint256 private _registrationPrice = 0.0 ether;
    uint256 private nextAnimalId = 0;


    modifier onlyBreeder() {
        require(Breeder[msg.sender], "Caller is not the breeder");
        _;
    }

    struct Animal {
        string name;
        bool wings;
        uint legs;
        uint sex;
        uint parent1;
        uint parent2;
    }
      
    mapping(address => bool) private Breeder;
    mapping(uint256 => Animal) private animals;
    mapping(address => uint256[]) private ownerTokens;
    mapping(uint256 => uint256) attribute_price;
    mapping(uint256 => bool) private reproduce;
    mapping(uint256 => uint256) private reproducePrice;
    mapping(uint256=>address) private reproduceBreeder;

    constructor() ERC721("EvaNFT", "EVN") {}

    function getAnimalCharacteristics(uint animalNumber) external view returns (string memory _name, bool _wings, uint _legs, uint _sex) {
        Animal storage animal = animals[animalNumber];
        return (animal.name, animal.wings, animal.legs, animal.sex);
    }

    function isBreeder(address account) external view returns (bool) {
        return Breeder[account];
    }

    function registrationPrice() external view returns (uint256) {
        return _registrationPrice;
    }

    function registerMeAsBreeder() external payable {
        require(msg.value == _registrationPrice, "Invalid registration price");
        Breeder[msg.sender] = true;
    }

    function declareAnimal(uint256 sex, uint256 legs, bool wings, string calldata name) external onlyBreeder returns (uint256) {
        uint256 animalNumber = nextAnimalId;
        animals[animalNumber] = Animal(name, wings, legs, sex,0,0);
        _mint(msg.sender, animalNumber);
        nextAnimalId += 1;  

        ownerTokens[msg.sender].push(animalNumber);

        return animalNumber;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256) {
        return ownerTokens[owner][index];
    }

    function declareDeadAnimal(uint animalNumber) external  {
        require(ownerOf(animalNumber) == msg.sender, "You are not the owner of this animal");
        delete animals[animalNumber];
        _burn(animalNumber);
    
    uint256[] storage tokens = ownerTokens[msg.sender];
    for (uint256 i = 0; i < tokens.length; i++) {
        if (tokens[i] == animalNumber) {
            tokens[i] = tokens[tokens.length - 1];
            tokens.pop();
            break; 
        }   
    }
    }  

     function isAnimalForSale(uint animalNumber) external view returns (bool){
        if (attribute_price[animalNumber] != 0)
        {
            return true;
        } else{
            return false;
        }
    }

	function animalPrice(uint animalNumber) external view returns (uint256){
        return attribute_price[animalNumber];
    }

    function buyAnimal(uint animalNumber) external payable{
        address currentOwner = ownerOf(animalNumber);
        require(currentOwner != msg.sender, "You already own this animal");

        payable(currentOwner).transfer(attribute_price[animalNumber]);
        _transfer(currentOwner, msg.sender, animalNumber);

        attribute_price[animalNumber] = 0;
    }


	function offerForSale(uint animalNumber, uint price) external{
        attribute_price[animalNumber] = price;
    }

    function declareAnimalWithParents(uint sex, uint legs, bool wings, string calldata name, uint parent1, uint parent2) external returns (uint256){
        if (reproduceBreeder[parent2] == msg.sender) {
        reproduce[parent1] = true;
        reproduce[parent2] = true;
        }
        
        require(reproduce[parent1], "Parent1 cannot reproduce");
        require(reproduce[parent2], "Parent2 cannot reproduce");

        uint256 animalNumber = nextAnimalId;
        animals[animalNumber] = Animal(name, wings, legs, sex, parent1, parent2);
        _mint(msg.sender, animalNumber);
        nextAnimalId += 1;
        ownerTokens[msg.sender].push(animalNumber);

        reproduceBreeder[parent2] = ownerOf(parent2);

        return animalNumber;
    }

    function getParents(uint animalNumber) external returns (uint256, uint256){
        return (animals[animalNumber].parent1, animals[animalNumber].parent2);
    }

    function canReproduce(uint animalNumber) external returns (bool){
        return reproduce[animalNumber];
    }

	function reproductionPrice(uint animalNumber) external view returns (uint256){
        return reproducePrice[animalNumber];
    }

	function offerForReproduction(uint animalNumber, uint priceOfReproduction) external returns (uint256){
        require(ownerOf(animalNumber) == msg.sender, "You are not the owner of this animal");
        reproduce[animalNumber] = true;
        reproducePrice[animalNumber] = priceOfReproduction;
        return animalNumber;
    }

    function authorizedBreederToReproduce(uint animalNumber) external returns (address){
        return reproduceBreeder[animalNumber];
    }

	function payForReproduction(uint animalNumber) external payable{
        address currentOwner = ownerOf(animalNumber);

        payable(currentOwner).transfer(reproducePrice[animalNumber]);

        reproduce[animalNumber] = false;
        reproducePrice[animalNumber] = 0;
        reproduceBreeder[animalNumber] = msg.sender;
    }



}
