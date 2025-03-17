import ballerina/http;
import ballerina/test;

@test:Config {}
function testGetExistingPatientMappings() returns error? {
    http:Client testClient = check new ("http://localhost:9090");
    HospitalPatientMapping[] response = check testClient->/mpi/["UP001"]/mappings;

    test:assertEquals(response.length(), 2);
    test:assertEquals(response[0].hospitalPatientId, "H1P123");
    test:assertEquals(response[0].hospitalId, "H001");
    test:assertEquals(response[1].hospitalPatientId, "H2P456");
    test:assertEquals(response[1].hospitalId, "H002");
}

@test:Config {}
function testGetNonExistingPatientMappings() returns error? {
    http:Client testClient = check new ("http://localhost:9090");
    http:Response response = check testClient->/mpi/["UP999"]/mappings;
    test:assertEquals(response.statusCode, 404);
}

@test:Config {}
function testAllInitializedMappings() returns error? {
    http:Client testClient = check new ("http://localhost:9090");

    // Test first patient
    HospitalPatientMapping[] response1 = check testClient->/mpi/["UP001"]/mappings;
    test:assertEquals(response1.length(), 2);

    // Test second patient
    HospitalPatientMapping[] response2 = check testClient->/mpi/["UP002"]/mappings;
    test:assertEquals(response2.length(), 2);
    test:assertEquals(response2[0].hospitalPatientId, "H1P789");
    test:assertEquals(response2[1].hospitalId, "H003");
}
