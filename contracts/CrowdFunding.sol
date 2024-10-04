// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
import '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';

contract CrowdFunding {
 string public name; 

  uint256 public projectCount = 0; //Keeping count of Project 

  mapping(uint256 => Project) public projects; //mapping Project to projects
  mapping(uint256 => mapping(address => uint256)) public contributions; //Nested Mapping for address

  using EnumerableSet for EnumerableSet.AddressSet;

  mapping(uint256 => EnumerableSet.AddressSet) private contributors; // Enumerableset From OpenZeppellin

  struct Project {
    uint256 id;
    string name;
    string desc;
    address owner;
    uint256 dateLine;
    bool exists;
    uint256 balance;
    uint256 goal;
  }

   event ProjectCreated(
    uint256 id,
    string name,
    string desc,
    address owner,
    uint256 dateLine,
    bool exists,
    uint256 balance,
    uint256 goal
  );

  event CampaignCreated(uint256 id, address owner, address funder, uint256 amount); //Creating ProjectFund Events

  event DonationRecieved(uint256 id, string name, uint256 balance);

  constructor() {
    name = 'Project for crowd funding';
  }
   modifier OnlyOwner(uint256 projectId) {
    require(msg.sender == projects[projectId].owner, 'Na Only Owner fit close Project'); //requirement from Project Owner
    _;
  }
  modifier ProjectExists(uint256 projectId) {
    require(projects[projectId].exists == true, 'Project Never dey (exist)');
    _;
  }

  function createCampaign(
    string memory _name,
    string memory _desc,
    uint256 _endDate,
    uint256 _target
  ) public {
  
    require(bytes(_name).length > 0);
    // Require a valid target
    require(_target > 0); // Target or goals
    // Require a valid endDate
    require(_endDate > 0); //This Increment Project Count
    projectCount++; //This Create the project
    projects[projectCount] = Project(
      projectCount,
      _name,
      _desc,
      msg.sender,
      _endDate,
      true,
      0,
      _target
    );
    emit ProjectCreated(projectCount, _name, _desc, msg.sender, _endDate, true, 0, _target);
  }

  function fundProject(uint256 _id) public payable ProjectExists(_id) {
    // This Fetch the Project
    Project memory _project = projects[_id]; //This Fetch the Project Owner
    address _owner = _project.owner; // Make sure the project has valid ID
    require(_project.id > 0 && _project.id <= projectCount); // Check if the Project end Date is greater than now
    require(block.timestamp < _project.dateLine, 'Project done (is) closed oooo.'); // Check if the owner is trying to fund and reject it
    require(_owner != msg.sender, "Owner can't fund the project created by themselves.");//Sent ether must be greater than 0
    require(msg.value > 0); // Fund it
    _project.balance += msg.value; // Update the Project
    projects[_id] = _project; // contributors can again send the money
    contributions[_id][msg.sender] += msg.value;

    if (contributors[_id].contains(msg.sender) != true) {
      contributors[_id].add(msg.sender);
    } // Trigger the event
    emit CampaignCreated(_project.id, _project.owner, msg.sender, msg.value);
  }

  function closeProject(uint256 _id) public OnlyOwner(_id) ProjectExists(_id) {// Fetch the Project
    Project memory _project = projects[_id];
    _project.exists = false;
    payable(_project.owner).transfer(_project.balance);
    _project.balance = 0;
    projects[_id] = _project;
    emit DonationRecieved(_project.id, _project.name, _project.balance);
  }
  
  function getContibutionsLength(uint256 project_id)
    public
    view
    ProjectExists(project_id)
    returns (uint256 length)
  {
    return contributors[project_id].length();
  }

  function getContributor(uint256 project_id, uint256 position)public view
    ProjectExists(project_id)
    returns (address)
  {
    address _contributorsAddress = contributors[project_id].at(position);
    return _contributorsAddress;
  }
  
   function balanceOfProjects() public view returns (uint256) {
    return address(this).balance;
  }
 
}