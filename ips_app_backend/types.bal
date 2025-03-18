import ballerinax/health.fhir.r4 as r4;

// MPI response types
type PatientMapping record {
    string hospitalId;
    string patientId;
};

type MpiResponse record {
    PatientMapping[] mappings;
};

// Hospital registry response types
type Hospital record {
    string id;
    string url;
};

// Hospital API response type
type HospitalResponse record {
    r4:DomainResource[] resources;
};
