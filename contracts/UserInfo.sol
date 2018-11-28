pragma solidity ^0.4.24;
import "oraclize-api/usingOraclize.sol";
import { Coverage } from "./Coverage.sol";

contract UserInfo is usingOraclize {
    struct User {
        mapping(uint => Coverage.Insurance) insurances;
        uint insuranceSize;
        // LIMITATION: Copying of type struct Coverage.Insurance memory[] memory to storage not yet supported
        // Coverage.Insurance[] insurances;
        uint256 points;
        bool set;
    }

    constructor() public payable {
        OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
    }

    function __callback(bytes32, string result) public {
        if (msg.sender != oraclize_cbAddress())
            revert("Wrong sender");
        // buy the insurance
    }

    mapping(address => User) private users;

    function getPoints() public view returns (uint256) {
        User storage user = users[msg.sender];
        require(user.set, "User is not set");

        return user.points;
    }

    function userExists() public view returns (bool) {
        User storage user = users[msg.sender];
        return user.set;
    }

    function createUser() public {
        User storage user = users[msg.sender];
        // Check that the user did not already exist:
        require(!user.set, "User is already set");
        // Store the user
        users[msg.sender] = User({
            insuranceSize: 0,
            points: 0,
            set: true
        });
    }

    function removePoints(uint256 points) public {
        // TODO: restrict this to contract-contract only
        require(points > 0, "Given points is non-positive");
        User storage user = users[msg.sender];
        require(user.set, "User is not set");

        user.points -= points;
    }

    function addPoints(uint256 points) public {
        // TODO: restrict this to contract-contract only
        require(points > 0, "Given points is non-positive");
        User storage user = users[msg.sender];
        require(user.set, "User is not set");

        user.points += points;
    }

    // buy an insurance
    function buyInsurance(bytes8 bookingNumber, uint departureDate,
        uint arrivalDate, bool buyWithLoyalty) public payable {
        require(departureDate > block.timestamp, "You cannot buy insurance for past flights!");
    }

    function buyInsurance(bytes8 bookingNumber, uint departureDate,
        uint arrivalDate, uint returnDepartureDate, bool buyWithLoyalty) public payable {
        // buy return trip ticket
        // LIMITATION: we cannot verify actual booking numbers because we don't have the data.
        // instead, we call a mock endpoint to determine whether the data is valid.
        require(departureDate > block.timestamp, "You cannot buy insurance for past flights!");
        // call oraclize to get whether flight details is correct
    }
}

contract flightValidity is usingOraclize {

    function __callback(bytes32, string result) public {
        if (msg.sender != oraclize_cbAddress())
            revert("Wrong sender");
        // with the result, buy the insurance. Get the price
    }

    function checkFlightDetails(string bookingNumber) {
        if (oraclize_getPrice("json") > address(this).balance) {
            emit LogNewOraclizeQuery("Oraclize query not sent, not enough ETH");
        } else {
            // TODO: call mock endpoint
            // oraclize_query("json", )
        }
    }

    // this method is unused as we are using mock flight data.
    function checkRealFlightDetails(
        string apikey, string airlineCode, string flightNumber,
        string originAirportCode, string scheduledDepartureDate,
        string destinationAirportCode, string scheduledArrivalDate) public payable {
        // endpoint is limited to 100 calls a day.
        if (oraclize_getPrice("computation") > address(this).balance) {
            emit LogNewOraclizeQuery("Oraclize query not sent, not enough ETH");
        } else {
            emit LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            oraclize_query(
                "computation",
                [
                    "QmdKK319Veha83h6AYgQqhx9YRsJ9MJE7y33oCXyZ4MqHE",
                    "POST",
                    "https://apigw.singaporeair.com/api/v3/flightstatus/getbynumber",
                    string(
                        abi.encodePacked(
                            "{'headers': { 'content-type': 'application/json',",
                            "'apikey':'", apikey,
                            "'},",
                            "'json':",
                            "{'request': {",
                            "'airlineCode':'", airlineCode,
                            "',",
                            "'flightNumber':'", flightNumber,
                            "',",
                            "'originAirportCode':'", originAirportCode,
                            "',",
                            "'scheduledDepartureDate':'", scheduledDepartureDate,
                            "',",
                            "'destinationAirportCode':'", destinationAirportCode,
                            "',",
                            "'scheduledArrivalDate':'", scheduledArrivalDate,
                            "'},",
                            "'clientUUID': 'TestIODocs'}}"
                        )
                    )
                ]
            );
        }
    }
}