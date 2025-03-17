import ballerina/http;

service / on new http:Listener(9092) {
    isolated resource function get hospitals/[string hospitalId]/connection() returns HospitalConnection|http:NotFound {
        string? url = hospitalConnections[hospitalId];
        if url is () {
            return {
                body: {
                    message: string `Hospital with ID ${hospitalId} not found`,
                    code: "HOSPITAL_NOT_FOUND"
                }
            };
        }
        return {
            hospitalId: hospitalId,
            url: url
        };
    }
}