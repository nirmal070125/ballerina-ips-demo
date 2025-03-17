import ballerina/test;
import ballerina/http;

@test:Config {}
function testGetExistingHospitalConnection() returns error? {
    http:Client testClient = check new (TEST_URL);
    
    HospitalConnection response = check testClient->/hospitals/["H001"]/connection;
    
    test:assertEquals(response.hospitalId, "H001");
    test:assertEquals(response.url, "https://hospital1.example.com");
}

@test:Config {}
function testGetNonExistingHospitalConnection() returns error? {
    http:Client testClient = check new (TEST_URL);
    
    http:Response response = check testClient->/hospitals/["H999"]/connection;
    
    test:assertEquals(response.statusCode, 404);
    json errorPayload = check response.getJsonPayload();
    ErrorDetails errorDetails = check errorPayload.cloneWithType();
    test:assertEquals(errorDetails.code, "HOSPITAL_NOT_FOUND");
    test:assertEquals(errorDetails.message, "Hospital with ID H999 not found");
}

@test:Config {}
function testGetAllDefinedHospitals() returns error? {
    http:Client testClient = check new (TEST_URL);
    
    // Test H002
    HospitalConnection response1 = check testClient->/hospitals/["H002"]/connection;
    test:assertEquals(response1.hospitalId, "H002");
    test:assertEquals(response1.url, "https://hospital2.example.com");
    
    // Test H003
    HospitalConnection response2 = check testClient->/hospitals/["H003"]/connection;
    test:assertEquals(response2.hospitalId, "H003");
    test:assertEquals(response2.url, "https://hospital3.example.com");
}