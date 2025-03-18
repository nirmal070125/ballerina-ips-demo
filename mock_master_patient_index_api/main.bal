import ballerina/http;
import ballerina/log;

// In-memory storage for patient mappings using unique patient ID as the key
final readonly & map<readonly & HospitalPatientMapping[]> patientMappingStore = {
    "UP001": [
        {hospitalPatientId: "444222222", hospitalId: "H001"}
    ],
    "UP002": [
        {hospitalPatientId: "H1P789", hospitalId: "H001"},
        {hospitalPatientId: "H3P012", hospitalId: "H003"}
    ]
};

service / on new http:Listener(9090) {
    isolated resource function get mpi/[string uniquePatientId]/mappings() returns HospitalPatientMapping[]|http:NotFound {
        log:printInfo("Received request for patient ID: " + uniquePatientId);
        readonly & HospitalPatientMapping[]? mappings = patientMappingStore[uniquePatientId];
        if mappings is () {
            return {
                body: {
                    message: string `Patient ID ${uniquePatientId} not found`
                }
            };
        }
        return mappings.clone();
    }
}
