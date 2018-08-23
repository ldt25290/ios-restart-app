
import LGCoreKit
import LGComponents

extension ServiceListingType {
    
    static var allCases: [ServiceListingType] {
        return [.service, .job]
    }
    
    static func allCases(withFirstItem firstItem: ServiceListingType) -> [ServiceListingType] {
        switch firstItem {
        case .service:
            return allCases
        case .job:
            return [.job, .service]
        }
    }
    
    var displayPrefix: String {
        switch self {
        case .job:
            return R.Strings.postDetailsJobsServicesStepOptionJobsPrefix
        case .service:
            return R.Strings.postDetailsJobsServicesStepOptionServicesPrefix
        }
    }
    
    var displayName: String {
        switch self {
        case .job:
            return R.Strings.postDetailsListingTypeJobDisplayName
        case .service:
            return R.Strings.postDetailsListingTypeServiceDisplayName
        }
    }
    
    var pluralDisplayName: String {
        switch self {
        case .job:
            return R.Strings.editJobsServicesJobsOptionTitle
        case .service:
            return R.Strings.editJobsServicesServicesOptionTitle
        }
    }
}
