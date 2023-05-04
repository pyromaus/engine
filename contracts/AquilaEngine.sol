//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;

import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.6/vendor/Ownable.sol";

contract AquilaEngine is ChainlinkClient, Ownable {
    // Storage - Structs

    struct Customer {
        uint256 custID;
    }

    struct MeasureLocation {
        uint256 locationID;
        bytes32 latLong;
    }

    struct WindFarm {
        uint256 custID;
        uint256 farmID;
        uint256 locationID;
        uint256 farmAvgMWh;
    }

    struct Turbine {
        uint256 custID;
        uint256 farmID;
        uint256 turbineID;
        uint256 locationID;
        uint256 turbineAvgMWh;
    }

    struct MeasuredWind {
        uint256 locationID;
        uint256 timestampID;
        uint256 windMeasured;
    }

    struct TurbineOutputReport {
        uint256 custID;
        uint256 farmID;
        uint256 turbineID;
        uint256 timestampID;
        uint256 output;
    }

    struct TurbineOutputResult {
        uint256 custID;
        uint256 farmID;
        uint256 turbineID;
        uint256 timestampID;
        uint256 PARM_W;
        uint256 PARM_O;
        uint256 PARM_STATUS;
    }

    // Storage - Mappings & Sequences

    mapping(uint256 => Customer) public customers;
    mapping(uint256 => MeasureLocation) public measureLocations;
    mapping(uint256 => mapping(uint256 => WindFarm)) public windFarms;
    mapping(uint256 => mapping(uint256 => mapping(uint256 => Turbine)))
        public turbines;
    mapping(uint256 => mapping(uint256 => MeasuredWind))
        public historicalWindAvgs;
    mapping(uint256 => mapping(uint256 => MeasuredWind)) public measuredWind;
    mapping(uint256 => mapping(uint256 => mapping(uint256 => TurbineOutputReport)))
        public outputReports;
    mapping(uint256 => mapping(uint256 => mapping(uint256 => TurbineOutputResult)))
        public outputResults;

    uint256 public SEQ_CustID = 0;
    uint256 public SEQ_LocationID = 0;
    uint256 public SEQ_FarmID = 0;
    uint256 public SEQ_TurbineID = 0;

    uint256[] public customersIndex;
    uint256[] public measureLocationsIndex;
    mapping(uint256 => uint256[]) public windFarmsIndex;
    mapping(uint256 => mapping(uint256 => uint256[])) public turbinesIndex;

    // Storage - Customer

    function addCustomerI() public returns (uint256) {
        customers[SEQ_CustID] = Customer(SEQ_CustID);
        SEQ_CustID++;
        customersIndex.push(SEQ_CustID);
        return SEQ_CustID;
    }

    function addCustomerE(uint256 _custID) public {
        customers[_custID] = Customer(_custID);
        customersIndex.push(_custID);
    }

    function removeCustomer(uint256 _custID) public {
        delete customers[_custID];
    }

    function getAllCustomers() public view returns (Customer[] memory) {
        Customer[] memory items = new Customer[](customersIndex.length);
        for (uint256 i = 0; i < customersIndex.length; i++) {
            items[i] = customers[customersIndex[i]];
        }
        return items;
    }

    // Storage - MeasureLocation

    function addMeasureLocationI(bytes32 _latLong) public returns (uint256) {
        measureLocations[SEQ_LocationID] = MeasureLocation(
            SEQ_LocationID,
            _latLong
        );
        SEQ_LocationID++;
        measureLocationsIndex.push(SEQ_LocationID);
        return SEQ_LocationID;
    }

    function addMeasureLocationE(uint256 _locationID, bytes32 _latLong) public {
        measureLocations[_locationID] = MeasureLocation(_locationID, _latLong);
        measureLocationsIndex.push(_locationID);
    }

    function removeMeasureLocation(uint256 _locationID) public {
        delete measureLocations[_locationID];
    }

    function getAllMeasureLocations()
        public
        view
        returns (MeasureLocation[] memory)
    {
        MeasureLocation[] memory items = new MeasureLocation[](
            measureLocationsIndex.length
        );
        for (uint256 i = 0; i < measureLocationsIndex.length; i++) {
            items[i] = measureLocations[measureLocationsIndex[i]];
        }
        return items;
    }

    // Storage - WindFarm

    function addWindFarmI(
        uint256 _custID,
        //uint256,
        uint256 _locationID,
        uint256 _farmAvgMWh
    ) public returns (uint256) {
        windFarms[_custID][SEQ_FarmID] = WindFarm(
            _custID,
            SEQ_FarmID,
            _locationID,
            _farmAvgMWh
        );
        SEQ_FarmID++;
        windFarmsIndex[_custID].push(SEQ_FarmID);
        return SEQ_FarmID;
    }

    function addWindFarmE(
        uint256 _custID,
        uint256 _farmID,
        uint256 _locationID,
        uint256 _farmAvgMWh
    ) public {
        windFarms[_custID][_farmID] = WindFarm(
            _custID,
            _farmID,
            _locationID,
            _farmAvgMWh
        );
        windFarmsIndex[_custID].push(_farmID);
    }

    function removeWindFarm(uint256 _custID, uint256 _farmID) public {
        delete windFarms[_custID][_farmID];
    }

    function getAllCustomerWindfarms(
        uint256 _custID
    ) public view returns (WindFarm[] memory) {
        WindFarm[] memory items = new WindFarm[](
            windFarmsIndex[_custID].length
        );
        for (uint256 i = 0; i < windFarmsIndex[_custID].length; i++) {
            items[i] = windFarms[_custID][windFarmsIndex[_custID][i]];
        }
        return items;
    }

    // Storage - Turbines

    function addTurbineI(
        uint256 _custID,
        uint256 _farmID,
        uint256,
        uint256 _locationID,
        uint256 _turbineAvgMWh
    ) public returns (uint256) {
        turbines[_custID][_farmID][SEQ_TurbineID] = Turbine(
            _custID,
            _farmID,
            SEQ_TurbineID,
            _locationID,
            _turbineAvgMWh
        );
        SEQ_TurbineID++;
        turbinesIndex[_custID][_farmID].push(SEQ_TurbineID);
        return SEQ_TurbineID;
    }

    function addTurbineE(
        uint256 _custID,
        uint256 _farmID,
        uint256 _turbineID,
        uint256 _locationID,
        uint256 _turbineAvgMWh
    ) public {
        turbines[_custID][_farmID][_turbineID] = Turbine(
            _custID,
            _farmID,
            _turbineID,
            _locationID,
            _turbineAvgMWh
        );
        turbinesIndex[_custID][_farmID].push(_turbineID);
    }

    function removeTurbine(
        uint256 _custID,
        uint256 _farmID,
        uint256 _turbineID
    ) public {
        delete turbines[_custID][_farmID][_turbineID];
    }

    function getAllFarmTurbines(
        uint256 _custID,
        uint256 _farmID
    ) public view returns (Turbine[] memory) {
        Turbine[] memory items = new Turbine[](
            turbinesIndex[_custID][_farmID].length
        );
        for (uint256 i = 0; i < turbinesIndex[_custID][_farmID].length; i++) {
            items[i] = turbines[_custID][_farmID][
                turbinesIndex[_custID][_farmID][i]
            ];
        }
        return items;
    }

    // Storage - Historical Wind Averages

    function addHistoricalWindAvg(
        uint256 _locationID,
        uint256 _timestampID,
        uint256 _windAvg
    ) public {
        historicalWindAvgs[_locationID][_timestampID] = MeasuredWind(
            _locationID,
            _timestampID,
            _windAvg
        );
    }

    function addMeasuredWind(
        uint256 _locationID,
        uint256 _timestampID,
        uint256 _windAvg
    ) public {
        measuredWind[_locationID][_timestampID] = MeasuredWind(
            _locationID,
            _timestampID,
            _windAvg
        );
    }

    function removeHistoricalWindAvg(
        uint256 _locationID,
        uint256 _timestampID
    ) public {
        delete historicalWindAvgs[_locationID][_timestampID];
    }

    function removeMeasuredWind(
        uint256 _locationID,
        uint256 _timestampID
    ) public {
        delete measuredWind[_locationID][_timestampID];
    }

    // Storage - Turbine Output Report

    function addOutputReport(
        uint256 _custID,
        uint256 _farmID,
        uint256 _turbineID,
        uint256 _timestampID,
        uint256 _output
    ) public {
        outputReports[_custID][_farmID][_turbineID] = TurbineOutputReport(
            _custID,
            _farmID,
            _turbineID,
            _timestampID,
            _output
        );
    }

    function removeOutputReport(
        uint256 _custID,
        uint256 _farmID,
        uint256 _turbineID
    ) public {
        delete outputReports[_custID][_farmID][_turbineID];
    }

    // Storage - Turbine Output Result

    function addOutputResult(
        uint256 _custID,
        uint256 _farmID,
        uint256 _turbineID,
        uint256 _timestampID,
        uint256 PARM_W,
        uint256 PARM_O,
        uint256 PARM_STATUS
    ) public {
        outputResults[_custID][_farmID][_turbineID] = TurbineOutputResult(
            _custID,
            _farmID,
            _turbineID,
            _timestampID,
            PARM_W,
            PARM_O,
            PARM_STATUS
        );
    }

    function removeOutputResult(
        uint256 _custID,
        uint256 _farmID,
        uint256 _turbineID
    ) public {
        delete outputResults[_custID][_farmID][_turbineID];
    }

    // LOGIC

    function getOutputResult(
        uint256 farmID,
        uint256 turbineID,
        uint256 timestampID
    ) public view returns (TurbineOutputResult memory) {
        return outputResults[farmID][turbineID][timestampID];
    }

    function calculateOutputResult(
        uint256 _custID,
        uint256 _farmID,
        uint256 _turbineID,
        uint256 _timestampID
    ) public returns (TurbineOutputResult memory) {
        uint256 parm_o;
        uint256 parm_w;
        uint256 parm_status;

        uint256 output = outputReports[_farmID][_turbineID][_timestampID]
            .output;
        uint256 locationID = windFarms[_custID][_farmID].locationID;
        uint256 avgOutput = turbines[_custID][_farmID][_turbineID]
            .turbineAvgMWh;

        uint256 avgWind = historicalWindAvgs[locationID][_timestampID]
            .windMeasured;
        uint256 wind = measuredWind[locationID][_timestampID].windMeasured;

        parm_w = output > avgOutput ? 1 : 0;
        parm_o = wind > avgWind ? 1 : 0;
        parm_status = parm_o == parm_w ? 1 : 0;

        outputResults[_farmID][_turbineID][_timestampID] = TurbineOutputResult(
            _custID,
            _farmID,
            _turbineID,
            _timestampID,
            parm_w,
            parm_o,
            parm_status
        );

        return outputResults[_farmID][_turbineID][_timestampID];
    }

    //NETWORK

    uint256 private constant ORACLE_PAYMENT = 1 * 10 ** 9;
    uint256 public CONTRACT_NETWORK = 4;
    address public oracle_address = address(0x0);
    string public oracle_jobid = "0000000001";
    string public dataObjectString;
    bytes32 public dataObjectBytes32;

    function setJob(string memory _jobId) public onlyOwner {
        oracle_jobid = _jobId;
    }

    function setOracle(address _oracle) public onlyOwner {
        oracle_address = _oracle;
    }

    //MAIN

    constructor() public Ownable() {
        setPublicChainlinkToken();
    }

    //ACCOUNTING

    function getBalance() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }

    function withdrawAll() public onlyOwner {
        address payable to = payable(msg.sender);
        to.transfer(getBalance());
    }

    function withdrawAmount(uint256 amount) public onlyOwner {
        address payable to = payable(msg.sender);
        to.transfer(amount);
    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }

    function addToBalance() public payable {}

    //CL Requests

    function requestDataString(
        string memory _spec,
        string memory _id1,
        string memory _id2,
        string memory _id3,
        string memory _id4,
        string memory _id5,
        string memory _id6
    ) public onlyOwner {
        Chainlink.Request memory req = buildChainlinkRequest(
            stringToBytes32(oracle_jobid),
            address(this),
            this.fulfillDataRequestString.selector
        );

        req.add("spec", _spec);
        req.add("id1", _id1);
        req.add("id2", _id2);
        req.add("id3", _id3);
        req.add("id4", _id4);
        req.add("id5", _id5);
        req.add("id6", _id6);

        sendChainlinkRequestTo(oracle_address, req, ORACLE_PAYMENT);
    }

    function requestDataBytes32(
        string memory _spec,
        string memory _id1,
        string memory _id2,
        string memory _id3,
        string memory _id4,
        string memory _id5,
        string memory _id6
    ) public onlyOwner {
        Chainlink.Request memory req = buildChainlinkRequest(
            stringToBytes32(oracle_jobid),
            address(this),
            this.fulfillDataRequestBytes32.selector
        );

        req.add("spec", _spec);
        req.add("id1", _id1);
        req.add("id2", _id2);
        req.add("id3", _id3);
        req.add("id4", _id4);
        req.add("id5", _id5);
        req.add("id6", _id6);

        sendChainlinkRequestTo(oracle_address, req, ORACLE_PAYMENT);
    }

    //CL Settlements

    function fulfillDataRequestString(
        bytes32 _requestId,
        bytes32 _data
    ) public recordChainlinkFulfillment(_requestId) {
        dataObjectString = bytes32ToStr(_data);
    }

    function fulfillDataRequestBytes32(
        bytes32 _requestId,
        bytes32 _data
    ) public recordChainlinkFulfillment(_requestId) {
        dataObjectBytes32 = _data;

        // (uint256 _s1, uint256 _s2, uint256 _s3, uint256 _s4) = splitBytes32(dataObjectBytes32);
        // Do stuff with the 4 separate (uint256)bytes8
    }

    //UTILS

    function getChainlinkToken() public view returns (address) {
        return chainlinkTokenAddress();
    }

    function bytes32ToStr(
        bytes32 _bytes32
    ) private pure returns (string memory) {
        bytes memory bytesArray = new bytes(32);
        for (uint256 i; i < 32; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

    function stringToBytes32(
        string memory source
    ) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            // solhint-disable-line no-inline-assembly
            result := mload(add(source, 32))
        }
    }

    function splitBytes32(
        bytes32 r
    ) private pure returns (uint256 s1, uint256 s2, uint256 s3, uint256 s4) {
        uint256 rr = uint256(r);
        s1 = uint256(uint64(rr >> (64 * 3)));
        s2 = uint256(uint64(rr >> (64 * 2)));
        s3 = uint256(uint64(rr >> (64 * 1)));
        s4 = uint256(uint64(rr >> (64 * 0)));
    }
}
