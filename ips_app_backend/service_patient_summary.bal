import ballerina/http;
import ballerina/log;
import ballerinax/health.fhir.r4 as r4;
import ballerinax/health.fhir.r4.international401 as international401;
import ballerinax/health.fhir.r4.ips as ips;

final http:Client mpiClient = check new (mpiUrl);
final http:Client hospitalRegistryClient = check new (registryUrl);

# HTTP service to handle patient summary requests
service / on new http:Listener(servicePort) {

    # Resource to get patient summary as FHIR IPS bundle
    #
    # + patientId - ID of the patient
    # + return - FHIR Bundle containing patient summary or error response
    resource function get [string patientId]/summary() returns json|error {
        // Get patient mappings from MPI
        log:printInfo("Getting patient mappings from MPI for ID: " + patientId);
        MpiResponse|http:ClientError mpiResponse = mpiClient->/mpi/[patientId]/mappings;
        PatientMapping[] patientMappings = [];
        if (mpiResponse is http:ClientError) {
            log:printError("Error getting patient mappings from MPI for ID: " + patientId, mpiResponse);
            return error("Error getting patient mappings from MPI");
        } else {
            patientMappings = mpiResponse.mappings;
        }

        if patientMappings.length() == 0 {
            log:printError("Patient not found for ID: " + patientId);
            return error("Patient not found");
        }

        r4:BundleEntry[] bundleEntries = [];
        // For each mapping, get resources from respective hospitals
        foreach PatientMapping mapping in patientMappings {
            string hospitalId = mapping.hospitalId;
            string hospitalPatientId = mapping.patientId;

            Hospital?|http:ClientError hospital = hospitalRegistryClient->/hospitals/[hospitalId]/connection;
            if hospital is http:ClientError {
                log:printError("Error getting hospital connection details for ID: " + hospitalId, hospital);
                continue;
            }
            if hospital is () {
                continue;
            }
            log:printInfo("Getting patient data from hospital: " + hospital.url + " for patient ID: " + hospitalPatientId);
            // Create client for hospital API
            http:Client|http:ClientError hospitalClient = new (hospital.url);
            if hospitalClient is http:ClientError {
                log:printError("Error creating client for hospital: " + hospital.url, hospitalClient);
                continue;
            }
            // Get patient resource
            international401:Patient patientResource = check hospitalClient->/Patient/[hospitalPatientId];
            bundleEntries.push({
                'resource: patientResource
            });

            // Get allergies
            r4:Bundle allergyResources = check hospitalClient->/AllergyIntolerance(patient = hospitalPatientId);

            r4:BundleEntry[]? allergyEntries = allergyResources.entry;
            if allergyEntries is r4:BundleEntry[] {
                bundleEntries.push(...allergyEntries);
            }

            // Get conditions
            r4:Bundle conditionResources = check hospitalClient->/Condition(patient = hospitalPatientId);

            r4:BundleEntry[]? conditionEntries = conditionResources.entry;
            if conditionEntries is r4:BundleEntry[] {
                bundleEntries.push(...conditionEntries);
            }
        }

        // Create and return the bundle
        r4:Bundle summaryBundle = {
            resourceType: "Bundle",
            'type: r4:BUNDLE_TYPE_DOCUMENT,
            entry: bundleEntries
        };
        summaryBundle = check ips:getIpsBundle(summaryBundle);
        return summaryBundle.toJson();
    }

}
