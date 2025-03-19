import ballerina/http;
import ballerina/log;

// In-memory storage for patient mappings using unique patient ID as the key
final readonly & map<readonly & HospitalPatientMapping[]> patientMappingStore = {
    "UP001": [
        {hospitalPatientId: "444222222", hospitalId: "H001"}
    ],
    "UP002": [
        {hospitalPatientId: "102938475", hospitalId: "H002"}
    ]
};

service / on new http:Listener(9090) {
    isolated resource function get mpi/[string uniquePatientId]/mappings() returns HospitalPatientMapping[]|http:NotFound {
        log:printInfo("Received request for patient ID: " + uniquePatientId);
        readonly & HospitalPatientMapping[]? mappings = patientMappingStore.get(uniquePatientId);
        if mappings is () {
            return {
                body: {
                    message: string `Patient ID ${uniquePatientId} not found`
                }
            };
        }
        log:printInfo(string `Returning mappings ${mappings.toBalString()} for patient ID: ${uniquePatientId}`);
        return mappings.clone();
    }
}
