import Foundation

class Picture: Codable {
    var image: String
    var text: String?
    var heart: Bool
    
    init(image: String, text: String, heart: Bool) {
        self.image = image
        self.text = text
        self.heart = heart
    }
    
    public enum CodingKeys: String, CodingKey {
        case image, text, heart
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.image = try container.decode(String.self, forKey: .image)
        self.text = try container.decodeIfPresent(String.self, forKey: .text)
        self.heart = try container.decode(Bool.self, forKey: .heart)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.image, forKey: .image)
        try container.encode(self.text, forKey: .text)
        try container.encode(self.heart, forKey: .heart)
    }
}
